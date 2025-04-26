const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const librdkafka = @cImport({
    @cInclude("librdkafka/rdkafka.h");
});

fn ConfigType() type {
    return struct {
        const Config = @This();

        _kafka_conf: ?*librdkafka.struct_rd_kafka_conf_s,

        pub inline fn init() Config {
            const producer_conf: ?*librdkafka.struct_rd_kafka_conf_s = librdkafka.rd_kafka_conf_new();
            std.debug.assert(producer_conf != null);
            return .{ ._kafka_conf = producer_conf };
        }

        pub inline fn set(self: *Config, param: [*c]const u8, value: [*c]const u8) *Config {
            var error_message: [512]u8 = undefined;
            std.debug.assert(self._kafka_conf != null);
            if (librdkafka.rd_kafka_conf_set(self._kafka_conf, param, value, &error_message, error_message.len) != librdkafka.RD_KAFKA_CONF_OK) {
                @panic(&error_message);
            }
            return self;
        }

        pub inline fn build(self: Config) ?*librdkafka.struct_rd_kafka_conf_s {
            std.debug.assert(self._kafka_conf != null);

            // 1. Check bootstrap.servers (required)
            var bootstrap_servers_value: [512]u8 = undefined;
            var bootstrap_servers_size: usize = bootstrap_servers_value.len;
            const bootstrap_servers_result = librdkafka.rd_kafka_conf_get(self._kafka_conf, "bootstrap.servers", &bootstrap_servers_value, &bootstrap_servers_size);
            std.debug.assert(bootstrap_servers_result == librdkafka.RD_KAFKA_CONF_OK);
            std.debug.assert(bootstrap_servers_size > 0);
            return self._kafka_conf;
        }

        pub inline fn printAllConfig(self: Config) void {
            std.debug.assert(self._kafka_conf != null);

            const stdout = std.io.getStdOut().writer();

            // Comprehensive list of librdkafka producer configurations
            const config_keys = [_][]const u8{
                // Connection configurations
                "bootstrap.servers",
                "client.id",
                "client.rack",
                "metadata.broker.list",
                "reconnect.backoff.ms",
                "reconnect.backoff.max.ms",
                "socket.timeout.ms",
                "socket.keepalive.enable",
                "socket.max.fails",
                "broker.address.ttl",
                "broker.address.family",
                "security.protocol",

                // Performance configurations
                "queue.buffering.max.messages",
                "queue.buffering.max.kbytes",
                "queue.buffering.max.ms",
                "message.send.max.retries",
                "retries",
                "retry.backoff.ms",
                "compression.codec",
                "compression.type",
                "batch.num.messages",
                "batch.size",
                "linger.ms",
                "delivery.timeout.ms",
                "message.max.bytes",
                "max.in.flight.requests.per.connection",

                // Reliability configurations
                "enable.idempotence",
                "enable.gapless.guarantee",
                "acks",
                "request.required.acks",
                "request.timeout.ms",
                "message.timeout.ms",

                // Transactional configurations
                "transactional.id",
                "transaction.timeout.ms",

                // SSL configurations
                "ssl.key.location",
                "ssl.key.password",
                "ssl.certificate.location",
                "ssl.ca.location",
                "ssl.crl.location",

                // SASL configurations
                "sasl.mechanisms",
                "sasl.username",
                "sasl.password",

                // Partitioning and routing
                "partitioner",
                "sticky.partitioning.linger.ms",

                // Debug and metrics
                "debug",
                "statistics.interval.ms",
                "log.level",
                "log.queue",
                "log.thread.name",

                // Memory management
                "buffer.memory",
                "receive.message.max.bytes",

                // Other producer-specific configurations
                "produce.offset.report",
                "enable.random.seed",
                "builtin.features",
                "api.version.request",
                "api.version.fallback.ms",
                "api.version.request.timeout.ms",
                "enabled_events",
                "internal.termination.signal",
                "log_cb",
                "log_level",
                "opaque",
                "default_topic_conf",
                "interceptors",
                "plugins.library.paths",
            };

            var buffer: [512]u8 = undefined;

            stdout.print("\n========= Kafka Producer Configuration =========\n", .{}) catch {};

            for (config_keys) |key| {
                var value_size: usize = buffer.len;
                const result = librdkafka.rd_kafka_conf_get(self._kafka_conf, key.ptr, &buffer, &value_size);

                if (result == librdkafka.RD_KAFKA_CONF_OK) {
                    // Create a slice of the buffer up to value_size
                    const value_str = buffer[0..value_size];
                    stdout.print("{s}: {s}\n", .{ key, value_str }) catch {};
                } else {
                    stdout.print("{s}: <not set>\n", .{key}) catch {};
                }
            }

            stdout.print("=================================================\n", .{}) catch {};
        }
    };
}

test "test Producer Config Ok" {
    var Config = ConfigType().init();
    const conf = Config
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

    std.debug.assert(@TypeOf(conf) == ?*librdkafka.struct_rd_kafka_conf_s);
    Config.printAllConfig();
}
