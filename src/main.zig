const std = @import("std");

pub const Config = @import("config.zig").ConfigType();

pub fn main() !void {
    var config = Config.init();
    const conf = config
        .set("debug", "all")
        .set("bootstrap.servers", "localhost:9092")
        .set("enable.idempotence", "true")
        .set("batch.num.messages", "10")
        .set("reconnect.backoff.ms", "1000")
        .set("reconnect.backoff.max.ms", "5000")
        .set("transaction.timeout.ms", "10000")
        .set("linger.ms", "100")
        .set("delivery.timeout.ms", "1800000")
        .set("compression.codec", "snappy")
        .set("batch.size", "16384")
        .build();

    std.debug.print("Type of config: {string}\n", .{@typeName(@TypeOf(conf))});
}
