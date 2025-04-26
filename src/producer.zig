const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const librdkafka = @cImport({
    @cInclude("librdkafka/rdkafka.h");
});

fn ProducerType() type {
    return struct {
        const Config = @This();

        _kafka_producer: ?*librdkafka.rd_kafka_t,
        _topic: ?*librdkafka.struct_rd_kafka_topic_s,
    };
}
