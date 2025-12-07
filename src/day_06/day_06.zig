const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const mem = std.mem;

const assert = std.debug.assert;
const tokenizeScalar = mem.tokenizeScalar;

const File = fs.File;
const Problem = @import("Problem.zig");

const BUFFER_SIZE: usize = 1024;

pub fn main() !void {
    var stdout_buffer: [BUFFER_SIZE]u8 = undefined;
    var stdout_writer = File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stdin_buffer: [BUFFER_SIZE]u8 = undefined;
    var stdin_reader = File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const stdin_input = try stdin.allocRemaining(allocator, .unlimited);
    defer allocator.free(stdin_input);

    var lines: std.ArrayList([]const u8) = .empty;
    defer lines.deinit(allocator);

    var chunks = tokenizeScalar(u8, stdin_input, '\n');
    while (chunks.next()) |line| {
        try lines.append(allocator, line);
    }

    assert(lines.items.len > 0);
    const line_length = lines.items[0].len;

    var result: usize = 0;
    var right_to_left_result: usize = 0;

    var previous_start: usize = 0;
    var column: usize = 0;
    outer: while (column <= line_length) : (column += 1) {
        // Search for empty column
        for (lines.items) |line| {
            // Don't skip on last column
            if (column != line_length and line[column] != ' ') {
                continue :outer;
            }
        }

        var numbers = try allocator.alloc([]const u8, lines.items.len - 1);
        defer allocator.free(numbers);

        for (0..lines.items.len - 1) |i| {
            numbers[i] = lines.items[i][previous_start..column];
        }

        result += try Problem.solve(allocator, .normal, numbers, lines.items[lines.items.len - 1][previous_start]);
        right_to_left_result += try Problem.solve(allocator, .right_to_left, numbers, lines.items[lines.items.len - 1][previous_start]);

        // Skip empty column
        column += 1;
        previous_start = column;
    }

    try stdout.print("Part 1: {d}\n", .{result});
    try stdout.print("Part 2: {d}\n", .{right_to_left_result});

    try stdout.flush();
}
