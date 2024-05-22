const std = @import("std");
const jetzig = @import("jetzig");
const auth = @import("../auth.zig");
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
    if(params.getT(.string, "email")) |email| {
        if(params.getT(.string, "password")) |password| {
            log.info("Attempting to authenticate account with email {s} and password {s}", .{email, password});
            if(try auth.authenticate(request.allocator, email, password)) |jwt| {
                defer request.allocator.free(jwt);
                var session = try request.session();
                try session.put("jwt", data.string(jwt));
                logged_in = true;
            }
            else {
                log.info("Authentication failed :(", .{});
            }

        }
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