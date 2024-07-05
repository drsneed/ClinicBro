const std = @import("std");
const jetzig = @import("jetzig");
pub const Bro = @import("models/bro.zig");
pub const Location = @import("models/location.zig");
pub const Client = @import("models/client.zig");
pub const LookupItem = @import("models/lookup_item.zig");
const log = std.log.scoped(.DbContext);
const DbContext = @This();

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

// ------------------------------- Bro Context ------------------------------------------
const bro_select_query =
    \\select bro.id, bro.active, bro.name, bro.color, bro.sees_clients,
    \\to_char(bro.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(bro.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from Bro bro 
    \\left join Bro created_bro on bro.created_bro_id=created_bro.id
    \\left join Bro updated_bro on bro.updated_bro_id=updated_bro.id
;
const bro_item_select_query = "select id, active, name from Bro";
const bro_insert_query =
    \\insert into Bro(active, name, password, color, sees_clients, date_created, date_updated, created_bro_id, updated_bro_id)
    \\values(true, $1, crypt($2, gen_salt('bf')), 0, $3, NOW(), NOW(), $4, $4);
;

pub fn validateBroPassword(self: *DbContext, name: []const u8, password: []const u8) !?LookupItem {
    var result = try self.database.pool.query(bro_item_select_query ++ " where name=$1 and active=true and (password = crypt($2, password))", .{
        name,
        password,
    });
    try self.results.append(result);
    if (try result.next()) |row| {
        return .{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) };
    }
    return null;
}

fn mapBro(row: jetzig.http.Database.pg.Row) Bro {
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
pub fn updateBro(self: *DbContext, id: i32, name: []const u8, active: bool, sees_clients: bool, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec("update Bro set active=$1, name=$2, sees_clients=$3, date_updated = NOW(), updated_bro_id=$4 where id=$5", .{
        active,
        name,
        sees_clients,
        updated_bro_id,
        id,
    });
}

pub fn createBro(self: *DbContext, updated_bro_id: i32, name: []const u8, sees_clients: bool) !i32 {
    _ = try self.database.pool.exec(bro_insert_query, .{
        name,
        "temp",
        sees_clients,
        updated_bro_id,
    });
    var result = try self.database.pool.query("select max(id) from bro where name = $1", .{name});
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
        return mapBro(row);
    }
    return null;
}

pub fn lookupProviderBros(self: *DbContext, include_inactive: bool) !std.ArrayList(LookupItem) {
    const query = if (include_inactive)
        bro_item_select_query ++ "where sees_clients=true order by active desc, name"
    else
        bro_item_select_query ++ " where sees_clients=true and active=true order by name";

    var result = try self.database.pool.query(query, .{});
    try self.results.append(result);
    var bros = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try bros.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) });
    }
    return bros;
}

pub fn lookupBros(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        bro_item_select_query ++ " order by active desc, name"
    else
        bro_item_select_query ++ " where active=true order by name";

    var result = try self.database.pool.query(query, .{});
    try self.results.append(result);
    var bros = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try bros.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) });
    }
    return bros;
}

