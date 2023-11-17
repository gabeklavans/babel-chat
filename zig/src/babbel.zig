/// https://ziglang.org/documentation/master/std/#A;std

const std = @import("std");
const be = @import("babbel_event.zig");

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

        var events: []be.Event = try allocator.alloc(be.Event, 10);
        var event_channel = std.event.Channel(be.Event).init(events);
        defer event_channel.deinit();

        var event_thread = std.Thread.start(event_handler, std.Ptr(event_channel));
        defer std.Thread.join(event_thread);

        const max_message_len = 128;
        var send_message: []u8 = try allocator.alloc(u8, max_message_len);
        var read_message: []u8 = try allocator.alloc(u8, max_message_len);

        std.debug.print("Send Message: ", .{});

        const stdin = std.io.getStdIn();
        var temp_reader = stdin.reader();

        // main loop
        while (true) {
            // Process user input
            var input = try nextLine(temp_reader, send_message);
            var sent_len = try self.sendMessage(input.?);

            std.debug.assert(input.?.len == sent_len);

            if (self.stream.getMessage()) {
                std.debug.print("Echo: {s}", .{read_message[0..]});
            }
            // Update the user interface

            // If there is an event in the queue, dequeue it and process it
            // var event: std.Ptr = event_queue.dequeue();
            // if (event != std.Ptr(null)) {
            //     process_event(event);
            // }
        }
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
            '\n', // TODO: get working with new line!!!
        )) orelse return null;
        // trim annoying windows-only carriage return character
        if (@import("builtin").os.tag == .windows) {
            return std.mem.trimRight(u8, line, "\r");
        } else {
            return line;
        }
    }

    fn event_handler(_: std.Thread.task, data: std.Ptr) void {
        var event_channel: std.Channel = data.*;
        while (true) {
            _ = event_channel.getOrNull();
            // if (event_queue.)
            // Listen for events
            // Add events to the event queue
            // const recived_len = try self.getMessage(read_message);
            // std.debug.print("Echo: {s}", .{read_message[0..recived_len]});
        }
    }

    // fn process_event(event: std.Ptr) void {
    //     // Handle the event
    // }
};
