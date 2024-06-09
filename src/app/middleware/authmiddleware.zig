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
const security = @import("../security.zig");
/// Define any custom data fields you want to store here. Assigning to these fields in the `init`
/// function allows you to access them in various middleware callbacks defined below, where they
/// can also be modified.
//my_custom_value: []const u8,

const AuthMiddleware = @This();

/// Initialize middleware.
pub fn init(request: *jetzig.http.Request) !*AuthMiddleware {
    const middleware = try request.allocator.create(AuthMiddleware);
    //middleware.my_custom_value = "initial value";
    return middleware;
}

/// Invoked immediately after the request is received but before it has started processing.
/// Any calls to `request.render` or `request.redirect` will prevent further processing of the
/// request, including any other middleware in the chain.
pub fn afterRequest(self: *AuthMiddleware, request: *jetzig.http.Request) !void {
    _ = self;
    if (!try security.authorize(request)) {
        // don't append return_url for requests to home path '/'
        if (std.mem.eql(u8, request.path.path, "/")) {
            _ = request.redirect("./signin", .found);
        } else {
            var buf: [256]u8 = undefined;
            const url = try std.fmt.bufPrint(&buf, "./signin?return_url={s}", .{request.path.path});
            _ = request.redirect(url, .found);
        }
    }
}

/// Invoked immediately before the response renders to the client.
/// The response can be modified here if needed.
pub fn beforeResponse(
    self: *AuthMiddleware,
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
    self: *AuthMiddleware,
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
pub fn deinit(self: *AuthMiddleware, request: *jetzig.http.Request) void {
    request.allocator.destroy(self);
}
