const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "layout";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Home"));
    return request.render(.ok);
}
