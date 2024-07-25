const std = @import("std");
const io = @import("io.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const config = .{ .safety = true };
    var gpa = std.heap.GeneralPurposeAllocator(config){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    while (true) {
        try io.printPrompt();
        const maybe_buf = try io.readInput(allocator);

        if (maybe_buf) |buf| {
            defer allocator.free(buf);

            if (std.mem.eql(u8, buf, ".exit")) {
                break;
            } else {
                try stdout.print("Unrecognized command: {s}.\n", .{buf});
            }
            try bw.flush();
        }
    }

    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
