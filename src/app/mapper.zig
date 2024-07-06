const std = @import("std");
const jetzig = @import("jetzig");
const Bro = @import("models/bro.zig");
const Location = @import("models/location.zig");
const Client = @import("models/client.zig");
const AppointmentType = @import("models/appointment_type.zig");
const AppointmentStatus = @import("models/appointment_status.zig");
const log = std.log.scoped(.mapper);

pub const bro = struct {
    pub fn fromRequest(request: *jetzig.http.Request) !Bro {
        var model = Bro{};
        const params = try request.params();
        model.id = @intCast(params.getT(.integer, "id") orelse 0);
        model.active = params.getT(.boolean, "active") orelse false;
        model.name = params.getT(.string, "name") orelse return error.MissingParam;
        model.color = params.getT(.string, "color") orelse "";
        model.sees_clients = params.getT(.boolean, "sees_clients") orelse false;
        return model;
    }
    pub fn toResponse(model: Bro, data: *jetzig.Data) !void {
        var root = data.value.?;
        try root.put("id", data.integer(model.id));
        try root.put("name", data.string(model.name));
        try root.put("active", data.boolean(model.active));
        try root.put("active_check", data.string(if (model.active) "checked" else ""));
        try root.put("color", data.string(model.color));
        try root.put("sees_clients_check", data.string(if (model.sees_clients) "checked" else ""));
        try root.put("date_created", data.string(model.date_created));
        try root.put("date_updated", data.string(model.date_updated));
        try root.put("created_by", data.string(model.created_by orelse "System"));
        try root.put("updated_by", data.string(model.updated_by orelse "System"));
    }
    pub fn fromDatabase(row: jetzig.http.Database.pg.Row) Bro {
        return .{
            .id = row.get(i32, 0),
            .active = row.get(bool, 1),
            .name = row.get([]const u8, 2),
            .color = row.get([]const u8, 3),
            .sees_clients = row.get(bool, 4),
            .date_created = row.get([]const u8, 5),
            .date_updated = row.get([]const u8, 6),
            .created_by = row.get(?[]const u8, 7),
            .updated_by = row.get(?[]const u8, 8),
        };
    }
};

pub const location = struct {
    pub fn toResponse(model: Location, data: *jetzig.Data) !void {
        var root = data.value.?;
        try root.put("id", data.integer(model.id));
        try root.put("name", data.string(model.name));
        try root.put("active", data.boolean(model.active));
        try root.put("active_check", data.string(if (model.active) "checked" else ""));
        try root.put("phone", data.string(model.phone));
        try root.put("address_1", data.string(model.address_1));
        try root.put("address_2", data.string(model.address_2));
        try root.put("city", data.string(model.city));
        try root.put("state", data.string(model.state));
        try root.put("zip_code", data.string(model.zip_code));
        try root.put("date_created", data.string(model.date_created));
        try root.put("date_updated", data.string(model.date_updated));
        try root.put("created_by", data.string(model.created_by orelse "System"));
        try root.put("updated_by", data.string(model.updated_by orelse "System"));
    }
    pub fn fromRequest(request: *jetzig.http.Request) !Location {
        var model = Location{};
        const params = try request.params();
        model.name = params.getT(.string, "name") orelse return error.MissingParam;
        model.active = params.getT(.boolean, "active") orelse false;
        model.phone = params.getT(.string, "phone") orelse "";
        model.address_1 = params.getT(.string, "address_1") orelse "";
        model.address_2 = params.getT(.string, "address_2") orelse "";
        model.city = params.getT(.string, "city") orelse "";
        model.state = params.getT(.string, "state") orelse "";
        model.zip_code = params.getT(.string, "zip_code") orelse "";
        return model;
    }
    pub fn fromDatabase(row: jetzig.http.Database.pg.Row) Location {
        return .{
            .id = row.get(i32, 0),
            .active = row.get(bool, 1),
            .name = row.get([]const u8, 2),
            .phone = row.get([]const u8, 3),
            .address_1 = row.get([]const u8, 4),
            .address_2 = row.get([]const u8, 5),
            .city = row.get([]const u8, 6),
            .state = row.get([]const u8, 7),
            .zip_code = row.get([]const u8, 8),
            .date_created = row.get([]const u8, 9),
            .date_updated = row.get([]const u8, 10),
            .created_by = row.get(?[]const u8, 11),
            .updated_by = row.get(?[]const u8, 12),
        };
    }
};

