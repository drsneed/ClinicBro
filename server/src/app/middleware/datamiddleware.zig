/// Demo middleware. Assign middleware by declaring `pub const middleware` in the
/// `jetzig_options` defined in your application's `src/main.zig`.
///
/// Middleware is called before and after the request, providing full access to the active
/// request, allowing you to execute any custom code for logging, tracking, inserting response
/// headers, etc.
///
/// This middleware is configured in the demo app's `src/main.zig`:
///
/// ```
/// pub const jetzig_options = struct {
///    pub const middleware: []const type = &.{@import("app/middleware/AuthMiddleware.zig")};
/// };
/// ```
const std = @import("std");
const jetzig = @import("jetzig");
/// Define any custom data fields you want to store here. Assigning to these fields in the `init`
/// function allows you to access them in various middleware callbacks defined below, where they
/// can also be modified.
//my_custom_value: []const u8,

const DataMiddleware = @This();

const RequiredFields = .{
    "main_home",
    "main_schedule",
    "setup_expander_state",
    "setup_users",
    "setup_locations",
    "setup_appointment_types",
    "setup_appointment_statuses",
    "setup_reports",
    "setup_system",
    "header_include",
};

const IgnorePaths = .{
    "/client-api/*",
};

/// Initialize middleware.
pub fn init(request: *jetzig.http.Request) !*DataMiddleware {
    const middleware = try request.allocator.create(DataMiddleware);
    //middleware.my_custom_value = "initial value";
    return middleware;
}

/// Invoked immediately after the request is received but before it has started processing.
/// Any calls to `request.render` or `request.redirect` will prevent further processing of the
/// request, including any other middleware in the chain.
pub fn afterRequest(self: *DataMiddleware, request: *jetzig.http.Request) !void {
    _ = self;
    inline for (IgnorePaths) |ignore_path| {
        if (std.mem.endsWith(u8, ignore_path, "*") and std.mem.startsWith(u8, request.path.path, ignore_path[0 .. ignore_path.len - 1])) {
            //try request.server.logger.DEBUG("{s} is a public path. No auth required.", .{path});
            return;
        }
        if (std.mem.eql(u8, request.path.path, ignore_path)) {
            //try request.server.logger.DEBUG("{s} is a public path. No auth required.", .{path});
            return;
        } else {
            //try request.server.logger.DEBUG("{s} != {s}", .{ path, ignore_path });
        }
    }
    // initialize data object with empty values
    if (request.response_data.value) |root| {
        inline for (RequiredFields) |required_field| {
            try root.put(required_field, request.response_data.string(""));
        }

        // cache system settings if they are not there
        // if (try request.cache.get("client_title")) |client_title| {
        //     try root.put("client_title", .{client_title});
        // }

        // try root.put("client_title", try request.cache.get("client_title"));
    }
}

/// Invoked immediately before the response renders to the client.
/// The response can be modified here if needed.
pub fn beforeResponse(
    self: *DataMiddleware,
    request: *jetzig.http.Request,
    response: *jetzig.http.Response,
) !void {
    _ = self;
    _ = request;
    _ = response;
}

/// Invoked immediately after the response has been finalized and sent to the client.
/// Response data can be accessed for logging, but any modifications will have no impact.
pub fn afterResponse(
    self: *DataMiddleware,
    request: *jetzig.http.Request,
    response: *jetzig.http.Response,
) !void {
    _ = self;
    _ = response;
    _ = request;
    // try request.server.logger.DEBUG("[AuthMiddleware:afterResponse] response completed", .{});
}

/// Invoked after `afterResponse` is called. Use this function to do any clean-up.
/// Note that `request.allocator` is an arena allocator, so any allocations are automatically
/// freed before the next request starts processing.
pub fn deinit(self: *DataMiddleware, request: *jetzig.http.Request) void {
    request.allocator.destroy(self);
}
