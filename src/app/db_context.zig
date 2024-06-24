const std = @import("std");
const pg = @import("pg");
const UserAccount = @import("models/user_account.zig");
const log = std.log.scoped(.DbContext);
const DbContext = @This();
allocator: std.mem.Allocator,
pool: *pg.Pool,

pub fn init(allocator: std.mem.Allocator) !DbContext {
    return .{
        .allocator = allocator,
        .pool = try pg.Pool.init(allocator, .{ .size = 5, .connect = .{
            .port = 5432,
            .host = "127.0.0.1",
        }, .auth = .{
            .username = "postgres",
            .database = "ClinicBro",
            .password = "tokyo_2",
            .timeout = 10_000,
        } }),
    };
}

pub fn deinit(self: DbContext) void {
    self.pool.deinit();
}

pub fn validateUser(self: DbContext, name: []const u8, password: []const u8) !?UserAccount {
    var result = try self.pool.query("SELECT id, name FROM user_account where name=$1 and (password = crypt($2, password))", .{ name, password });
    defer result.deinit();
    if (try result.next()) |row| {
        const id = row.get(i32, 0);
        const db_name = row.get([]u8, 1);
        //const date_created = row.get(i64, 2);
        //log.info("date_created = {d}", .{date_created});
        const user = try UserAccount.init(self.allocator, id, db_name, 0);
        return user;
    }

    return null;
}

pub fn getAllUsers(self: DbContext) !std.ArrayList(UserAccount) {
    var result = try self.pool.query("select id, name, date_created from user_account", .{});
    defer result.deinit();

    var users = std.ArrayList(UserAccount).init(self.allocator);

    while (try result.next()) |row| {
        const id = row.get(i32, 0);
        const name = row.get([]u8, 1);
        const date_created = row.get(i64, 2);
        const user = try UserAccount.init(self.allocator, id, name, date_created);
        try users.append(user);
    }

    return users;
}