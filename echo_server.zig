const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var listener = try std.net.StreamServer.init(.{
        .address = std.net.Address.parseIp4("0.0.0.0", 8080),
    });
    defer listener.deinit();

    try listener.listen();
    std.debug.print("Echo server listening on 0.0.0.0:8080\n", .{});

    while (true) {
        var conn = try listener.accept();
        defer conn.close();

        var stream = conn.stream;
        var buffer: [1024]u8 = undefined;

        while (true) {
            const bytes_read = try stream.read(buffer[0..]);
            if (bytes_read == 0) break;

            std.debug.print("Received: {s}\n", .{buffer[0..bytes_read]});
            try stream.writeAll(buffer[0..bytes_read]);
        }
    }
}
