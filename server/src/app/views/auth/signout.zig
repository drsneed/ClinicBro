const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../../security.zig");
pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    try request.server.logger.DEBUG("signing out!", .{});
    try security.signout(request);
    //return request.render(.ok);
    return request.redirect("/", .found);
}
