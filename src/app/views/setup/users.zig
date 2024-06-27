const std = @import("std");
const jetzig = @import("jetzig");
const db_context = @import("../../db_context.zig");
const log = std.log.scoped(.bros);
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Bro Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_bros", data.string("class=\"current\""));
    const json_bros = try data.array();
    try root.put("bros", json_bros);
    // load bros from database and build json array for page model
    const bros = try db_context.getBros(request.allocator, request.server.database, false);
    defer bros.deinit();
    for (bros.items) |bro| {
        var json_bro = try data.object();
        try json_bro.put("id", data.integer(bro.id));
        try json_bro.put("name", data.string(&bro.name));
        try json_bro.put("date_created", data.integer(bro.date_created));
        try json_bros.append(json_bro);
    }

    return request.render(.ok);
}
