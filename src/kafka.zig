const std = @import("std");
pub const Config = @import("config.zig").ConfigType();

test {
    std.testing.refAllDecls(@This());
}

pub fn main() !void {}
