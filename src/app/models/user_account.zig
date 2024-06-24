const std = @import("std");

const UserAccount = @This();

allocator: std.mem.Allocator,
id: i32,
name: []u8,
date_created: i64,

pub fn init(allocator: std.mem.Allocator, id: i32, name: []const u8, date_created: i64) !UserAccount {
    return .{
        .allocator = allocator,
        .id = id,
        .name = try allocator.dupe(u8, name),
        .date_created = date_created,
        //.date_created = try allocator.dupe(u8, date_created),
    };
}

pub fn deinit(self: UserAccount) void {
    self.allocator.free(self.name);
    //self.allocator.free(self.date_created);
}
