const AppointmentStatus = @This();
id: i32 = 0,
active: bool = true,
name: []const u8 = "",
show: bool = true,
date_created: []const u8 = "",
date_updated: []const u8 = "",
created_by: ?[]const u8 = "",
updated_by: ?[]const u8 = "",
