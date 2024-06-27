const Bro = @This();

id: i32,
active: bool,
name: [16]u8 = undefined,
color: i32,
sees_clients: bool,
date_created: i64,
date_updated: i64,
created_bro_id: i32,
updated_bro_id: i32
