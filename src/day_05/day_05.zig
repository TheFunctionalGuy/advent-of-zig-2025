const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const mem = std.mem;
const sort = std.sort;

const assert = std.debug.assert;
const indexOfScalar = mem.indexOfScalar;
const parseInt = fmt.parseInt;
const pdq = sort.pdq;
const tokenizeScalar = mem.tokenizeScalar;
const tokenizeSequence = mem.tokenizeSequence;

const File = fs.File;
const Range = @import("Range.zig");
const RangeList = std.ArrayList(Range);

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

    var chunks = tokenizeSequence(u8, stdin_input, "\n\n");
    const ranges = chunks.next().?;
    const ingredient_ids = chunks.next().?;

    assert(chunks.next() == null);

    var fresh_ids: RangeList = .empty;
    defer fresh_ids.deinit(allocator);

    var range_chunks = tokenizeScalar(u8, ranges, '\n');
    while (range_chunks.next()) |range| {
        const delimiter_index = indexOfScalar(u8, range, '-').?;

        const from = try parseInt(usize, range[0..delimiter_index], 10);
        const to = try parseInt(usize, range[delimiter_index + 1 ..], 10);

        try fresh_ids.append(allocator, Range{ .from = from, .to = to });
    }

    // Ranges need to be sorted by start for the algorithm to work
    pdq(Range, fresh_ids.items, .{}, Range.lessThan);

    var number_of_fresh_ids: usize = 0;
    number_of_fresh_ids += fresh_ids.items[0].to - fresh_ids.items[0].from + 1;

    var current: usize = 1;
    var previous_non_complete_overlap: usize = 0;
    while (current < fresh_ids.items.len) : (current += 1) {
        // Complete overlap
        if (fresh_ids.items[current].to <= fresh_ids.items[previous_non_complete_overlap].to) {
            continue;
        }

        number_of_fresh_ids += fresh_ids.items[current].to - fresh_ids.items[current].from + 1;

        // Partial overlap
        if (fresh_ids.items[current].from <= fresh_ids.items[previous_non_complete_overlap].to) {
            number_of_fresh_ids -= fresh_ids.items[previous_non_complete_overlap].to - fresh_ids.items[current].from + 1;
        }

        previous_non_complete_overlap = current;
    }

    var number_of_fresh_ingredients: usize = 0;

    var id_chunks = tokenizeScalar(u8, ingredient_ids, '\n');
    while (id_chunks.next()) |id| {
        for (fresh_ids.items) |range| {
            if (range.contains(try parseInt(usize, id, 10))) {
                number_of_fresh_ingredients += 1;

                break;
            }
        }
    }

    try stdout.print("Part 1: {d}\n", .{number_of_fresh_ingredients});
    try stdout.print("Part 2: {d}\n", .{number_of_fresh_ids});

    try stdout.flush();
}
