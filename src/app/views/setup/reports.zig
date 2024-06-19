const std = @import("std");
const jetzig = @import("jetzig");

pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Reports Setup"));
    try root.put("header_include", data.string(
        \\ <link rel="stylesheet" href="/lib/reportbro/reportbro.css">
        \\ <script src="/lib/reportbro/reportbro.js"></script>
    ));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_reports", data.string("class=\"current\""));
    return request.render(.ok);
}
