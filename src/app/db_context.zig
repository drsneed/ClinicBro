const std = @import("std");
const jetzig = @import("jetzig");
pub const Bro = @import("models/bro.zig");
pub const Location = @import("models/location.zig");
const Client = @import("models/client.zig");
const Appointment = @import("models/appointment.zig");
const AppointmentView = @import("models/appointment_view.zig");
const AppointmentType = @import("models/appointment_type.zig");
const AppointmentStatus = @import("models/appointment_status.zig");
pub const LookupItem = @import("models/lookup_item.zig");
const mapper = @import("mapper.zig");
const log = std.log.scoped(.DbContext);
const DbContext = @This();

allocator: std.mem.Allocator,
results: std.ArrayList(*jetzig.http.Database.pg.Result),
query_rows: std.ArrayList(jetzig.http.Database.pg.QueryRow),
database: *jetzig.http.Database,
connection: *jetzig.http.Database.pg.Conn,
pub fn init(allocator: std.mem.Allocator, database: *jetzig.http.Database) !DbContext {
    return .{
        .allocator = allocator,
        .database = database,
        .results = std.ArrayList(*jetzig.http.Database.pg.Result).init(allocator),
        .query_rows = std.ArrayList(jetzig.http.Database.pg.QueryRow).init(allocator),
        .connection = try database.pool.acquire(),
    };
}
pub fn drain(self: *DbContext) !void {
    for (self.results.items) |result| {
        try result.drain();
    }
    for (self.query_rows.items) |*row| {
        try row.result.drain();
    }
}
pub fn deinit(self: *DbContext) !void {
    for (self.results.items) |result| {
        result.deinit();
    }
    self.results.deinit();
    for (self.query_rows.items) |*row| {
        try row.deinit();
    }
    self.query_rows.deinit();
    self.database.pool.release(self.connection);
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
    \\values(true, $1, crypt($2, gen_salt('bf')), $3, $4, NOW(), NOW(), $5, $5);
;
const bro_update_query = "update Bro set active=$2, name=$3, color=$4, sees_clients=$5, date_updated = NOW(), updated_bro_id=$6 where id=$1";
pub fn validateBroPassword(self: *DbContext, name: []const u8, password: []const u8) !?LookupItem {
    var result = try self.connection.query(bro_item_select_query ++ " where name=$1 and active=true and (password = crypt($2, password))", .{
        name,
        password,
    });
    try self.results.append(result);
    if (try result.next()) |row| {
        return .{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) };
    }
    return null;
}

pub fn updateBro(self: *DbContext, bro: Bro, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(bro_update_query, .{
        bro.id,
        bro.active,
        bro.name,
        bro.color,
        bro.sees_clients,
        updated_bro_id,
    });
}

