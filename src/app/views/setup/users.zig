const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const log = std.log.scoped(.bros);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    if (params.getT(.integer, "id")) |bro_id| {
        const bro = try db_context.getBro(@intCast(bro_id)) orelse return request.render(.not_found);
        //log.info("Got bro {any} from database", .{bro});

        try root.put("id", data.integer(bro.id));
        try root.put("name", data.string(bro.name));
        try root.put("date_created", data.string(bro.date_created));
        try root.put("date_updated", data.string(bro.date_updated));
        try root.put("created_by", data.string(bro.created_by orelse "System"));
        try root.put("updated_by", data.string(bro.updated_by orelse "System"));
        return request.render(.ok);
    }
    try root.put("page_title", data.string("Bro Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_users", data.string("class=\"current\""));
    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bros = try db_context.getBroItems(false);
    defer bros.deinit();
    for (bros.items) |bro| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro.id));
        try json_bro.put("name", data.string(bro.name));
        try json_bros.append(json_bro);
    }
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var selected_id: i32 = 0;
    if (params.getT(.integer, "id")) |id| {
        selected_id = @intCast(id);
        const session = try request.session();
        var updated_bro_id: i32 = 0;
        if (try session.get("bro")) |bro_session| {
            updated_bro_id = @intCast(bro_session.getT(.integer, "id").?);
        }
        if (params.getT(.string, "name")) |name| {
            log.info("Trying to update bro with id {d} to {s}", .{ id, name });
            _ = try db_context.updateBro(.{ .id = selected_id, .updated_bro_id = updated_bro_id, .name = name });
        }
    }

    const bro = try db_context.getBro(selected_id) orelse return request.redirect("/", .found);
    var root = data.value.?;
    try root.put("id", data.integer(bro.id));
    try root.put("name", data.string(bro.name));
    try root.put("date_created", data.string(bro.date_created));
    try root.put("date_updated", data.string(bro.date_updated));
    try root.put("created_by", data.string(bro.created_by orelse "System"));
    try root.put("updated_by", data.string(bro.updated_by orelse "System"));
    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bro_items = try db_context.getBroItems(false);
    defer bro_items.deinit();
    for (bro_items.items) |bro_item| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro_item.id));
        try json_bro.put("name", data.string(bro_item.name));
        try json_bro.put("selected", data.string(if (bro_item.id == selected_id) "selected" else ""));
        try json_bros.append(json_bro);
    }

    return request.render(.ok);
}
