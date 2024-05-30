const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../security.zig");
pub const layout = "login";
const log = std.log.scoped(.login);

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
        try root.put("page_title", data.string("Log In"));
        try root.put("return_url", data.string(return_url));
        return request.render(.ok);
    }
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    //log.info("root = {}\n", .{root});
    var logged_in: bool = false;
    const params = try request.params();
    log.info("attempting to log in , checking params...", .{});
    if (params.getT(.string, "email")) |email| {
        if (params.getT(.string, "password")) |password| {
            if (try security.login(request, email, password)) {
                logged_in = true;
                log.info("Successfully logged in :)", .{});
            } else {
                // log unsuccessful attempt
                log.info("Authentication failed :(", .{});
            }
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

    if (logged_in) {
        return request.redirect(destination_url, .found);
    } else {
        try root.put("page_title", data.string("Log In"));
        try root.put("return_url", data.string(destination_url));
        try root.put("error_message", data.string("Invalid credentials, please try again."));
        return request.render(.ok);
    }
}
