const std = @import("std");
const db = @import("db.zig");
const jwt = @import("jwt.zig");
const log = std.log.scoped(.auth);

pub const JwtPayload = struct {
    sub: i64,
    iat: i64
};

const sig = jwt.SignatureOptions {
    .key = "-~-tslive-~-"
};

pub fn authenticate(allocator: std.mem.Allocator, email: []const u8, password: []const u8) !?[]const u8 {
    const account_found = try db.lookupAccount(allocator, email);
    if(account_found) |account| {
        defer account.deinit();
        log.info("account lookup succeeded for email {s}", .{email});
        // generate hash and compare with key
        var key: [32]u8 = undefined;
        try std.crypto.pwhash.pbkdf2(&key, password, email, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
        if(std.mem.eql(u8, &key, &account.key)) {
            // issue token
            const payload = JwtPayload {
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

pub fn validate(allocator: std.mem.Allocator, token: []const u8) ?JwtPayload {
    var decoded_p = jwt.validate(JwtPayload, allocator, .HS256, token, sig) catch return null;
    defer decoded_p.deinit();
    return decoded_p.value;
}