pub const client = struct {
    pub fn fromRequest(request: *jetzig.http.Request) !Client {
        var model = Client{};
        const params = try request.params();
        model.id = @intCast(params.getT(.integer, "id") orelse 0);
        model.active = params.getT(.boolean, "active") orelse false;
        model.first_name = params.getT(.string, "first_name") orelse return error.MissingParam;
        model.middle_name = params.getT(.string, "middle_name") orelse "";
        model.last_name = params.getT(.string, "last_name") orelse return error.MissingParam;
        model.date_of_birth = params.getT(.string, "date_of_birth");
        if (model.date_of_birth) |dob| {
            if (dob.len == 0) model.date_of_birth = null;
        }
        model.phone = params.getT(.string, "phone") orelse "";
        model.email = params.getT(.string, "email") orelse "";
        model.address_1 = params.getT(.string, "address_1") orelse "";
        model.address_2 = params.getT(.string, "address_2") orelse "";
        model.city = params.getT(.string, "city") orelse "";
        model.state = params.getT(.string, "state") orelse "";
        model.zip_code = params.getT(.string, "zip_code") orelse "";
        //model.notes = params.getT(.string, "notes") orelse "";
        model.can_call = params.getT(.boolean, "can_call") orelse false;
        model.can_text = params.getT(.boolean, "can_call") orelse false;
        model.can_email = params.getT(.boolean, "can_call") orelse false;
        model.location_id = @intCast(params.getT(.integer, "location_id") orelse 0);
        model.bro_id = @intCast(params.getT(.integer, "bro_id") orelse 0);
        return model;
    }
    pub fn toResponse(model: Client, data: *jetzig.Data) !void {
        var root = data.value.?;
        try root.put("id", data.integer(model.id));
        try root.put("first_name", data.string(model.first_name));
        try root.put("middle_name", data.string(model.middle_name));
        try root.put("last_name", data.string(model.last_name));
        try root.put("active", data.boolean(model.active));
        try root.put("active_check", data.string(if (model.active) "checked" else ""));
        try root.put("date_of_birth", data.string(model.date_of_birth orelse ""));
        try root.put("phone", data.string(model.phone));
        try root.put("email", data.string(model.email));
        try root.put("can_call", data.boolean(model.can_call));
        try root.put("can_text", data.boolean(model.can_text));
        try root.put("can_email", data.boolean(model.can_email));
        try root.put("address_1", data.string(model.address_1));
        try root.put("address_2", data.string(model.address_2));
        try root.put("city", data.string(model.city));
        try root.put("state", data.string(model.state));
        try root.put("zip_code", data.string(model.zip_code));
        try root.put("date_created", data.string(model.date_created));
        try root.put("date_updated", data.string(model.date_updated));
        try root.put("created_by", data.string(model.created_by orelse "System"));
        try root.put("updated_by", data.string(model.updated_by orelse "System"));
    }
    pub fn fromDatabase(row: jetzig.http.Database.pg.Row) Client {
        return .{
            .id = row.get(i32, 0),
            .active = row.get(bool, 1),
            .first_name = row.get([]const u8, 2),
            .middle_name = row.get([]const u8, 3),
            .last_name = row.get([]const u8, 4),
            .date_of_birth = row.get(?[]const u8, 5),
            .date_of_death = row.get(?[]const u8, 6),
            .email = row.get([]const u8, 7),
            .phone = row.get([]const u8, 8),
            .address_1 = row.get([]const u8, 9),
            .address_2 = row.get([]const u8, 10),
            .city = row.get([]const u8, 11),
            .state = row.get([]const u8, 12),
            .zip_code = row.get([]const u8, 13),
            .notes = row.get([]const u8, 14),
            .can_call = row.get(bool, 15),
            .can_text = row.get(bool, 16),
            .can_email = row.get(bool, 17),
            .location_id = row.get(i32, 18),
            .bro_id = row.get(i32, 19),
            .date_created = row.get([]const u8, 20),
            .date_updated = row.get([]const u8, 21),
            .created_by = row.get(?[]const u8, 22),
            .updated_by = row.get(?[]const u8, 23),
        };
    }
};

