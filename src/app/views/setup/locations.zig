const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
const Location = @import("../../models/location.zig");
const log = std.log.scoped(.locations);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    var root = data.value.?;
    try root.put("page_title", data.string("Location Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_locations", data.string("class=\"current\""));
    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_locations = try data.array();
    try root.put("setup_items", json_locations);

    const locations = try db_context.lookupLocations(include_inactive);
    defer locations.deinit();
    for (locations.items) |loc| {
        var json_loc = try data.object();
        try json_loc.put("id", data.integer(loc.id));
        try json_loc.put("active", data.boolean(loc.active));
        try json_loc.put("name", data.string(loc.name));
        try json_locations.append(json_loc);
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
        const active = params.getT(.boolean, "active") orelse false;
        const phone = params.getT(.string, "phone") orelse "";
        const address_1 = params.getT(.string, "address_1") orelse "";
        const address_2 = params.getT(.string, "address_2") orelse "";
        const city = params.getT(.string, "city") orelse "";
        const state = params.getT(.string, "state") orelse "";
        const zip_code = params.getT(.string, "zip_code") orelse "";
        if (selected_id == 0) {
            selected_id = try db_context.createLocation(name, phone, address_1, address_2, city, state, zip_code, current_bro_id);
            log.info("Created new Location with ID {d}", .{selected_id});
        } else {
            try db_context.updateLocation(selected_id, active, name, phone, address_1, address_2, city, state, zip_code, current_bro_id);
        }
    }

    var root = data.value.?;

    var include_inactive: bool = false;
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));

    const json_locs = try data.array();
    try root.put("setup_items", json_locs);
    const loc_lookups = try db_context.lookupLocations(include_inactive);
    defer loc_lookups.deinit();
    for (loc_lookups.items) |loc_lookup| {
        var json_loc = try data.object();
        try json_loc.put("id", data.integer(loc_lookup.id));
        try json_loc.put("name", data.string(loc_lookup.name));
        try json_loc.put("active", data.boolean(loc_lookup.active));
        try json_loc.put("selected", data.string(if (loc_lookup.id == selected_id) "selected" else ""));
        try json_locs.append(json_loc);
        if (loc_lookup.id == selected_id) {
            const location = try db_context.getLocation(selected_id) orelse return error.DatabaseError;
            try root.put("id", data.integer(location.id));
            try root.put("name", data.string(location.name));
            try root.put("active", data.boolean(location.active));
            try root.put("active_check", data.string(if (location.active) "checked" else ""));
            try root.put("phone", data.string(location.phone));
            try root.put("address_1", data.string(location.address_1));
            try root.put("address_2", data.string(location.address_2));
            try root.put("city", data.string(location.city));
            try root.put("state", data.string(location.state));
            try root.put("zip_code", data.string(location.zip_code));
            try root.put("date_created", data.string(location.date_created));
            try root.put("date_updated", data.string(location.date_updated));
            try root.put("created_by", data.string(location.created_by orelse "System"));
            try root.put("updated_by", data.string(location.updated_by orelse "System"));
        }
    }

    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const location_id = try std.fmt.parseInt(i32, id, 10);

    var location = Location{
        .id = 0,
        .name = "",
        .active = true,
        .phone = "",
        .address_1 = "",
        .address_2 = "",
        .city = "",
        .state = "",
        .zip_code = "",
        .date_created = "",
        .date_updated = "",
        .created_by = "",
        .updated_by = "",
    };
    if (location_id > 0) {
        location = try db_context.getLocation(location_id) orelse location;
    }
    var root = data.value.?;
    try root.put("id", data.integer(location.id));
    try root.put("name", data.string(location.name));
    try root.put("active", data.boolean(location.active));
    try root.put("active_check", data.string(if (location.active) "checked" else ""));
    try root.put("phone", data.string(location.phone));
    try root.put("address_1", data.string(location.address_1));
    try root.put("address_2", data.string(location.address_2));
    try root.put("city", data.string(location.city));
    try root.put("state", data.string(location.state));
    try root.put("zip_code", data.string(location.zip_code));
    try root.put("date_created", data.string(location.date_created));
    try root.put("date_updated", data.string(location.date_updated));
    try root.put("created_by", data.string(location.created_by orelse "System"));
    try root.put("updated_by", data.string(location.updated_by orelse "System"));
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var db_context = DbContext.init(request.allocator, request.server.database);
    defer db_context.deinit();
    const loc_id = try std.fmt.parseInt(i32, id, 10);
    _ = try db_context.deleteLocation(loc_id);
    var root = data.value.?;
    var include_inactive: bool = false;
    const params = try request.params();
    if (params.getT(.boolean, "include_inactive")) |incl_inactive| {
        include_inactive = incl_inactive;
    }
    try root.put("include_inactive", data.string(if (include_inactive) "checked" else ""));
    const json_locs = try data.array();
    try root.put("setup_items", json_locs);
    const loc_lookups = try db_context.lookupLocations(include_inactive);
    defer loc_lookups.deinit();
    for (loc_lookups.items) |loc_lookup| {
        var json_loc = try data.object();
        try json_loc.put("id", data.integer(loc_lookup.id));
        try json_loc.put("name", data.string(loc_lookup.name));
        try json_loc.put("active", data.boolean(loc_lookup.active));
        try json_locs.append(json_loc);
    }
    return request.render(.ok);
}
