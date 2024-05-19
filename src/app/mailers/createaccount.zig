const std = @import("std");
const jetzig = @import("jetzig");

pub const defaults: jetzig.mail.DefaultMailParams = .{
    .from = "Test Server <no-reply@testserver.live>",
    .subject = "Account Activation",
};

pub fn deliver(
    allocator: std.mem.Allocator,
    mail: *jetzig.mail.MailParams,
    data: *jetzig.data.Data,
    params: *jetzig.data.Value,
    env: jetzig.jobs.JobEnv,
) !void {
    _ = allocator;

    // if (std.mem.eql(u8, mail.get(.from), "debug@example.com")) {
    //     // Override the mail subject in certain scenarios.
    //     mail.subject = "DEBUG EMAIL";
    // }

    try params.put("token", data.string("secret-token"));
    try env.logger.INFO("Delivering email with subject: '{?s}'", .{mail.get(.subject)});
}