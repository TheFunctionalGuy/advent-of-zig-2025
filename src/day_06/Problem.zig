const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

const assert = std.debug.assert;
const parseInt = fmt.parseInt;
const trim = mem.trim;

const Allocator = mem.Allocator;

const Direction = enum {
    normal,
    right_to_left,
};

pub fn solve(allocator: Allocator, comptime direction: Direction, numbers: [][]const u8, operation: u8) !usize {
    assert(numbers.len > 0);

    const resolved_numbers_count = switch (direction) {
        .normal => numbers.len,
        .right_to_left => numbers[0].len,
    };
    var resolved_numbers = try allocator.alloc(usize, resolved_numbers_count);
    defer allocator.free(resolved_numbers);

    const number_representation = switch (direction) {
        .normal => numbers,
        // Here in theory we should go right-to-left, but because `+` and `*` are commutative we ignore that
        .right_to_left => blk: {
            var reordered_numbers = try allocator.alloc([]u8, resolved_numbers_count);

            for (0..numbers[0].len) |i| {
                reordered_numbers[i] = try allocator.alloc(u8, numbers.len);

                for (numbers, 0..) |number, j| {
                    reordered_numbers[i][j] = number[i];
                }
            }

            for (0..reordered_numbers.len) |i| {
                resolved_numbers[i] = try parseInt(usize, trim(u8, reordered_numbers[i], " "), 10);
            }

            break :blk reordered_numbers;
        },
    };
    defer {
        if (direction == .right_to_left) {
            for (number_representation) |number| {
                allocator.free(number);
            }
            allocator.free(number_representation);
        }
    }

    for (0..resolved_numbers_count) |i| {
        resolved_numbers[i] = try parseInt(usize, trim(u8, number_representation[i], " "), 10);
    }

    return switch (operation) {
        '+' => blk: {
            var result: usize = 0;
            for (resolved_numbers) |number| {
                result += number;
            }

            break :blk result;
        },
        '*' => blk: {
            var result: usize = 1;
            for (resolved_numbers) |number| {
                result *= number;
            }

            break :blk result;
        },
        else => unreachable,
    };
}
