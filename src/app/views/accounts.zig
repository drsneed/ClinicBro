const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../db.zig");
pub const layout = "layout";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    try root.put("page_title", data.string("Accounts"));
    const accounts = try data.array();
    try root.put("accounts", accounts);
    // load account list from database
    const dbAccountList = try db.getAllAccounts(request.allocator);
    defer dbAccountList.deinit();

    // append each db account to accounts json array
    for (dbAccountList.items) |dbAccount| {
        var account = try data.object();
        try account.put("uid", data.integer(dbAccount.uid));
        try account.put("name", data.string(dbAccount.name));
        try account.put("email", data.string(dbAccount.email));
        try account.put("mod", data.integer(dbAccount.mod));
        try account.put("iat", data.string(dbAccount.iat));
        try account.put("uat", data.string(dbAccount.uat));
        try accounts.append(account);
    }

    return request.render(.ok);
}
