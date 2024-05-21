const std = @import("std");
const db = @import("db.zig");
const log = std.log.scoped(.auth);

pub fn authenticate(allocator: std.mem.Allocator, email: []const u8, password: []const u8) !bool {
    const account_found = try db.lookupAccount(allocator, email);
    if(account_found) |account| {
        defer account.deinit();
        log.info("account lookup succeeded for email {s}", .{email});
        var key: [32]u8 = undefined;
        try std.crypto.pwhash.pbkdf2(&key, password, email, 2171, std.crypto.auth.hmac.sha2.HmacSha256);
        if(std.mem.eql(u8, &key, &account.key)) {
            return true;
        }
        log.info("authentication failed for password {s}", .{password});
        return false;
    }
    log.info("account lookup failed for email {s}", .{email});
    return false;
}