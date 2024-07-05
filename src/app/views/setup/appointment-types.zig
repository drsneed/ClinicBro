const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const mapper = @import("../../mapper.zig");
const AppointmentType = @import("../../models/appointment_type.zig");
const log = std.log.scoped(.locations);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    try root.put("page_title", data.string("Appointment Type Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_appointment_types", data.string("class=\"current\""));
    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_appointment_types = try data.array();
    try root.put("setup_items", json_appointment_types);

    const appointment_types = try db_context.lookupAppointmentTypes(include_inactive);
    defer appointment_types.deinit();
    for (appointment_types.items) |appt_type| {
        var json_appt_type = try data.object();
        try json_appt_type.put("id", data.integer(appt_type.id));
        try json_appt_type.put("active", data.boolean(appt_type.active));
        try json_appt_type.put("name", data.string(appt_type.name));
        try json_appointment_types.append(json_appt_type);
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
    var appointment_type = try mapper.appointment_type.fromRequest(request);
    if (appointment_type.id == 0) {
        appointment_type.id = try db_context.createAppointmentType(appointment_type, current_bro_id);
    } else {
        try db_context.updateAppointmentType(appointment_type, current_bro_id);
    }

    var root = data.value.?;

    var include_inactive: bool = false;
    const params = try request.params();
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));

    const json_appt_types = try data.array();
    try root.put("setup_items", json_appt_types);
    const appt_type_lookups = try db_context.lookupAppointmentTypes(include_inactive);
    defer appt_type_lookups.deinit();
    for (appt_type_lookups.items) |appt_type_lookup| {
        var json_appt_type = try data.object();
        try json_appt_type.put("id", data.integer(appt_type_lookup.id));
        try json_appt_type.put("name", data.string(appt_type_lookup.name));
        try json_appt_type.put("active", data.boolean(appt_type_lookup.active));
        try json_appt_type.put("selected", data.string(if (appt_type_lookup.id == appointment_type.id) "selected" else ""));
        try json_appt_types.append(json_appt_type);

        if (appt_type_lookup.id == appointment_type.id) {
            appointment_type = try db_context.getAppointmentType(appointment_type.id) orelse appointment_type;
            try mapper.appointment_type.toResponse(appointment_type, data);
        }
    }

    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const appt_type_id = try std.fmt.parseInt(i32, id, 10);

    var appt_type = AppointmentType{};
    if (appt_type_id > 0) {
        appt_type = try db_context.getAppointmentType(appt_type_id) orelse appt_type;
    }
    try mapper.appointment_type.toResponse(appt_type, data);
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const appt_type_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteAppointmentType(appt_type_id);
    var root = data.value.?;
    var include_inactive: bool = false;
    const params = try request.params();
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_appt_types = try data.array();
    try root.put("setup_items", json_appt_types);
    const appt_type_lookups = try db_context.lookupAppointmentTypes(include_inactive);
    defer appt_type_lookups.deinit();
    for (appt_type_lookups.items) |appt_type_lookup| {
        var json_appt_type = try data.object();
        try json_appt_type.put("id", data.integer(appt_type_lookup.id));
        try json_appt_type.put("name", data.string(appt_type_lookup.name));
        try json_appt_type.put("active", data.boolean(appt_type_lookup.active));
        try json_appt_types.append(json_appt_type);
    }
    return request.render(.ok);
}
