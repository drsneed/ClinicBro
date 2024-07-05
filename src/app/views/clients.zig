const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../db_context.zig");
const Client = @import("../models/client.zig");
const log = std.log.scoped(.clients);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    const json_clients = try data.array();
    var root = data.value.?;
    try root.put("clients", json_clients);
    const clients = try db_context.lookupRecentClients(current_bro_id);
    defer clients.deinit();
    for (clients.items) |client| {
        var json_client = try data.object();
        try json_client.put("id", data.integer(client.id));
        try json_client.put("active", data.boolean(client.active));
        try json_client.put("name", data.string(client.name));
        try json_client.put("selected", data.string(""));
        try json_clients.append(json_client);
    }
    return request.render(.ok);
}
pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const client_id = try std.fmt.parseInt(i32, id, 10);
    if (std.mem.eql(u8, id, "recent")) {} else {}

    var client = Client{};
    if (client_id > 0) {
        client = try db_context.getClient(client_id) orelse client;
    }
    var root = data.value.?;
    try root.put("id", data.integer(client.id));
    try root.put("first_name", data.string(client.first_name));
    try root.put("middle_name", data.string(client.middle_name));
    try root.put("last_name", data.string(client.last_name));
    try root.put("active", data.boolean(client.active));
    try root.put("active_check", data.string(if (client.active) "checked" else ""));
    try root.put("date_of_birth", data.string(client.date_of_birth orelse ""));
    try root.put("phone", data.string(client.phone));
    try root.put("email", data.string(client.email));
    try root.put("can_call", data.boolean(client.can_call));
    try root.put("can_text", data.boolean(client.can_text));
    try root.put("can_email", data.boolean(client.can_email));
    try root.put("address_1", data.string(client.address_1));
    try root.put("address_2", data.string(client.address_2));
    try root.put("city", data.string(client.city));
    try root.put("state", data.string(client.state));
    try root.put("zip_code", data.string(client.zip_code));
    try root.put("date_created", data.string(client.date_created));
    try root.put("date_updated", data.string(client.date_updated));
    try root.put("created_by", data.string(client.created_by orelse "System"));
    try root.put("updated_by", data.string(client.updated_by orelse "System"));

    const json_locations = try data.array();
    try root.put("locations", json_locations);
    const locations = try db_context.lookupLocations(false);
    defer locations.deinit();
    for (locations.items) |loc| {
        var json_loc = try data.object();
        try json_loc.put("id", data.integer(loc.id));
        try json_loc.put("active", data.boolean(loc.active));
        try json_loc.put("name", data.string(loc.name));
        try json_loc.put("selected", data.string(if (client.location_id == loc.id) "selected" else ""));
        try json_locations.append(json_loc);
    }

    const json_bros = try data.array();
    try root.put("bros", json_bros);
    const bros = try db_context.lookupProviderBros(false);
    defer bros.deinit();
    for (bros.items) |bro| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro.id));
        try json_bro.put("active", data.boolean(bro.active));
        try json_bro.put("name", data.string(bro.name));
        try json_bro.put("selected", data.string(if (client.bro_id == bro.id) "selected" else ""));
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
        const active = params.getT(.boolean, "active") orelse false;
        const first_name = params.getT(.string, "first_name") orelse return error.MissingParam;
        const middle_name = params.getT(.string, "middle_name") orelse "";
        const last_name = params.getT(.string, "last_name") orelse return error.MissingParam;
        var date_of_birth = params.getT(.string, "date_of_birth");
        const phone = params.getT(.string, "phone") orelse "";
        const email = params.getT(.string, "email") orelse "";
        const address_1 = params.getT(.string, "address_1") orelse "";
        const address_2 = params.getT(.string, "address_2") orelse "";
        const city = params.getT(.string, "city") orelse "";
        const state = params.getT(.string, "state") orelse "";
        const zip_code = params.getT(.string, "zip_code") orelse "";
        //const notes = params.getT(.string, "notes") orelse "";
        const can_call = params.getT(.boolean, "can_call") orelse false;
        const can_text = params.getT(.boolean, "can_call") orelse false;
        const can_email = params.getT(.boolean, "can_call") orelse false;
        const location_id = params.getT(.integer, "location_id") orelse 0;
        const bro_id = params.getT(.integer, "bro_id") orelse 0;

        if (date_of_birth) |dob| {
            if (dob.len == 0) {
                date_of_birth = null;
            }
        }

        if (selected_id == 0) {
            selected_id = try db_context.createClient(
                first_name,
                middle_name,
                last_name,
                date_of_birth,
                email,
                phone,
                address_1,
                address_2,
                city,
                state,
                zip_code,
                "",
                can_call,
                can_text,
                can_email,
                @intCast(location_id),
                @intCast(bro_id),
                current_bro_id,
            );
            log.info("Created new Client with ID {d}", .{selected_id});
        } else {
            try db_context.updateClient(
                selected_id,
                active,
                first_name,
                middle_name,
                last_name,
                date_of_birth,
                null,
                email,
                phone,
                address_1,
                address_2,
                city,
                state,
                zip_code,
                "",
                can_call,
                can_text,
                can_email,
                @intCast(location_id),
                @intCast(bro_id),
                current_bro_id,
            );
        }
    }
    var id_buffer: [8]u8 = undefined;
    const id_str = try std.fmt.bufPrint(&id_buffer, "{d}", .{selected_id});
    return get(id_str, request, data);
}

pub fn put(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn patch(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const client_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteClient(client_id);
    return request.render(.ok);
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/clients", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/clients", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/clients/example-id", .{});
    try response.expectStatus(.ok);
}
