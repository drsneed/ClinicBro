const std = @import("std");
const jetzig = @import("jetzig");
pub const Bro = @import("models/domain/bro.zig");
pub const BroItem = @import("models/bro_item.zig");
const log = std.log.scoped(.DbContext);
const DbContext = @This();

const bro_select_query =
    \\select bro.id, bro.active, bro.name, bro.color, bro.sees_clients,
    \\to_char(bro.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(bro.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from Bro bro 
    \\left join Bro created_bro on bro.created_bro_id=created_bro.id
    \\left join Bro updated_bro on bro.updated_bro_id=updated_bro.id
;
const bro_item_select_query = "select id, name from Bro";
const bro_insert_query =
    \\insert into Bro(active, name, password, color, sees_clients, date_created, date_updated, created_bro_id, updated_bro_id)
    \\values(true, $1, $2, 0, false, NOW(), NOW(), $3, $3);
;

allocator: std.mem.Allocator,
results: std.ArrayList(jetzig.http.Database.pg.Result),
database: *jetzig.http.Database,
pub fn init(allocator: std.mem.Allocator, database: *jetzig.http.Database) DbContext {
    return .{
        .allocator = allocator,
        .database = database,
        .results = std.ArrayList(jetzig.http.Database.pg.Result).init(allocator),
    };
}
pub fn deinit(self: DbContext) void {
    for (self.results.items) |result| {
        result.deinit();
    }
    self.results.deinit();
}

pub fn validateBroPassword(self: *DbContext, name: []const u8, password: []const u8) !?BroItem {
    var result = try self.database.pool.query(bro_item_select_query ++ " where name=$1 and (password = crypt($2, password))", .{
        name,
        password,
    });
    try self.results.append(result);
    if (try result.next()) |row| {
        return .{ .id = row.get(i32, 0), .name = row.get([]u8, 1) };
    }
    return null;
}

fn makeBro(row: jetzig.http.Database.pg.Row) Bro {
    return .{
        .id = row.get(i32, 0),
        .active = row.get(bool, 1),
        .name = row.get([]u8, 2),
        .color = row.get(i32, 3),
        .sees_clients = row.get(bool, 4),
        .date_created = row.get([]u8, 5),
        .date_updated = row.get([]u8, 6),
        .created_by = row.get(?[]u8, 7),
        .updated_by = row.get(?[]u8, 8),
    };
}
pub fn updateBro(self: *DbContext, args: struct {
    id: i32,
    updated_bro_id: i32,
    name: ?[]const u8 = null,
    password: ?[]const u8 = null,
    color: ?i32 = null,
    active: ?bool = null,
}) !bool {
    if (args.name) |name| {
        _ = try self.database.pool.exec("update Bro set name=$1, date_updated = NOW(), updated_bro_id=$2 where id=$3", .{
            name,
            args.updated_bro_id,
            args.id,
        });
    }

    return true;
}

pub fn createBro(self: *DbContext, args: struct {
    updated_bro_id: i32,
    name: []const u8,
    password: ?[]const u8 = null,
    color: ?i32 = null,
    active: ?bool = null,
}) !i32 {
    _ = try self.database.pool.exec(bro_insert_query, .{
        args.name,
        "temp",
        args.updated_bro_id,
    });
    var result = try self.database.pool.query("select id from bro where name = $1", .{args.name});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteBro(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from Bro where id=$1", .{id});
    return true;
}

pub fn getBro(self: *DbContext, id: i32) !?Bro {
    var result = try self.database.pool.query(bro_select_query ++ " where bro.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return makeBro(row);
    }
    return null;
}

pub fn getBroItems(self: *DbContext, include_all: bool) !std.ArrayList(BroItem) {
    const query = if (include_all)
        bro_item_select_query ++ " order by name"
    else
        bro_item_select_query ++ " where active=true order by name";

    var result = try self.database.pool.query(query, .{});
    try self.results.append(result);
    var bros = std.ArrayList(BroItem).init(self.allocator);
    while (try result.next()) |row| {
        try bros.append(.{ .id = row.get(i32, 0), .name = row.get([]u8, 1) });
    }
    return bros;
}
