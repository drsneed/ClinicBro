const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../db_context.zig");
const mapper = @import("../mapper.zig");
const Client = @import("../models/client.zig");
const log = std.log.scoped(.clients);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
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
    try db_context.deinit();
    return request.render(.ok);
}
pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const client_id = try std.fmt.parseInt(i32, id, 10);
    var client = Client{};
    if (client_id > 0) {
        client = try db_context.getClient(client_id) orelse client;
    }
    try mapper.client.toResponse(client, data);
    var root = data.value.?;
    const json_locations = try data.array();
    try root.put("locations", json_locations);
    const locations = try db_context.lookupLocations(false);
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
    try db_context.deinit();
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const session = try request.session();
    var current_bro_id: i32 = 0;
    if (try session.get("bro")) |bro_session| {
        current_bro_id = @intCast(bro_session.getT(.integer, "id").?);
    }
    log.info("attempting to map fields from request", .{});
    var client = try mapper.client.fromRequest(request);
    if (client.id == 0) {
        client.id = try db_context.createClient(client, current_bro_id);
        try db_context.addRecentClient(current_bro_id, client.id);
    } else {
        try db_context.updateClient(client, current_bro_id);
    }

    const json_clients = try data.array();
    var root = data.value.?;
    try root.put("clients", json_clients);
    const recent_clients = try db_context.lookupRecentClients(current_bro_id);
    defer recent_clients.deinit();
    for (recent_clients.items) |recent_client| {
        var json_client = try data.object();
        try json_client.put("id", data.integer(recent_client.id));
        try json_client.put("active", data.boolean(recent_client.active));
        try json_client.put("name", data.string(recent_client.name));
        try json_client.put("selected", data.string(if (recent_client.id == client.id) "active" else ""));
        try json_clients.append(json_client);
    }
    try db_context.deinit();
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    var db_context = try DbContext.init(request.allocator, request.server.database);
    const client_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteClient(client_id);
    try db_context.deinit();
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
