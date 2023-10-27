const std = @import("std");

pub fn main() !void {
    // std.stdout.print("Run `zig build test` to run the tests.\n", .{});
}

test "simple test" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const address = try std.net.Address.parseIp("127.0.0.1", 9000);
    var stream = std.net.tcpConnectToAddress(address) catch |err| {
        std.debug.print("\n-- Make sure server is running! --\n", .{});
        return err;
    };
    defer stream.close();

    const write_message = "You smell sorry!";
    const write_len = try stream.write(write_message);
    try std.testing.expectEqual(write_message.len, write_len);

    var read_message = try allocator.alloc(u8, write_message.len);
    const read_len = try stream.read(read_message);

    try std.testing.expectEqualSlices(u8, write_message, read_message[0..read_len]);
}