// ------------------------------- Location Context ------------------------------------------
const location_select_query =
    \\select loc.id, loc.active, loc.name, loc.phone, loc.address_1, loc.address_2, loc.city, loc.state, loc.zip_code,
    \\to_char(loc.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(loc.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from Location loc
    \\left join Bro created_bro on loc.created_bro_id=created_bro.id
    \\left join Bro updated_bro on loc.updated_bro_id=updated_bro.id
;
const location_lookup_query = "select id, active, name from Location";
const location_insert_query =
    \\insert into Location(active, name, phone, address_1, address_2, city, state, zip_code, date_created, date_updated, created_bro_id, updated_bro_id)
    \\values(true, $1, $2, $3, $4, $5, $6, $7, NOW(), NOW(), $8, $8);
;
const location_update_query =
    \\update Location set active=$1, name=$2, phone=$3, address_1=$4, address_2=$5, city=$6, state=$7, zip_code=$8,
    \\date_updated = NOW(), updated_bro_id=$9 where id=$10;
;

fn mapLocation(row: jetzig.http.Database.pg.Row) Location {
    return .{
        .id = row.get(i32, 0),
        .active = row.get(bool, 1),
        .name = row.get([]u8, 2),
        .phone = row.get([]u8, 3),
        .address_1 = row.get([]u8, 4),
        .address_2 = row.get([]u8, 5),
        .city = row.get([]u8, 6),
        .state = row.get([]u8, 7),
        .zip_code = row.get([]u8, 8),
        .date_created = row.get([]u8, 9),
        .date_updated = row.get([]u8, 10),
        .created_by = row.get(?[]u8, 11),
        .updated_by = row.get(?[]u8, 12),
    };
}

pub fn updateLocation(
    self: *DbContext,
    id: i32,
    active: bool,
    name: []const u8,
    phone: []const u8,
    address_1: []const u8,
    address_2: []const u8,
    city: []const u8,
    state: []const u8,
    zip_code: []const u8,
    updated_bro_id: i32,
) !void {
    _ = try self.database.pool.exec(location_update_query, .{
        active,
        name,
        phone,
        address_1,
        address_2,
        city,
        state,
        zip_code,
        updated_bro_id,
        id,
    });
}

pub fn createLocation(
    self: *DbContext,
    name: []const u8,
    phone: []const u8,
    address_1: []const u8,
    address_2: []const u8,
    city: []const u8,
    state: []const u8,
    zip_code: []const u8,
    updated_bro_id: i32,
) !i32 {
    _ = try self.database.pool.exec(location_insert_query, .{
        name,
        phone,
        address_1,
        address_2,
        city,
        state,
        zip_code,
        updated_bro_id,
    });
    var result = try self.database.pool.query("select max(id) from location where name = $1", .{name});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteLocation(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from Location where id=$1", .{id});
    return true;
}

pub fn getLocation(self: *DbContext, id: i32) !?Location {
    var result = try self.database.pool.query(location_select_query ++ " where loc.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapLocation(row);
    }
    return null;
}

pub fn lookupLocations(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        location_lookup_query ++ " order by active desc, name"
    else
        location_lookup_query ++ " where active=true order by name";

    var result = try self.database.pool.query(query, .{});
    try self.results.append(result);
    var locs = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try locs.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) });
    }
    return locs;
}

