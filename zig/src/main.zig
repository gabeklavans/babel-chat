const std = @import("std");
const babbel = @import("babbel.zig");



pub fn main() !void {
    const host_name = "127.0.0.1";
    const port = 9000;
    // std.stdout.print("Run `zig build test` to run the tests.\n", .{});
    var app = try babbel.BabbelApp.init(host_name, port);
    defer app.close();
    try app.run();
}

test "echo server test" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    comptime var host_name = "127.0.0.1";
    comptime var port = 9000;

    const address = try std.net.Address.parseIp(host_name, port);
    var stream = std.net.tcpConnectToAddress(address) catch {
        std.debug.print("\n-- Make sure server is running! --\n", .{});
        std.os.exit(1);
    };
    defer stream.close();

    const write_message = "You smell sorry!";
    const write_len = try stream.write(write_message);
    try std.testing.expectEqual(write_message.len, write_len);

    var read_message = try allocator.alloc(u8, write_message.len);
    const read_len = try stream.read(read_message);

    try std.testing.expectEqualSlices(u8, write_message, read_message[0..read_len]);
}
