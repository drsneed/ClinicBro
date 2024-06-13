const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Schedule"));
    //try root.put("month", data.string("June"));
    try root.put("header_include", data.string(
        \\ <link rel="stylesheet" href="/schedule.css">
        \\ <script src="/schedule.js"></script>
    ));
    try root.put("main_schedule", data.string("class=\"current\""));
    return request.render(.ok);
}
