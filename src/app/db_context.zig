const std = @import("std");
const jetzig = @import("jetzig");
const Bro = @import("models/domain/bro.zig");
const log = std.log.scoped(.DbContext);
const DbContext = @This();
allocator: std.mem.Allocator,

pub fn validateBro(database: *jetzig.http.Database, name: []const u8, password: []const u8) !?Bro {
    var result = try database.pool.query("select * from Bro where name=$1 and (password = crypt($2, password))", .{ name, password });
    defer result.deinit();
    if (try result.next()) |row| {
        return makeBro(row);
    }
    return null;
}

fn makeBro(row: jetzig.http.Database.pg.Row) Bro {
    var bro = Bro{
        .id = row.get(i32, 0),
        .active = row.get(bool, 1),
        // copy name below (row 2)
        // skip password (row 3)
        .color = row.get(i32, 4),
        .sees_clients = row.get(bool, 5),
        .date_created = row.get(i64, 6),
        .date_updated = row.get(i64, 7),
        .created_bro_id = row.get(i32, 8),
        .updated_bro_id = row.get(i32, 9),
    };
    _ = std.fmt.bufPrint(bro.name[0..], "{s}", .{row.get([]u8, 2)}) catch unreachable;
    return bro;
}

pub fn getBros(allocator: std.mem.Allocator, database: *jetzig.http.Database, include_inactive: bool) !std.ArrayList(Bro) {
    const query = if (include_inactive) "select * from Bro" else "select * from Bro where active=true";
    var result = try database.pool.query(query, .{});
    defer result.deinit();
    var bros = std.ArrayList(Bro).init(allocator);
    while (try result.next()) |row| {
        try bros.append(makeBro(row));
    }
    return bros;
}