// ------------------------------- Client Context ------------------------------------------
const client_select_query =
    \\select cl.id, cl.active, cl.first_name, cl.middle_name, cl.last_name, cl.date_of_birth, cl.date_of_death, cl.email, cl.phone,
    \\cl.address_1, cl.address_2, cl.city, cl.state, cl.zip_code,
    \\cl.notes,cl.can_call,cl.can_text,cl.can_email,cl.location_id,cl.bro_id,
    \\to_char(cl.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(cl.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from Client cl
    \\left join Bro created_bro on cl.created_bro_id=created_bro.id
    \\left join Bro updated_bro on cl.updated_bro_id=updated_bro.id
;
const client_lookup_query = "select id, active, name from Client";
const client_insert_query =
    \\insert into Client(active,first_name,middle_name,last_name,date_of_birth,date_of_death,email,phone,address_1,address_2,city,state,zip_code,notes,can_call,can_text,can_email,location_id,bro_id,date_created,date_updated,created_bro_id,updated_bro_id)
    \\values(true, $1, $2, $3, $4, null, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, NOW(), NOW(), $18, $18);
;
const client_update_query =
    \\update Client set active=$1,first_name=$2,middle_name=$3,last_name=$4,date_of_birth=$5,date_of_death=$6,email=$7,phone=$8,
    \\address_1=$9,address_2=$10,city=$11,state=$12,zip_code=$13,notes=$14,can_call=$15,can_text=$16,can_email=$17,
    \\location_id=$18,bro_id=$19,date_updated=NOW(),updated_bro_id=$20
;

fn mapClient(row: jetzig.http.Database.pg.Row) Client {
    return .{
        .id = row.get(i32, 0),
        .active = row.get(bool, 1),
        .first_name = row.get([]u8, 2),
        .middle_name = row.get([]u8, 3),
        .last_name = row.get([]u8, 4),
        .date_of_birth = row.get(?[]u8, 5),
        .date_of_death = row.get(?[]u8, 6),
        .email = row.get([]u8, 7),
        .phone = row.get([]u8, 8),
        .address_1 = row.get([]u8, 9),
        .address_2 = row.get([]u8, 10),
        .city = row.get([]u8, 11),
        .state = row.get([]u8, 12),
        .zip_code = row.get([]u8, 13),
        .notes = row.get([]u8, 14),
        .can_call = row.get(bool, 15),
        .can_text = row.get(bool, 16),
        .can_email = row.get(bool, 17),
        .location_id = row.get(i32, 18),
        .bro_id = row.get(i32, 19),
        .date_created = row.get([]u8, 20),
        .date_updated = row.get([]u8, 21),
        .created_by = row.get(?[]u8, 22),
        .updated_by = row.get(?[]u8, 23),
    };
}

pub fn updateClient(
    self: *DbContext,
    id: i32,
    active: bool,
    first_name: []const u8,
    middle_name: []const u8,
    last_name: []const u8,
    date_of_birth: ?[]const u8,
    date_of_death: ?[]const u8,
    email: []const u8,
    phone: []const u8,
    address_1: []const u8,
    address_2: []const u8,
    city: []const u8,
    state: []const u8,
    zip_code: []const u8,
    notes: []const u8,
    can_call: bool,
    can_text: bool,
    can_email: bool,
    location_id: i32,
    bro_id: i32,
    updated_bro_id: i32,
) !void {
    _ = try self.database.pool.exec(client_update_query, .{
        active,
        first_name,
        middle_name,
        last_name,
        date_of_birth,
        date_of_death,
        email,
        phone,
        address_1,
        address_2,
        city,
        state,
        zip_code,
        notes,
        can_call,
        can_text,
        can_email,
        location_id,
        bro_id,
        updated_bro_id,
        id,
    });
}

pub fn createClient(
    self: *DbContext,
    first_name: []const u8,
    middle_name: []const u8,
    last_name: []const u8,
    date_of_birth: ?[]const u8,
    email: []const u8,
    phone: []const u8,
    address_1: []const u8,
    address_2: []const u8,
    city: []const u8,
    state: []const u8,
    zip_code: []const u8,
    notes: []const u8,
    can_call: bool,
    can_text: bool,
    can_email: bool,
    location_id: i32,
    bro_id: i32,
    updated_bro_id: i32,
) !i32 {
    _ = try self.database.pool.exec(client_insert_query, .{
        first_name,
        middle_name,
        last_name,
        date_of_birth,
        email,
        phone,
        address_1,
        address_2,
        city,
        state,
        zip_code,
        notes,
        can_call,
        can_text,
        can_email,
        location_id,
        bro_id,
        updated_bro_id,
    });
    var result = try self.database.pool.query("select max(id) from Client where first_name = $1 and last_name=$2", .{ first_name, last_name });
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteClient(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from Client where id=$1", .{id});
    return true;
}

pub fn getClient(self: *DbContext, id: i32) !?Client {
    var result = try self.database.pool.query(client_select_query ++ " where cl.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapClient(row);
    }
    return null;
}

pub fn lookupClients(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        client_lookup_query ++ " order by active desc, name"
    else
        client_lookup_query ++ " where active=true order by name";
    var result = try self.database.pool.query(query, .{});
    try self.results.append(result);
    var lookup_list = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) });
    }
    return lookup_list;
}
