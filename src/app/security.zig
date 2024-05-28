const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("db.zig");
const jwt = @import("jwt.zig");
const log = std.log.scoped(.security);

pub const RestrictedPaths = .{"/"};

pub const Ticket = struct { name: []const u8, uid: i64, iat: i64, exp: i64, mod: i64 };

pub fn validatePassword(password: []const u8, salt: []const u8, stored_key: *const [32]u8) !bool {
    var key: [32]u8 = undefined;
    try std.crypto.pwhash.pbkdf2(&key, password, salt, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
    return std.mem.eql(u8, &key, stored_key);
}

pub fn issueTicket(allocator: std.mem.Allocator, email: []const u8, password: []const u8) !?Ticket {
    if (try db.lookupAccount(allocator, email)) |account| {
        defer allocator.free(account.email);
        if (try validatePassword(password, email, account.key[0..32])) {
            return .{ .name = account.name, .uid = account.uid, .iat = std.time.timestamp(), .exp = 0, .mod = account.mod };
        }
    }
    return null;
}

pub fn login(request: *jetzig.Request, email: []const u8, password: []const u8) !bool {
    if (try issueTicket(request.allocator, email, password)) |ticket| {
        defer request.allocator.free(ticket.name);
        var data = jetzig.zmpl.Data.init(request.allocator);
        var root = try data.object();
        try root.put("name", data.string(ticket.name));
        try root.put("uid", data.integer(ticket.uid));
        try root.put("iat", data.integer(ticket.iat));
        try root.put("exp", data.integer(ticket.exp));
        try root.put("mod", data.integer(ticket.mod));
        var session = try request.session();
        try session.put("ticket", root);
        return true;
    }
    return false;
}

pub fn logout(request: *jetzig.Request) !void {
    var session = try request.session();
    try session.reset();
    try request.server.logger.DEBUG("session reset!", .{});
}

pub fn authorize(request: *jetzig.Request) !void {
    const data = request.response_data;
    var root = try data.object();
    try request.server.logger.DEBUG("authorizing request for {s}", .{request.path.path});
    var authorized: bool = true;
    const session = try request.session();
    if (try session.get("ticket")) |ticket| {
        try root.put("user_name", data.string(ticket.getT(.string, "name") orelse "?"));
    } else {
        try root.put("user_name", data.string("Guest"));
        inline for (RestrictedPaths) |restricted_path| {
            if (std.mem.eql(u8, request.path.path, restricted_path)) {
                authorized = false;
                break;
            }
        }
    }
    try root.put("authorized", data.boolean(authorized));
}

// if(auth.validate(request.allocator, jwt.string.value)) |payload| {
//     _ = payload;
//     try root.put("auth_link", request.response_data.string("/logout"));
//     try root.put("auth_link_text", request.response_data.string("Log Out"));
//     return;
// }

pub const JwtPayload = struct { sub: i64, iat: i64 };

const sig = jwt.SignatureOptions{ .key = "-~-tslive-~-" };

pub fn issueToken(allocator: std.mem.Allocator, email: []const u8, password: []const u8) !?[]const u8 {
    const account_found = try db.lookupAccount(allocator, email);
    if (account_found) |account| {
        defer account.deinit();
        log.info("account lookup succeeded for email {s}", .{email});
        // generate hash and compare with key
        var key: [32]u8 = undefined;
        try std.crypto.pwhash.pbkdf2(&key, password, email, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
        if (std.mem.eql(u8, &key, &account.key)) {
            // issue token
            const payload = JwtPayload{
                .sub = account.id,
                .iat = std.time.timestamp(),
            };
            const token = try jwt.encode(allocator, .HS256, payload, sig);
            return token;
        }
        log.info("authentication failed for password {s}", .{password});
        return null;
    }
    log.info("account lookup failed for email {s}", .{email});
    return null;
}

pub fn validateToken(allocator: std.mem.Allocator, token: []const u8) ?JwtPayload {
    var decoded_p = jwt.validate(JwtPayload, allocator, .HS256, token, sig) catch return null;
    defer decoded_p.deinit();
    return decoded_p.value;
}
