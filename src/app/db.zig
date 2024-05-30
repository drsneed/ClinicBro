pub const std = @import("std");
pub const zqlite = @import("zqlite");
const Account = @import("models/account.zig");
pub const db_name = "tslive.db";

pub fn lookupAccount(allocator: std.mem.Allocator, email: []const u8) !?Account {
    var account: ?Account = null;
    var conn = try zqlite.open(db_name, zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode);
    defer conn.close();
    if (try conn.row("select * from account where email=(?1)", .{email})) |row| {
        defer row.deinit();
        // (uid,name,email,phone,mod,iat,uat,key)
        account = try Account.init(
            allocator,
            row.int(0),
            row.text(1),
            row.text(2),
            row.text(3),
            row.int(4),
            row.text(5),
            row.text(6),
            row.blob(7)[0..32],
        );
    }
    return account;
}

pub fn getAllAccounts(allocator: std.mem.Allocator) !std.ArrayList(Account) {
    var accounts = std.ArrayList(Account).init(allocator);
    var conn = try zqlite.open(db_name, zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode);
    defer conn.close();
    var rows = try conn.rows("select * from account", .{});
    defer rows.deinit();
    while (rows.next()) |row| {
        const account = try Account.init(
            allocator,
            row.int(0),
            row.text(1),
            row.text(2),
            row.text(3),
            row.int(4),
            row.text(5),
            row.text(6),
            row.blob(7)[0..32],
        );
        try accounts.append(account);
    }
    return accounts;
}
