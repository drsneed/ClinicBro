const std = @import("std");

const Account = @This();

allocator: std.mem.Allocator,
uid: i64,
name: []u8,
email: []u8,
phone: []u8,
mod: i64,
iat: []u8,
uat: []u8,
key: [32]u8 = undefined,

pub fn init(allocator: std.mem.Allocator, uid: i64, name: []const u8, email: []const u8, phone: []const u8, mod: i64, iat: []const u8, uat: []const u8, key: *const [32]u8) !Account {
    return .{
        .allocator = allocator,
        .uid = uid,
        .name = try allocator.dupe(u8, name),
        .email = try allocator.dupe(u8, email),
        .phone = try allocator.dupe(u8, phone),
        .mod = mod,
        .iat = try allocator.dupe(u8, iat),
        .uat = try allocator.dupe(u8, uat),
        .key = key.*,
    };
}

pub fn deinit(self: Account) void {
    self.allocator.free(self.name);
    self.allocator.free(self.email);
    self.allocator.free(self.phone);
    self.allocator.free(self.iat);
    self.allocator.free(self.uat);
}
