const std = @import("std");
const jetzig = @import("jetzig");
const db_context = @import("db_context.zig");
const jwt = @import("jwt.zig");
const log = std.log.scoped(.auth);

pub fn validatePassword(password: []const u8, salt: []const u8, stored_key: *const [32]u8) !bool {
    var key: [32]u8 = undefined;
    try std.crypto.pwhash.pbkdf2(&key, password, salt, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
    return std.mem.eql(u8, &key, stored_key);
}

pub fn signin(request: *jetzig.Request, name: []const u8, password: []const u8) !bool {
    if (try db_context.validateBro(request.server.database, name, password)) |bro| {
        log.info("security, validated bro {s}", .{bro.name});
        var data = jetzig.zmpl.Data.init(request.allocator);
        var root = try data.object();
        try root.put("name", data.string(bro.name[0..bro.name_len()]));
        try root.put("id", data.integer(bro.id));
        try root.put("iat", data.integer(std.time.timestamp()));
        try root.put("exp", data.integer(0));
        var session = try request.session();
        try session.put("bro", root);
        return true;
    }
    return false;
}

pub fn signout(request: *jetzig.Request) !void {
    var session = try request.session();
    try session.reset();
    try request.server.logger.DEBUG("session reset!", .{});
}

pub fn authenticate(request: *jetzig.Request) !bool {
    var authenticated: bool = false;
    var user_name: []const u8 = "Guest";

    const session = try request.session();
    if (try session.get("bro")) |bro| {
        authenticated = true;
        user_name = bro.getT(.string, "name") orelse "?";
    }

    const data = request.response_data;
    var root = try data.object();
    try root.put("user_name", data.string(user_name));

    return authenticated;
}

pub fn authorize(request: *jetzig.Request) !bool {
    _ = request;
    // todo: authorize based on user permissions
    return true;
}

// if(auth.validate(request.allocator, jwt.string.value)) |payload| {
//     _ = payload;
//     try root.put("auth_link", request.response_data.string("/logout"));
//     try root.put("auth_link_text", request.response_data.string("Log Out"));
//     return;
// }

// pub const JwtPayload = struct { sub: i64, iat: i64 };

// const sig = jwt.SignatureOptions{ .key = "-~-clinicbro-~-" };

// pub fn issueToken(allocator: std.mem.Allocator, email: []const u8, password: []const u8) !?[]const u8 {
//     const account_found = try db.lookupAccount(allocator, email);
//     if (account_found) |account| {
//         defer account.deinit();
//         log.info("account lookup succeeded for email {s}", .{email});
//         // generate hash and compare with key
//         var key: [32]u8 = undefined;
//         try std.crypto.pwhash.pbkdf2(&key, password, email, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
//         if (std.mem.eql(u8, &key, &account.key)) {
//             // issue token
//             const payload = JwtPayload{
//                 .sub = account.id,
//                 .iat = std.time.timestamp(),
//             };
//             const token = try jwt.encode(allocator, .HS256, payload, sig);
//             return token;
//         }
//         log.info("authentication failed for password {s}", .{password});
//         return null;
//     }
//     log.info("account lookup failed for email {s}", .{email});
//     return null;
// }

// pub fn validateToken(allocator: std.mem.Allocator, token: []const u8) ?JwtPayload {
//     var decoded_p = jwt.validate(JwtPayload, allocator, .HS256, token, sig) catch return null;
//     defer decoded_p.deinit();
//     return decoded_p.value;
// }
