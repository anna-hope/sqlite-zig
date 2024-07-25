const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn printPrompt() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("db > ", .{});
    try bw.flush();
}

pub fn readInput(allocator: Allocator) !?[]u8 {
    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    const buffer = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 100);
    return buffer;
}
