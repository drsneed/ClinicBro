const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../../db.zig");
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("System Setup"));
    return request.render(.ok);
}
