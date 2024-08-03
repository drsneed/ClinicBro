const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("db_context.zig");
const jwt = @import("jwt.zig");
const log = std.log.scoped(.auth);

pub fn validatePassword(password: []const u8, salt: []const u8, stored_key: *const [32]u8) !bool {
    var key: [32]u8 = undefined;
    try std.crypto.pwhash.pbkdf2(&key, password, salt, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
    return std.mem.eql(u8, &key, stored_key);
}

pub fn signin(request: *jetzig.Request, name: []const u8, password: []const u8) !bool {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    if (try db_context.validateBroPassword(name, password)) |bro_item| {
        var data = jetzig.zmpl.Data.init(request.allocator);
        var root = try data.object();
        try root.put("name", data.string(bro_item.name));
        try root.put("id", data.integer(bro_item.id));
        try root.put("iat", data.integer(std.time.timestamp()));
        try root.put("exp", data.integer(0));
        var session = try request.session();
        try session.put("bro", root);
        try db_context.deinit();
        return true;
    }
    try db_context.deinit();
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

pub const JwtPayload = struct { sub: i64, iat: i64, name: []const u8 };

const sig = jwt.SignatureOptions{ .key = "-~-clinicbro-~-" };

pub fn issueToken(request: *jetzig.Request, name: []const u8, password: []const u8) !?[]const u8 {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    if (try db_context.validateBroPassword(name, password)) |bro_item| {

        // issue token
        const payload = JwtPayload{
            .sub = bro_item.id,
            .name = bro_item.name,
            .iat = std.time.timestamp(),
        };
        const token = try jwt.encode(request.allocator, .HS256, payload, sig);
        try db_context.deinit();
        return token;
    }
    try db_context.deinit();
    return null;
}

pub fn validateToken(allocator: std.mem.Allocator, token: []const u8) ?JwtPayload {
    var decoded_p = jwt.validate(JwtPayload, allocator, .HS256, token, sig) catch return null;
    defer decoded_p.deinit();
    return decoded_p.value;
}
