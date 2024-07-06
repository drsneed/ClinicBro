const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../db_context.zig");
const mapper = @import("../mapper.zig");
const Appointment = @import("../models/appointment.zig");
const log = std.log.scoped(.clients);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    const json_appts = try data.array();
    var root = data.value.?;
    try root.put("appts", json_appts);
    const db_appts = try db_context.getAllAppointments();
    defer db_appts.deinit();
    for (db_appts.items) |appt| {
        var json_appt = try data.object();
        try json_appt.put("id", data.integer(appt.id));
        try json_appt.put("title", data.string(appt.title));
        try json_appt.put("appt_date", data.string(appt.appt_date));
        try json_appt.put("appt_from", data.string(appt.appt_from));
        try json_appt.put("appt_to", data.string(appt.appt_to));
        try json_appt.put("selected", data.string(""));
        try json_appts.append(json_appt);
    }
    return request.render(.ok);
}
pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const appt_id = try std.fmt.parseInt(i32, id, 10);
    var appointment = Appointment{};
    if (appt_id > 0) {
        appointment = try db_context.getAppointment(appt_id) orelse appointment;
    } else {
        const params = try request.params();
        if (params.getT(.string, "date")) |date| {
            log.info("got date '{s}'", .{date});
            appointment.appt_date = date;
        }
    }
    try mapper.appointment.toResponse(appointment, data);
    var root = data.value.?;
    const json_locations = try data.array();
    try root.put("locations", json_locations);
    const locations = try db_context.lookupLocations(false);
    for (locations.items) |loc| {
        var json_loc = try data.object();
        try json_loc.put("id", data.integer(loc.id));
        try json_loc.put("active", data.boolean(loc.active));
        try json_loc.put("name", data.string(loc.name));
        try json_loc.put("selected", data.string(if (appointment.location_id == loc.id) "selected" else ""));
        try json_locations.append(json_loc);
    }

    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bros = try db_context.lookupProviderBros(false);
    defer bros.deinit();
    for (bros.items) |bro| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro.id));
        try json_bro.put("active", data.boolean(bro.active));
        try json_bro.put("name", data.string(bro.name));
        try json_bro.put("selected", data.string(if (appointment.bro_id == bro.id) "selected" else ""));
        try json_bros.append(json_bro);
    }

    const json_appt_types = try data.array();
    try root.put("appt_types", json_appt_types);
    const appt_types = try db_context.lookupItems("AppointmentType", false);
    defer appt_types.deinit();
    for (appt_types.items) |appt_type| {
        var json_appt_type = try data.object();
        try json_appt_type.put("id", data.integer(appt_type.id));
        try json_appt_type.put("active", data.boolean(appt_type.active));
        try json_appt_type.put("name", data.string(appt_type.name));
        try json_appt_type.put("selected", data.string(if (appointment.type_id == appt_type.id) "selected" else ""));
        try json_appt_types.append(json_appt_type);
    }

    const json_appt_statuses = try data.array();
    try root.put("appt_statuses", json_appt_statuses);
    const appt_statuses = try db_context.lookupItems("AppointmentStatus", false);
    defer appt_statuses.deinit();
    for (appt_statuses.items) |appt_status| {
        var json_appt_status = try data.object();
        try json_appt_status.put("id", data.integer(appt_status.id));
        try json_appt_status.put("active", data.boolean(appt_status.active));
        try json_appt_status.put("name", data.string(appt_status.name));
        try json_appt_status.put("selected", data.string(if (appointment.status_id == appt_status.id) "selected" else ""));
        try json_appt_statuses.append(json_appt_status);
    }

    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    var appointment = try mapper.appointment.fromRequest(request);
    if (appointment.id == 0) {
        appointment.id = try db_context.createAppointment(appointment, current_bro_id);
    } else {
        try db_context.updateAppointment(appointment, current_bro_id);
    }
    var id_buffer: [8]u8 = undefined;
    const id_str = try std.fmt.bufPrint(&id_buffer, "{d}", .{appointment.id});
    return get(id_str, request, data);
}

pub fn put(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn patch(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const appt_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteAppointment(appt_id);
    return request.render(.ok);
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/clients", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/clients", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}