pub const appointment_type = struct {
    pub fn fromRequest(request: *jetzig.http.Request) !AppointmentType {
        var model = AppointmentType{};
        const params = try request.params();
        model.id = @intCast(params.getT(.integer, "id") orelse 0);
        model.active = params.getT(.boolean, "active") orelse false;
        model.name = params.getT(.string, "name") orelse return error.MissingParam;
        model.abbreviation = params.getT(.string, "abbreviation") orelse "";
        model.color = params.getT(.string, "color") orelse "";
        return model;
    }
    pub fn toResponse(model: AppointmentType, data: *jetzig.Data) !void {
        var root = data.value.?;
        try root.put("id", data.integer(model.id));
        try root.put("name", data.string(model.name));
        try root.put("abbreviation", data.string(model.abbreviation));
        try root.put("active", data.boolean(model.active));
        try root.put("active_check", data.string(if (model.active) "checked" else ""));
        try root.put("color", data.string(model.color));
        try root.put("date_created", data.string(model.date_created));
        try root.put("date_updated", data.string(model.date_updated));
        try root.put("created_by", data.string(model.created_by orelse "System"));
        try root.put("updated_by", data.string(model.updated_by orelse "System"));
    }
    pub fn fromDatabase(row: jetzig.http.Database.pg.Row) AppointmentType {
        return .{
            .id = row.get(i32, 0),
            .active = row.get(bool, 1),
            .name = row.get([]const u8, 2),
            .abbreviation = row.get([]const u8, 3),
            .color = row.get([]const u8, 4),
            .date_created = row.get([]const u8, 5),
            .date_updated = row.get([]const u8, 6),
            .created_by = row.get(?[]const u8, 7),
            .updated_by = row.get(?[]const u8, 8),
        };
    }
};

pub const appointment_status = struct {
    pub fn fromRequest(request: *jetzig.http.Request) !AppointmentStatus {
        var model = AppointmentStatus{};
        const params = try request.params();
        model.id = @intCast(params.getT(.integer, "id") orelse 0);
        model.active = params.getT(.boolean, "active") orelse false;
        model.name = params.getT(.string, "name") orelse return error.MissingParam;
        model.show = params.getT(.boolean, "show") orelse false;
        return model;
    }
    pub fn toResponse(model: AppointmentStatus, data: *jetzig.Data) !void {
        var root = data.value.?;
        try root.put("id", data.integer(model.id));
        try root.put("name", data.string(model.name));
        try root.put("active", data.boolean(model.active));
        try root.put("active_check", data.string(if (model.active) "checked" else ""));
        try root.put("show", data.boolean(model.show));
        try root.put("show_check", data.string(if (model.show) "checked" else ""));
        try root.put("date_created", data.string(model.date_created));
        try root.put("date_updated", data.string(model.date_updated));
        try root.put("created_by", data.string(model.created_by orelse "System"));
        try root.put("updated_by", data.string(model.updated_by orelse "System"));
    }
    pub fn fromDatabase(row: jetzig.http.Database.pg.Row) AppointmentStatus {
        return .{
            .id = row.get(i32, 0),
            .active = row.get(bool, 1),
            .name = row.get([]const u8, 2),
            .show = row.get(bool, 3),
            .date_created = row.get([]const u8, 4),
            .date_updated = row.get([]const u8, 5),
            .created_by = row.get(?[]const u8, 6),
            .updated_by = row.get(?[]const u8, 7),
        };
    }
};
