const std = @import("std");
const jetzig = @import("jetzig");
const db = @import("../db.zig");
pub const layout = "layout";

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = data.value.?;
    if (!root.getT(.boolean, "authorized").?) {
        return request.redirect("./login", .found); // todo: add redirect url as parameter
    }
    try root.put("page_title", data.string("Accounts"));
    // const accounts = try db.getAllAccounts(request.allocator);
    // defer request.allocator.free(accounts);
    // var accountsArray = data.array();
    // for(accounts.items) |account| {
    //     try accountsArray.append(account);
    // }
    // try root.put("accounts", accountsArray);
    return request.render(.ok);
}
