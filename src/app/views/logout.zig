const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../security.zig");
pub const layout = "layout";
pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    try request.server.logger.DEBUG("logging out!", .{});
    try security.logout(request);
    //return request.render(.ok);
    return request.redirect("./", .found);
}