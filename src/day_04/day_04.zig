const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const assert = std.debug.assert;
const tokenizeScalar = mem.tokenizeScalar;

const Allocator = mem.Allocator;
const File = fs.File;
const GridList = std.ArrayList([]const u8);

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

    var grid: GridList = .empty;
    defer grid.deinit(allocator);

    var chunks = tokenizeScalar(u8, stdin_input, '\n');
    while (chunks.next()) |chunk| {
        try grid.append(allocator, chunk);
    }

    const useable_rolls = get_number_of_useable_rolls(grid.items);
    const useable_rolls_with_removes = try get_number_of_useable_rolls_new(.{ .yes = allocator }, grid.items);

    try stdout.print("Part 1: {d}\n", .{useable_rolls});
    try stdout.print("Part 2: {d}\n", .{useable_rolls_with_removes});

    try stdout.flush();
}

const AllowRemoves = union(enum) {
    yes: Allocator,
    no: void,
};

fn get_number_of_useable_rolls(grid: [][]const u8) usize {
    const width = grid[0].len;
    const height = grid.len;

    var useable_rolls: usize = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            // Only check rolls
            if (grid[y][x] != '@') {
                continue;
            }

            var adjacent_rolls: usize = 0;

            const offsets = [_]isize{ -1, 0, 1 };
            for (offsets) |y_offset| {
                for (offsets) |x_offset| {
                    // Skip self
                    if (x_offset == 0 and y_offset == 0) {
                        continue;
                    }

                    const x_index: isize = @as(isize, @intCast(x)) + x_offset;
                    const y_index: isize = @as(isize, @intCast(y)) + y_offset;

                    // Skip when index out of bounds
                    if (x_index < 0 or x_index >= width or y_index < 0 or y_index >= height) {
                        continue;
                    }

                    if (grid[@as(usize, @intCast(y_index))][@as(usize, @intCast(x_index))] == '@') {
                        adjacent_rolls += 1;
                    }
                }
            }

            if (adjacent_rolls < 4) {
                useable_rolls += 1;
            }
        }
    }

    return useable_rolls;
}

// TODO: (refactor) Merge with `get_number_of_useable_rolls` for less code duplication
fn get_number_of_useable_rolls_new(allow_removes: AllowRemoves, grid: [][]const u8) !usize {
    const width = grid[0].len;
    const height = grid.len;
    std.debug.print("{d}\n", .{width});
    std.debug.print("{d}\n", .{height});

    const current_grid = switch (allow_removes) {
        .yes => |_| grid,
        .no => grid,
    };

    std.debug.print("{s}\n", .{current_grid});

    return 0;

    // var current_grid = try allocator.alloc([]u8, grid.len);
    // const original_current_grid = current_grid;
    // defer {
    //     for (original_current_grid) |item| {
    //         allocator.free(item);
    //     }
    //     allocator.free(original_current_grid);
    // }
    // var updated_grid = try allocator.alloc([]u8, grid.len);
    // defer {
    //     for (updated_grid) |item| {
    //         allocator.free(item);
    //     }
    //     allocator.free(updated_grid);
    // }
    //
    // for (grid, 0..) |str, i| {
    //     current_grid[i] = try allocator.dupe(u8, str);
    //     updated_grid[i] = try allocator.dupe(u8, str);
    // }
    //
    // var useable_rolls: usize = 0;
    // var changed = true;
    //
    // while (changed) {
    //     changed = false;
    //
    //     for (0..height) |y| {
    //         for (0..width) |x| {
    //             // Only check rolls
    //             if (current_grid[y][x] != '@') {
    //                 continue;
    //             }
    //
    //             var adjacent_rolls: usize = 0;
    //
    //             const offsets = [_]isize{ -1, 0, 1 };
    //             for (offsets) |y_offset| {
    //                 for (offsets) |x_offset| {
    //                     // Skip self
    //                     if (x_offset == 0 and y_offset == 0) {
    //                         continue;
    //                     }
    //
    //                     const x_index: isize = @as(isize, @intCast(x)) + x_offset;
    //                     const y_index: isize = @as(isize, @intCast(y)) + y_offset;
    //
    //                     // Skip when index out of bounds
    //                     if (x_index < 0 or x_index >= width or y_index < 0 or y_index >= height) {
    //                         continue;
    //                     }
    //
    //                     if (current_grid[@as(usize, @intCast(y_index))][@as(usize, @intCast(x_index))] == '@') {
    //                         adjacent_rolls += 1;
    //                     }
    //                 }
    //             }
    //
    //             if (adjacent_rolls < 4) {
    //                 useable_rolls += 1;
    //                 updated_grid[y][x] = '!';
    //                 changed = true;
    //             }
    //         }
    //     }
    //
    //     current_grid = updated_grid;
    // }
    //
    // return useable_rolls;
}
