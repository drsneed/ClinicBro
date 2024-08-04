const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../db_context.zig");
const mapper = @import("../mapper.zig");
const AppointmentView = @import("../models/appointment_view.zig");
const log = std.log.scoped(.appointment_details);

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const appt_id = try std.fmt.parseInt(i32, id, 10);
    var appointment = AppointmentView{};
    if (appt_id > 0) {
        appointment = try db_context.getAppointmentView(appt_id) orelse appointment;
    }
    try mapper.appointment_view.toResponse(appointment, data);
    try db_context.deinit();
    try request.response.headers.append("HX-Retarget", "global #appointment-details");
    return request.render(.ok);
}
