const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Home"));
    try root.put("main_home", data.string("class=\"current\""));
    return request.render(.ok);
}
