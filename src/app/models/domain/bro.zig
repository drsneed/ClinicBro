const Bro = @This();

id: i32,
active: bool,
name: [16]u8 = undefined,
color: i32,
sees_clients: bool,
date_created: i64,
date_updated: i64,
created_bro_id: i32,
updated_bro_id: i32,

pub fn name_len(self: Bro) usize {
    var len: usize = 0;
    inline for (self.name) |char| {
        if (char == 0) return len;
        len += 1;
    }
    return len;
}
