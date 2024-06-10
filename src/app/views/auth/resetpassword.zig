const std = @import("std");
const jetzig = @import("jetzig");
const auth = @import("../../auth.zig");
pub const layout = "auth";
const log = std.log.scoped(.resetpassword);

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return request.render(.ok);
    // const session = try request.session();
    // if (try session.get("ticket")) |ticket| {
    //     _ = ticket;
    //     return request.redirect("./", .found);
    // } else {
    //     var root = data.value.?;
    //     try root.put("page_title", data.string("Log In"));
    //     try root.put("hide_login_btn", data.boolean(true));
    //     return request.render(.ok);
    // }
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    //log.info("root = {}\n", .{root});
    //var logged_in: bool = false;
    const params = try request.params();
    if (params.getT(.string, "email")) |email| {
        log.info("attempting to reset password for {s}", .{email});
        // if (try security.login(request, email, password)) {
        //     logged_in = true;
        //     log.info("Successfully logged in :)", .{});
        // } else {
        //     log.info("Authentication failed :(", .{});
        // }
    }

    // if (logged_in) {
    //     if (params.get("redirect")) |location| {
    //         switch (location.*) {
    //             // Value is `.Null` when param is empty, e.g.:
    //             // `http://localhost:8080/example?redirect`
    //             .Null => return request.redirect("./", .found),

    //             // Value is `.string` when param is present, e.g.:
    //             // `http://localhost:8080/example?redirect=https://jetzig.dev/`
    //             .string => |string| return request.redirect(string.value, .found),

    //             else => return request.redirect("./", .found),
    //         }
    //     } else {
    //         return request.redirect("./", .found);
    //     }
    // } else {
    //     try root.put("page_title", data.string("Log In"));
    //     try root.put("error_message", data.string("Invalid credentials, please try again."));
    //     return request.render(.ok);
    // }
    try root.put("error_message", data.string("Invalid email address."));
    return request.render(.ok);
    //return request.redirect("./", .found);
}
