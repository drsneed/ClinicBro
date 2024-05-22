pub const std = @import("std");
pub const zqlite = @import("zqlite");

pub const db_name = "tslive.db";

pub const Account = struct {
    allocator: std.mem.Allocator,
    uid: i64,
    name: []u8,
    email: []u8,
    phone: []u8,
    mod: i64,
    iat: i64,
    uat: i64,
    key: [32]u8 = undefined,

    pub fn init(allocator: std.mem.Allocator, uid: i64, name: []const u8, email: []const u8, 
        phone: []const u8, mod: i64, iat: i64, uat:i64, key: *const [32]u8) !Account {
        return .{
            .allocator = allocator,
            .uid = uid,
            .name = try allocator.dupe(u8, name),
            .email = try allocator.dupe(u8, email),
            .phone = try allocator.dupe(u8, phone),
            .mod = mod,
            .iat = iat,
            .uat = uat,
            .key = key.*
        };
    }
    
    pub fn deinit(self: Account) void {
        self.allocator.free(self.name);
        self.allocator.free(self.email);
        self.allocator.free(self.phone);
    }
    
    // pub const Status = enum(u8) {
    //     Active,
    //     Inactive,
    //     Locked,
    //     Closed
    // };
    // pub const Role = enum(u8) {
    //     Root,
    //     Admin,
    //     Moderator,
    //     User
    // };
};

pub fn lookupAccount(allocator: std.mem.Allocator, email: []const u8) !?Account {
    var account: ?Account = null;
    var conn = try zqlite.open(db_name, zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode);
    defer conn.close();
    if (try conn.row("select * from account where email=(?1)", .{email})) |row| {
        defer row.deinit();
        // (uid,name,email,phone,mod,iat,uat,key)
        account = try Account.init(allocator, row.int(0), row.text(1), row.text(2),
            row.text(3), row.int(4), row.int(5), row.int(6), row.blob(7)[0..32]);
    }
    return account;
}