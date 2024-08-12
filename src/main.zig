const std = @import("std");
const io = @import("io.zig");
const parser = @import("parser.zig");
const storage = @import("storage.zig");

fn executeStatement(statement: parser.Statement, table: *storage.Table) !void {
    switch (statement) {
        .insert => {
            const row_to_insert = statement.insert.row;
            try table.insertRow(row_to_insert);
        },
        .select => std.debug.print("This is where we would do a select.\n", .{}),
    }
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const config = .{ .safety = true };
    var gpa = std.heap.GeneralPurposeAllocator(config){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var table = try storage.Table.init();

    while (true) {
        try io.printPrompt();
        const maybe_input_buf = try io.readInput(allocator);

        if (maybe_input_buf) |input_buf| {
            defer allocator.free(input_buf);

            if (input_buf.len == 0) continue else if (input_buf[0] == '.') {
                if (std.mem.eql(u8, input_buf, ".exit")) break;

                parser.processMetaCommand(input_buf) catch {
                    try stdout.print("Unrecognized command: '{s}'\n", .{input_buf});
                    try bw.flush();
                };

                continue;
            }

            const maybe_statement = parser.Statement.parse(input_buf) catch |err| blk: {
                switch (err) {
                    error.Unrecognized => {
                        try stdout.print("Unrecognized keyword at start of '{s}'.\n", .{input_buf});
                    },
                    error.Syntax, error.Overflow, error.InvalidCharacter => {
                        try stdout.print("Syntax error. Could not parse statement: '{s}'.\n", .{input_buf});
                    },
                }
                break :blk null;
            };

            if (maybe_statement) |statement| {
                try executeStatement(statement, &table);
                try stdout.print("Executed.\n", .{});
            }

            try bw.flush();
        }
    }

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
