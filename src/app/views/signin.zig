const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../security.zig");
pub const layout = "signin";
const log = std.log.scoped(.signin);

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    const params = try request.params();
    var return_url: []const u8 = "/";
    if (params.getT(.string, "return_url")) |return_url_param| {
        return_url = return_url_param;
    }
    const session = try request.session();
    if (try session.get("ticket")) |ticket| {
        _ = ticket;
        return request.redirect(return_url, .found);
    } else {
        var root = data.value.?;
        try root.put("page_title", data.string("Sign In"));
        try root.put("return_url", data.string(return_url));
        return request.render(.ok);
    }
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    //log.info("root = {}\n", .{root});
    var signed_in: bool = false;
    var error_message: []const u8 = "Invalid credentials, please try again.";
    const params = try request.params();
    log.info("attempting to sign in , checking params...", .{});
    if (params.getT(.string, "email")) |email| {
        if (params.getT(.string, "password")) |password| {
            signed_in = security.signin(request, email, password) catch blk: {
                error_message = "Database connection failure";
                break :blk false;
            };
        }
    }

    var destination_url: []const u8 = "./";

    if (params.get("return_url")) |location| {
        switch (location.*) {
            .string => |string| {
                destination_url = string.value;
            },
            else => {},
        }
    }

    if (signed_in) {
        return request.redirect(destination_url, .found);
    } else {
        try root.put("page_title", data.string("Sign In"));
        try root.put("return_url", data.string(destination_url));
        try root.put("error_message", data.string(error_message));
        return request.render(.ok);
    }
}
