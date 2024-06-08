const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../db.zig");
pub const layout = "layout";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Users"));
    const users = try data.array();
    try root.put("users", users);
    // load account list from database
    const dbAccountList = try db.getAllAccounts(request.allocator);
    defer dbAccountList.deinit();

    // append each db account to accounts json array
    for (dbAccountList.items) |dbAccount| {
        var user = try data.object();
        try user.put("uid", data.integer(dbAccount.uid));
        try user.put("name", data.string(dbAccount.name));
        try user.put("email", data.string(dbAccount.email));
        try user.put("mod", data.integer(dbAccount.mod));
        try user.put("iat", data.string(dbAccount.iat));
        try user.put("uat", data.string(dbAccount.uat));
        try users.append(user);
    }

    return request.render(.ok);
}
