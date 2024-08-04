const std = @import("std");
const jetzig = @import("jetzig");
const security = @import("../security.zig");
const log = std.log.scoped(.client_api);

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();
    var jwt_token: ?[]const u8 = null;
    const params = try request.params();
    log.info("attempting to sign in , checking params...", .{});
    if (params.getT(.string, "name")) |name| {
        log.info("got name: {s}", .{name});
        if (params.getT(.string, "password")) |password| {
            log.info("Obtaining token for credentials: {s}/{s}", .{ name, password });
            jwt_token = security.issueToken(request, name, password) catch null;
        }
    }
    log.info("Returning token: {s}", .{jwt_token orelse ""});
    try root.put("token", data.string(jwt_token orelse ""));
    return request.render(.ok);
}
