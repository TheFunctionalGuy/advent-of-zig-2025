const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const mem = std.mem;

const assert = std.debug.assert;
const parseInt = fmt.parseInt;
const tokenizeScalar = mem.tokenizeScalar;

const File = fs.File;

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

    var total_joltage: usize = 0;
    var total_joltage_with_safety_override: usize = 0;

    var chunks = tokenizeScalar(u8, stdin_input, '\n');
    while (chunks.next()) |bank| {
        total_joltage += try get_maximum_joltage(bank);
        total_joltage_with_safety_override += try get_maximum_joltage_new(bank, 2);
    }

    try stdout.print("Part 1: {d}\n", .{total_joltage});
    try stdout.print("Part 2: {d}\n", .{total_joltage_with_safety_override});

    try stdout.flush();
}

fn get_maximum_joltage(bank: []const u8) !usize {
    assert(bank.len >= 2);

    var first_digit = bank[0];
    var second_digit = bank[1];

    for (1..bank.len) |index| {
        if (index != bank.len - 1 and bank[index] > first_digit) {
            first_digit = bank[index];
            second_digit = bank[index + 1];

            continue;
        }

        if (bank[index] > second_digit) {
            second_digit = bank[index];
        }
    }

    const number: [2]u8 = .{ first_digit, second_digit };

    return try parseInt(usize, &number, 10);
}

fn get_maximum_joltage_new(bank: []const u8, comptime count: usize) !usize {
    assert(bank.len >= count);
    std.debug.print("bank: {s}\n", .{bank});

    var number: [count]u8 = undefined;
    @memcpy(&number, bank[0..count]);

    const highest_number_index: usize = 0;
    for (1..bank.len) |i| {
        // 1. Find distance to highest number
        const distance_to_highest_number = (highest_number_index + i + 2) -| count;
        const end = @min(distance_to_highest_number, count);
        std.debug.print("i: {d}\n", .{i});
        std.debug.print("distance_to_highest_number: {d}\n", .{distance_to_highest_number});

        for (0..end) |number_index| {
            if (bank[i] > number[number_index]) {
                @memcpy(number[number_index .. number_index + end], bank[i .. i + end]);
                break;
            }
        }

        std.debug.print("number: {s}\n", .{number});
    }

    return try parseInt(usize, &number, 10);
}
