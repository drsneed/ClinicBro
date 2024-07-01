const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Bro = @import("../../models/domain/bro.zig");
const log = std.log.scoped(.bros);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    try root.put("page_title", data.string("User Setup"));
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
        var current_bro_id: i32 = 0;
        if (try session.get("bro")) |bro_session| {
            current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
        }
        if (params.getT(.string, "name")) |name| {
            if (selected_id == 0) {
                selected_id = try db_context.createBro(.{ .updated_bro_id = current_bro_id, .name = name });
                log.info("Created new Bro with ID {d}", .{selected_id});
            } else {
                _ = try db_context.updateBro(.{ .id = selected_id, .updated_bro_id = current_bro_id, .name = name });
            }
        } else {
            log.info("missing param name. Params = {any}", .{params});
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

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const bro_id = try std.fmt.parseInt(i32, id, 10);

    var bro = Bro{
        .id = 0,
        .name = "",
        .active = true,
        .sees_clients = false,
        .color = 0,
        .date_created = "",
        .date_updated = "",
        .created_by = "",
        .updated_by = "",
    };
    if (bro_id > 0) {
        bro = try db_context.getBro(bro_id) orelse bro;
    }
    var root = data.value.?;
    try root.put("id", data.integer(bro.id));
    try root.put("name", data.string(bro.name));
    try root.put("date_created", data.string(bro.date_created));
    try root.put("date_updated", data.string(bro.date_updated));
    try root.put("created_by", data.string(bro.created_by orelse "System"));
    try root.put("updated_by", data.string(bro.updated_by orelse "System"));
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const bro_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteBro(bro_id);
    var root = data.value.?;
    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bro_items = try db_context.getBroItems(false);
    defer bro_items.deinit();
    for (bro_items.items) |bro_item| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro_item.id));
        try json_bro.put("name", data.string(bro_item.name));
        try json_bros.append(json_bro);
    }
    return request.render(.ok);
}