pub fn createBro(self: *DbContext, bro: Bro, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(bro_insert_query, .{
        bro.name,
        "temp",
        bro.color,
        bro.sees_clients,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from bro where name = $1", .{bro.name});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteBro(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from RecentClient where bro_id=$1", .{id});
    _ = try self.database.pool.exec("delete from Bro where id=$1", .{id});
    return true;
}

pub fn getBro(self: *DbContext, id: i32) !?Bro {
    var result = try self.connection.query(bro_select_query ++ " where bro.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapper.bro.fromDatabase(row);
    }
    return null;
}

pub fn lookupProviderBros(self: *DbContext, include_inactive: bool) !std.ArrayList(LookupItem) {
    const query = if (include_inactive)
        bro_item_select_query ++ "where sees_clients=true order by active desc, name"
    else
        bro_item_select_query ++ " where sees_clients=true and active=true order by name";

    var result = try self.connection.query(query, .{});
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

    var result = try self.connection.query(query, .{});
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
    \\update Location set active=$2, name=$3, phone=$4, address_1=$5, address_2=$6, city=$7, state=$8, zip_code=$9,
    \\date_updated = NOW(), updated_bro_id=$10 where id=$1;
;

pub fn updateLocation(self: *DbContext, location: Location, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(location_update_query, .{
        location.id,
        location.active,
        location.name,
        location.phone,
        location.address_1,
        location.address_2,
        location.city,
        location.state,
        location.zip_code,
        updated_bro_id,
    });
}

pub fn createLocation(self: *DbContext, location: Location, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(location_insert_query, .{
        location.name,
        location.phone,
        location.address_1,
        location.address_2,
        location.city,
        location.state,
        location.zip_code,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from location where name = $1", .{location.name});
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
    var result = try self.connection.query(location_select_query ++ " where loc.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapper.location.fromDatabase(row);
    }
    return null;
}

pub fn lookupLocations(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        location_lookup_query ++ " order by active desc, name"
    else
        location_lookup_query ++ " where active=true order by name";

    var result = try self.connection.query(query, .{});
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
const recent_client_query = "select cl.id, cl.active, concat(cl.last_name, ', ', cl.first_name) as name from RecentClient rc join Client cl on rc.client_id=cl.id where rc.bro_id=$1";
const client_lookup_query = "select id, active, concat(last_name, ', ', first_name) as name from Client";
const client_insert_query =
    \\insert into Client(active,first_name,middle_name,last_name,date_of_birth,date_of_death,email,phone,address_1,address_2,city,state,zip_code,notes,can_call,can_text,can_email,location_id,bro_id,date_created,date_updated,created_bro_id,updated_bro_id)
    \\values(true, $1, $2, $3, $4, null, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, NOW(), NOW(), $18, $18);
;
const client_update_query =
    \\update Client set active=$2,first_name=$3,middle_name=$4,last_name=$5,date_of_birth=$6,date_of_death=$7,email=$8,phone=$9,
    \\address_1=$10,address_2=$11,city=$12,state=$13,zip_code=$14,notes=$15,can_call=$16,can_text=$17,can_email=$18,
    \\location_id=$19,bro_id=$20,date_updated=NOW(),updated_bro_id=$21 where id=$1
;

pub fn updateClient(self: *DbContext, client: Client, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(client_update_query, .{
        client.id,
        client.active,
        client.first_name,
        client.middle_name,
        client.last_name,
        client.date_of_birth,
        client.date_of_death,
        client.email,
        client.phone,
        client.address_1,
        client.address_2,
        client.city,
        client.state,
        client.zip_code,
        client.notes,
        client.can_call,
        client.can_text,
        client.can_email,
        client.location_id,
        client.bro_id,
        updated_bro_id,
    });
}

pub fn createClient(self: *DbContext, client: Client, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(client_insert_query, .{
        client.first_name,
        client.middle_name,
        client.last_name,
        client.date_of_birth,
        client.email,
        client.phone,
        client.address_1,
        client.address_2,
        client.city,
        client.state,
        client.zip_code,
        client.notes,
        client.can_call,
        client.can_text,
        client.can_email,
        client.location_id,
        client.bro_id,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from Client where first_name = $1 and last_name=$2", .{ client.first_name, client.last_name });
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteClient(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from RecentClient where client_id=$1", .{id});
    _ = try self.database.pool.exec("delete from Client where id=$1", .{id});
    return true;
}

pub fn getClient(self: *DbContext, id: i32) !?Client {
    const result = try self.connection.row(client_select_query ++ " where cl.id=$1", .{id});
    if (result) |row| {
        try self.query_rows.append(row);
        return mapper.client.fromDatabase(row.row);
    }
    return null;
}

pub fn lookupClientItem(self: *DbContext, id: i32) !?LookupItem {
    const result = try self.connection.row(
        client_lookup_query ++ " where id=$1",
        .{id},
    );

    if (result) |row| {
        try self.query_rows.append(row);
        return LookupItem{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]const u8, 2) };
    }
    //var db_mapper = result.mapper(LookupItem, .{ .dupe = true, .allocator = self.allocator });
    // if (try db_mapper.next()) |item| {
    //     return item;
    // }
    return null;
}

pub fn lookupClients(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        client_lookup_query ++ " order by active desc, name"
    else
        client_lookup_query ++ " where active=true order by name";
    var result = try self.connection.query(query, .{});
    try self.results.append(result);
    var lookup_list = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]const u8, 2) });
    }
    return lookup_list;
}

pub fn lookupRecentClients(self: *DbContext, bro_id: i32) !std.ArrayList(LookupItem) {
    var result = try self.connection.query(recent_client_query, .{bro_id});
    try self.results.append(result);
    var lookup_list = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]const u8, 2) });
    }
    return lookup_list;
}

pub fn addRecentClient(self: *DbContext, bro_id: i32, client_id: i32) !void {
    _ = try self.database.pool.exec("insert into RecentClient(bro_id, client_id, date_created) values($1, $2, NOW())", .{ bro_id, client_id });
}

