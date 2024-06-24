const std = @import("std");
const jetzig = @import("jetzig");
const DbContext = @import("../../db_context.zig");
pub const layout = "app";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("User Setup"));
    try root.put("setup_expander_state", data.string("open"));
    try root.put("setup_users", data.string("class=\"current\""));
    const user_array = try data.array();
    try root.put("users", user_array);
    // load account list from database

    var db_context = try DbContext.init(request.allocator);
    defer db_context.deinit();
    const users = try db_context.getAllUsers();
    defer users.deinit();

    // append each db account to accounts json array
    for (users.items) |user| {
        var usr = try data.object();
        try usr.put("id", data.integer(user.id));
        try usr.put("name", data.string(user.name));
        try usr.put("date_created", data.integer(user.date_created));
        try user_array.append(usr);
    }

    return request.render(.ok);
}
