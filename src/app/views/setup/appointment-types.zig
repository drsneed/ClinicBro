const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const mapper = @import("../../mapper.zig");
const util = @import("util.zig");
const AppointmentType = @import("../../models/appointment_type.zig");
const log = std.log.scoped(.locations);
pub const layout = "app";

const appointment_type_single_query = @embedFile("../../../sql/appointment_type_single.sql");
const appointment_type_insert_query = @embedFile("../../../sql/appointment_type_insert.sql");
const appointment_type_update_query = @embedFile("../../../sql/appointment_type_update.sql");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    var root = data.value.?;
    try root.put("page_title", data.string("Appointment Type Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_appointment_types", data.string("class=\"current\""));
    return try util.renderSetupList(request, data, &db_context, "AppointmentType", 0);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    // open db connection
    var conn = try request.server.database.pool.acquire();
    defer conn.release();

    var appointment_type = try mapper.appointment_type.fromRequest(request);
    log.info("appt type = {s}", .{appointment_type.description});
    if (appointment_type.id == 0) {
        // active is not a form field on a new entry, so it defaults to false further down if we don't set it properly here
        appointment_type.active = true;
        var row = (try conn.row(appointment_type_insert_query, .{
            appointment_type.name,
            appointment_type.description,
            appointment_type.color,
            current_bro_id,
        })) orelse unreachable;
        defer row.deinit() catch {};
        appointment_type.id = row.get(i32, 0);
    } else {
        _ = conn.exec(appointment_type_update_query, .{
            appointment_type.id,
            appointment_type.active,
            appointment_type.name,
            appointment_type.description,
            appointment_type.color,
            current_bro_id,
        }) catch |err| {
            if (conn.err) |pg_err| {
                log.err("update failure: {s}", .{pg_err.message});
            }
            return err;
        };
    }
    if (try util.renderSetupList2(request, data, conn, "AppointmentType", appointment_type.id)) {
        try mapper.appointment_type.toResponse(appointment_type, data);
    }
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const appointment_type_id = try std.fmt.parseInt(i32, id, 10);
    if (appointment_type_id > 0) {
        var row = (try request.server.database.pool.rowOpts(appointment_type_single_query, .{appointment_type_id}, .{ .column_names = true })) orelse unreachable;
        defer row.deinit() catch {};
        const appointment_type = try row.to(AppointmentType, .{});
        try mapper.appointment_type.toResponse(appointment_type, data);
    } else {
        const appointment_type = AppointmentType{};
        try mapper.appointment_type.toResponse(appointment_type, data);
    }
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const appt_type_id = try std.fmt.parseInt(i32, id, 10);
    var conn = try request.server.database.pool.acquire();
    defer conn.release();
    if (appt_type_id > 0) {
        _ = try conn.exec("delete from AppointmentType where id=$1", .{appt_type_id});
    }
    _ = try util.renderSetupList2(request, data, conn, "AppointmentType", 0);
    return request.render(.ok);
}