// ------------------------------- AppointmentType Context ------------------------------------------
const appointment_type_select_query =
    \\select apt.id, apt.active, apt.name, apt.abbreviation, apt.color,
    \\to_char(apt.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(apt.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from AppointmentType apt
    \\left join Bro created_bro on apt.created_bro_id=created_bro.id
    \\left join Bro updated_bro on apt.updated_bro_id=updated_bro.id
;
const appointment_type_lookup_query = "select id, active, name from AppointmentType";
const appointment_type_insert_query =
    \\insert into AppointmentType(active,name,abbreviation,color,date_created,date_updated,created_bro_id,updated_bro_id)
    \\values(true, $1, $2, $3, NOW(), NOW(), $4, $4);
;
const appointment_type_update_query =
    \\update AppointmentType set active=$2,name=$3,abbreviation=$4,color=$5,date_updated=NOW(),updated_bro_id=$6 where id=$1
;

pub fn updateAppointmentType(self: *DbContext, appointment_type: AppointmentType, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(appointment_type_update_query, .{
        appointment_type.id,
        appointment_type.active,
        appointment_type.name,
        appointment_type.abbreviation,
        appointment_type.color,
        updated_bro_id,
    });
}

pub fn createAppointmentType(self: *DbContext, appointment_type: AppointmentType, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(appointment_type_insert_query, .{
        appointment_type.name,
        appointment_type.abbreviation,
        appointment_type.color,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from AppointmentType where name = $1", .{appointment_type.name});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteAppointmentType(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from AppointmentType where id=$1", .{id});
    return true;
}

pub fn getAppointmentType(self: *DbContext, id: i32) !?AppointmentType {
    var result = try self.connection.query(appointment_type_select_query ++ " where apt.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapper.appointment_type.fromDatabase(row);
    }
    return null;
}

pub fn lookupAppointmentTypes(self: *DbContext, include_all: bool) !std.ArrayList(LookupItem) {
    const query = if (include_all)
        appointment_type_lookup_query ++ " order by active desc, name"
    else
        appointment_type_lookup_query ++ " where active=true order by name";
    var result = try self.connection.query(query, .{});
    try self.results.append(result);
    var lookup_list = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]u8, 2) });
    }
    return lookup_list;
}

pub fn lookupItems(self: *DbContext, table_name: []const u8, include_all: bool) !std.ArrayList(LookupItem) {
    var query_buffer: [256]u8 = undefined;
    const query = try std.fmt.bufPrint(&query_buffer, "select id, active, name from {s}{s}", .{
        table_name,
        if (include_all) " order by active desc, name" else " where active=true order by name",
    });
    var result = try self.connection.query(query, .{});
    try self.results.append(result);
    var lookup_list = std.ArrayList(LookupItem).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(.{ .id = row.get(i32, 0), .active = row.get(bool, 1), .name = row.get([]const u8, 2) });
    }
    return lookup_list;
}

