const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Bro = @import("../../models/bro.zig");
const Location = @import("../../models/location.zig");
const AppointmentType = @import("../../models/appointment_type.zig");
const mapper = @import("../../mapper.zig");
const log = std.log.scoped(.util);

pub fn renderSetupList(request: *jetzig.Request, data: *jetzig.Data, db_context: *DbContext, table_name: []const u8, selected_item_id: i32) !jetzig.View {
    const params = try request.params();
    var root = data.value.?;
    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const setup_items = try data.array();
    try root.put("setup_items", setup_items);
    log.info("attempting lookup for {s}", .{table_name});
    const db_items = try db_context.lookupItems(table_name, include_inactive);
    defer db_items.deinit();

    for (db_items.items) |db_item| {
        var setup_item = try data.object();
        try setup_item.put("id", data.integer(db_item.id));
        try setup_item.put("name", data.string(db_item.name));
        try setup_item.put("active", data.boolean(db_item.active));
        try setup_item.put("selected", data.string(if (db_item.id == selected_item_id) "selected" else ""));
        try setup_items.append(setup_item);
        if (db_item.id == selected_item_id) {
            if (std.mem.eql(u8, table_name, "Bro")) {
                const bro = try db_context.getBro(selected_item_id) orelse Bro{};
                try mapper.bro.toResponse(bro, data);
            } else if (std.mem.eql(u8, table_name, "Location")) {
                const location = try db_context.getLocation(selected_item_id) orelse Location{};
                try mapper.location.toResponse(location, data);
            } else if (std.mem.eql(u8, table_name, "AppointmentType")) {
                const appointment_type = try db_context.getAppointmentType(selected_item_id) orelse AppointmentType{};
                try mapper.appointment_type.toResponse(appointment_type, data);
            }
        }
    }
    return request.render(.ok);
}
