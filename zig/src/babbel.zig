const std = @import("std");

pub const BabbelApp = struct {
    stream: std.net.Stream,

    pub fn init(host_name: []const u8, port: u16) !BabbelApp {
        const address: std.net.Address = try std.net.Address.parseIp(host_name, port);
        var stream = std.net.tcpConnectToAddress(address) catch |err| {
            std.debug.print("\n-- Make sure server is running! --\n", .{});
            return err;
        };

        return .{ .stream = stream };
    }

    pub fn close(self: BabbelApp) void {
        self.stream.close();
        return;
    }

    pub fn run(self: BabbelApp) !void {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        var allocator = arena.allocator();

        const max_message_len = 128;
        var send_message: []u8 = try allocator.alloc(u8, max_message_len);
        var read_message: []u8 = try allocator.alloc(u8, max_message_len);

        // const temp = "hey";
        // @memcpy(send_message[0..temp.len], temp[0..]);

        std.debug.print("Send Message: ", .{});

        const stdin = std.io.getStdIn();
        var temp_reader = stdin.reader();
        var input = try nextLine(temp_reader, send_message);
        var sent_len = try self.sendMessage(input.?);

        std.debug.assert(input.?.len == sent_len);

        const recived_len = try self.getMessage(read_message);
        std.debug.print("Echo: {s}", .{read_message[0..recived_len]});
    }

    fn sendMessage(self: BabbelApp, message: []const u8) !usize {
        return try self.stream.write(message);
    }

    pub fn getMessage(self: BabbelApp, message: []u8) !usize {
        return try self.stream.read(message);
    }

    fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
        var line = (try reader.readUntilDelimiterOrEof(
            buffer,
            '.', // TODO: get working with new line!!!
        )) orelse return null;
        // trim annoying windows-only carriage return character
        if (@import("builtin").os.tag == .windows) {
            return std.mem.trimRight(u8, line, "\r");
        } else {
            return line;
        }
    }
};
