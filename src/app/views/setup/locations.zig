const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Location = @import("../../models/location.zig");
const mapper = @import("../../mapper.zig");
const util = @import("util.zig");
const log = std.log.scoped(.locations);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    var root = data.value.?;
    try root.put("page_title", data.string("Location Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_locations", data.string("class=\"current\""));
    return try util.renderSetupList(request, data, &db_context, "Location", 0);
}
pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    var location = try mapper.location.fromRequest(request);
    if (location.id == 0) {
        location.id = try db_context.createLocation(location, current_bro_id);
    } else {
        try db_context.updateLocation(location, current_bro_id);
    }
    try db_context.deinit();
    db_context = try DbContext.init(request.allocator, request.server.database);
    return try util.renderSetupList(request, data, &db_context, "Location", location.id);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const location_id = try std.fmt.parseInt(i32, id, 10);

    var location = Location{};
    if (location_id > 0) {
        location = try db_context.getLocation(location_id) orelse location;
    }
    try mapper.location.toResponse(location, data);
    try db_context.deinit();
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const location_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteLocation(location_id);
    return try util.renderSetupList(request, data, &db_context, "Location", 0);
}
