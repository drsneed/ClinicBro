const std = @import("std");
const jetzig = @import("jetzig");
const auth = @import("../../auth.zig");
pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    try request.server.logger.DEBUG("signing out!", .{});
    try auth.signout(request);
    //return request.render(.ok);
    return request.redirect("/", .found);
}
