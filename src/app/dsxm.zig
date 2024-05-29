
extern fn image(x: i32, y: i32, w: i32, h:i32, data: []u8);

export fn f2c(f: f32) f32 {
    return (f - 32.0) * 5.0/9.0;
}

export var running: i32 = 0;

