const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Bro = @import("../../models/bro.zig");
const log = std.log.scoped(.bros);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    try root.put("page_title", data.string("User Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_users", data.string("class=\"current\""));
    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_bros = try data.array();
    try root.put("bros", json_bros);

    const bros = try db_context.lookupBros(include_inactive);
    defer bros.deinit();
    for (bros.items) |bro| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro.id));
        try json_bro.put("name", data.string(bro.name));
        try json_bro.put("active", data.boolean(bro.active));
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
        const name = params.getT(.string, "name") orelse return error.MissingParam;
        const sees_clients = params.getT(.boolean, "sees_clients") orelse false;
        if (selected_id == 0) {
            selected_id = try db_context.createBro(current_bro_id, name, sees_clients);
            log.info("Created new Bro with ID {d}", .{selected_id});
        } else {
            _ = try db_context.updateBro(
                selected_id,
                name,
                params.getT(.boolean, "active") orelse false,
                sees_clients,
                current_bro_id,
            );
        }
    }

    var root = data.value.?;

    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));

    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bro_lookups = try db_context.lookupBros(include_inactive);
    defer bro_lookups.deinit();
    for (bro_lookups.items) |bro_lookup| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro_lookup.id));
        try json_bro.put("name", data.string(bro_lookup.name));
        try json_bro.put("active", data.boolean(bro_lookup.active));
        try json_bro.put("selected", data.string(if (bro_lookup.id == selected_id) "selected" else ""));
        try json_bros.append(json_bro);
        if (bro_lookup.id == selected_id) {
            const bro = try db_context.getBro(selected_id) orelse return error.DatabaseError;
            try root.put("id", data.integer(bro.id));
            try root.put("name", data.string(bro.name));
            try root.put("active", data.boolean(bro.active));
            try root.put("active_check", data.string(if (bro.active) "checked" else ""));
            try root.put("sees_clients_check", data.string(if (bro.sees_clients) "checked" else ""));
            try root.put("date_created", data.string(bro.date_created));
            try root.put("date_updated", data.string(bro.date_updated));
            try root.put("created_by", data.string(bro.created_by orelse "System"));
            try root.put("updated_by", data.string(bro.updated_by orelse "System"));
        }
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
    try root.put("active", data.boolean(bro.active));
    try root.put("active_check", data.string(if (bro.active) "checked" else ""));
    try root.put("sees_clients_check", data.string(if (bro.sees_clients) "checked" else ""));
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
    var include_inactive: bool = false;
    const params = try request.params();
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bro_lookups = try db_context.lookupBros(include_inactive);
    defer bro_lookups.deinit();
    for (bro_lookups.items) |bro_lookup| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro_lookup.id));
        try json_bro.put("name", data.string(bro_lookup.name));
        try json_bro.put("active", data.boolean(bro_lookup.active));
        try json_bros.append(json_bro);
    }
    return request.render(.ok);
}
