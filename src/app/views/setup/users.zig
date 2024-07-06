const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Bro = @import("../../models/bro.zig");
const mapper = @import("../../mapper.zig");
const util = @import("util.zig");
const log = std.log.scoped(.bros);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("User Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_users", data.string("class=\"current\""));
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    return try util.renderSetupList(request, data, &db_context, "Bro", 0);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    var bro = try mapper.bro.fromRequest(request);
    if (bro.id == 0) {
        bro.id = try db_context.createBro(bro, current_bro_id);
    } else {
        try db_context.updateBro(bro, current_bro_id);
    }

    return try util.renderSetupList(request, data, &db_context, "Bro", bro.id);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const bro_id = try std.fmt.parseInt(i32, id, 10);

    var bro = Bro{};
    if (bro_id > 0) {
        bro = try db_context.getBro(bro_id) orelse bro;
    }
    try mapper.bro.toResponse(bro, data);
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const bro_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteBro(bro_id);
    return try util.renderSetupList(request, data, &db_context, "Bro", 0);
}
