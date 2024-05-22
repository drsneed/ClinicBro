const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../security.zig");
pub const layout = "layout";
const log = std.log.scoped(.login);

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Log In"));
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    //log.info("root = {}\n", .{root});
    var logged_in: bool = false;
    const params = try request.params();
    log.info("attempting to log in , checking params...", .{});
    if (params.getT(.string, "email")) |email| {
        if (params.getT(.string, "password")) |password| {
            log.info("attempting to log in with {s}/{s}", .{ email, password });
            if (try security.login(request, email, password)) {
                logged_in = true;
                log.info("Successfully logged in :)", .{});
            } else {
                log.info("Authentication failed :(", .{});
            }
        }
    }

    if (logged_in) {
        if (params.get("redirect")) |location| {
            switch (location.*) {
                // Value is `.Null` when param is empty, e.g.:
                // `http://localhost:8080/example?redirect`
                .Null => return request.redirect("./", .found),

                // Value is `.string` when param is present, e.g.:
                // `http://localhost:8080/example?redirect=https://jetzig.dev/`
                .string => |string| return request.redirect(string.value, .found),

                else => return request.redirect("./", .found),
            }
        } else {
            return request.redirect("./", .found);
        }
    } else {
        try root.put("page_title", data.string("Log In"));
        try root.put("error_message", data.string("Invalid credentials, please try again."));
        return request.render(.ok);
    }
}
