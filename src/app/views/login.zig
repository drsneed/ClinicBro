const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "app";
const log = std.log.scoped(.login);

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();
    try root.put("page_title", data.string("Log In"));
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();
    //log.info("root = {}\n", .{root});
    const logged_in: bool = false;
    const params = try request.params();
    if(params.getT(.string, "email")) |email| {
        log.info("Got email: {s}\n", .{email});
    }
    if(params.getT(.string, "password")) |password| {
        log.info("Got password: {s}\n", .{password});
    }
    if(logged_in) {
        if (params.get("redirect")) |location| {
            switch (location.*) {
                // Value is `.Null` when param is empty, e.g.:
                // `http://localhost:8080/example?redirect`
                .Null => return request.redirect("./", .moved_permanently),

                // Value is `.string` when param is present, e.g.:
                // `http://localhost:8080/example?redirect=https://jetzig.dev/`
                .string => |string| return request.redirect(string.value, .moved_permanently),

                else => return request.redirect("./", .moved_permanently),
            }
        } else {
            return request.redirect("./", .moved_permanently);
        }
    }
    else {
        try root.put("page_title", data.string("Log In"));
        try root.put("error_message", data.string("Invalid credentials, please try again."));
        return request.render(.ok);
    }
}