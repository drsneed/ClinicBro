const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const mapper = @import("../../mapper.zig");
const util = @import("util.zig");
const AppointmentStatus = @import("../../models/appointment_status.zig");
const log = std.log.scoped(.appointment_statuses);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    var root = data.value.?;
    try root.put("page_title", data.string("Appointment Type Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_appointment_statuses", data.string("class=\"current\""));
    return try util.renderSetupList(request, data, &db_context, "AppointmentStatus", 0);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    var appointment_status = try mapper.appointment_status.fromRequest(request);
    if (appointment_status.id == 0) {
        appointment_status.id = try db_context.createAppointmentStatus(appointment_status, current_bro_id);
    } else {
        try db_context.updateAppointmentStatus(appointment_status, current_bro_id);
    }
    try db_context.deinit();
    db_context = try DbContext.init(request.allocator, request.server.database);
    return try util.renderSetupList(request, data, &db_context, "AppointmentStatus", appointment_status.id);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const appt_status_id = try std.fmt.parseInt(i32, id, 10);

    var appt_status = AppointmentStatus{};
    if (appt_status_id > 0) {
        appt_status = try db_context.getAppointmentStatus(appt_status_id) orelse appt_status;
    }
    try mapper.appointment_status.toResponse(appt_status, data);
    try db_context.deinit();
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const appt_status_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteAppointmentStatus(appt_status_id);
    return try util.renderSetupList(request, data, &db_context, "AppointmentStatus", 0);
}
