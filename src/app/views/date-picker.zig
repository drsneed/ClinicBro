const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../db_context.zig");
const mapper = @import("../mapper.zig");
const AppointmentDate = @import("../models/appointment_date.zig");
const log = std.log.scoped(.appointment_details);

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    const from = params.getT(.string, "from");
    const to = params.getT(.string, "to");
    if (from != null and to != null) {
        var db_context = try DbContext.init(request.allocator, request.server.database);
        const dates = try db_context.getAppointmentDates2(from.?, to.?);
        defer dates.deinit();
        var root = data.value.?;
        const json_dates = try data.array();
        try root.put("dates", json_dates);
        for (dates.items) |date| {
            var json_appt_date = try data.object();
            try json_appt_date.put("date", data.string(date.date));
            try json_dates.append(json_appt_date);
        }
        try db_context.deinit();
    }

    return request.render(.ok);
}
