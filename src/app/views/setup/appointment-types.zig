const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const mapper = @import("../../mapper.zig");
const util = @import("util.zig");
const AppointmentType = @import("../../models/appointment_type.zig");
const log = std.log.scoped(.locations);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    try root.put("page_title", data.string("Appointment Type Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_appointment_types", data.string("class=\"current\""));
    return try util.renderSetupList(request, data, &db_context, "AppointmentType", 0);
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
    return try util.renderSetupList(request, data, &db_context, "AppointmentType", appointment_type.id);
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
    return try util.renderSetupList(request, data, &db_context, "AppointmentType", 0);
}