// ------------------------------- AppointmentStatus Context ------------------------------------------
const appointment_status_select_query =
    \\select apt.id, apt.active, apt.name, apt.show,
    \\to_char(apt.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(apt.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name, updated_bro.name from AppointmentStatus apt
    \\left join Bro created_bro on apt.created_bro_id=created_bro.id
    \\left join Bro updated_bro on apt.updated_bro_id=updated_bro.id
;
const appointment_status_insert_query =
    \\insert into AppointmentStatus(active,name,show,date_created,date_updated,created_bro_id,updated_bro_id)
    \\values(true, $1, $2, NOW(), NOW(), $3, $3);
;
const appointment_status_update_query =
    \\update AppointmentStatus set active=$2,name=$3,show=$4,date_updated=NOW(),updated_bro_id=$5 where id=$1
;

pub fn updateAppointmentStatus(self: *DbContext, appointment_status: AppointmentStatus, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(appointment_status_update_query, .{
        appointment_status.id,
        appointment_status.active,
        appointment_status.name,
        appointment_status.show,
        updated_bro_id,
    });
}

pub fn createAppointmentStatus(self: *DbContext, appointment_status: AppointmentStatus, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(appointment_status_insert_query, .{
        appointment_status.name,
        appointment_status.show,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from AppointmentStatus where name = $1", .{appointment_status.name});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteAppointmentStatus(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from AppointmentStatus where id=$1", .{id});
    return true;
}

pub fn getAppointmentStatus(self: *DbContext, id: i32) !?AppointmentStatus {
    var result = try self.connection.query(appointment_status_select_query ++ " where apt.id=$1", .{id});
    try self.results.append(result);
    if (try result.next()) |row| {
        return mapper.appointment_status.fromDatabase(row);
    }
    return null;
}

// ------------------------------- Appointment Context ------------------------------------------
const appointment_select_query =
    \\select a.id, a.title, to_char(a.appt_date, 'YYYY-MM-DD'), 
    \\to_char(a.appt_from, 'HH24:MI'), to_char(a.appt_to, 'HH24:MI'),
    \\a.notes, a.type_id, a.status_id, a.client_id, a.bro_id, a.location_id,
    \\to_char(a.date_created, 'YYYY-MM-DD at HH12:MI AM') as date_created,
    \\to_char(a.date_updated, 'YYYY-MM-DD at HH12:MI AM') as date_updated,
    \\created_bro.name as created_by, updated_bro.name as updated_by from Appointment a
    \\left join Bro created_bro on a.created_bro_id=created_bro.id
    \\left join Bro updated_bro on a.updated_bro_id=updated_bro.id
;
const appointment_insert_query =
    \\insert into Appointment(title,appt_date,appt_from,appt_to,notes,type_id,status_id,client_id,bro_id,location_id,date_created,date_updated,created_bro_id,updated_bro_id)
    \\values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW(), $11, $11);
;
const appointment_update_query =
    \\update Appointment set title=$2,appt_date=$3,appt_from=$4,appt_to=$5,notes=$6,type_id=$7,status_id=$8,client_id=$9,
    \\bro_id=$10,location_id=$11,date_updated=NOW(),updated_bro_id=$12 where id=$1
;

pub fn updateAppointment(self: *DbContext, appointment: Appointment, updated_bro_id: i32) !void {
    _ = try self.database.pool.exec(appointment_update_query, .{
        appointment.id,
        appointment.title,
        appointment.appt_date,
        appointment.appt_from,
        appointment.appt_to,
        appointment.notes,
        appointment.type_id,
        appointment.status_id,
        appointment.client_id,
        appointment.bro_id,
        appointment.location_id,
        updated_bro_id,
    });
}

pub fn createAppointment(self: *DbContext, appointment: Appointment, created_bro_id: i32) !i32 {
    _ = try self.database.pool.exec(appointment_insert_query, .{
        appointment.title,
        appointment.appt_date,
        appointment.appt_from,
        appointment.appt_to,
        appointment.notes,
        appointment.type_id,
        appointment.status_id,
        appointment.client_id,
        appointment.bro_id,
        appointment.location_id,
        created_bro_id,
    });
    var result = try self.connection.query("select max(id) from Appointment", .{});
    try self.results.append(result);
    if (try result.next()) |row| {
        return row.get(i32, 0);
    }
    return 0;
}

pub fn deleteAppointment(self: *DbContext, id: i32) !bool {
    _ = try self.database.pool.exec("delete from Appointment where id=$1", .{id});
    return true;
}

pub fn getAppointment(self: *DbContext, id: i32) !?Appointment {
    const result = try self.connection.row(appointment_select_query ++ " where a.id=$1", .{id});
    if (result) |row| {
        try self.query_rows.append(row);
        return mapper.appointment.fromDatabase(row.row);
    }

    // var db_mapper = result.mapper(Appointment, .{ .dupe = true, .allocator = self.allocator });
    // if (try db_mapper.next()) |appointment| {
    //     return appointment;
    // }
    return null;
}

pub fn getAllAppointments(self: *DbContext) !std.ArrayList(Appointment) {
    var result = try self.connection.query(appointment_select_query, .{});
    try self.results.append(result);
    var lookup_list = std.ArrayList(Appointment).init(self.allocator);
    while (try result.next()) |row| {
        try lookup_list.append(mapper.appointment.fromDatabase(row));
    }
    return lookup_list;
}

pub fn getAllAppointmentViews(self: *DbContext) !std.ArrayList(AppointmentView) {
    var result = try self.connection.queryOpts("select * from AppointmentView", .{}, .{ .column_names = true });
    defer result.deinit();
    var lookup_list = std.ArrayList(AppointmentView).init(self.allocator);
    var db_mapper = result.mapper(AppointmentView, .{ .dupe = true, .allocator = self.allocator });
    while (try db_mapper.next()) |appointment_view| {
        try lookup_list.append(appointment_view);
    }
    // var result = try self.connection.query("select * from AppointmentView", .{});
    // try self.results.append(result);

    // while (try result.next()) |row| {
    //     try lookup_list.append(mapper.appointment_view.fromDatabase(row));
    // }
    return lookup_list;
}
