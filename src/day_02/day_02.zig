const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const mem = std.mem;

const assert = std.debug.assert;
const bufPrint = fmt.bufPrint;
const eql = mem.eql;
const indexOfScalar = mem.indexOfScalar;
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

    var sum_of_simple_invalid_ids: usize = 0;
    var sum_of_complex_invalid_ids: usize = 0;

    var chunks = tokenizeScalar(u8, stdin_input[0 .. stdin_input.len - 1], ',');
    while (chunks.next()) |chunk| {
        const range_delimiter = indexOfScalar(u8, chunk, '-').?;

        const from = try parseInt(usize, chunk[0..range_delimiter], 10);
        const to = try parseInt(usize, chunk[range_delimiter + 1 ..], 10);

        var id_buffer: [BUFFER_SIZE]u8 = undefined;
        for (from..to + 1) |current| {
            const chars = try bufPrint(&id_buffer, "{d}", .{current});

            if (is_simple_invalid_id(chars)) {
                sum_of_simple_invalid_ids += current;
            }

            if (is_complex_invalid_id(chars)) {
                sum_of_complex_invalid_ids += current;
            }
        }
    }

    try stdout.print("Part 1: {d}\n", .{sum_of_simple_invalid_ids});
    try stdout.print("Part 2: {d}\n", .{sum_of_complex_invalid_ids});

    try stdout.flush();
}

fn is_simple_invalid_id(id: []const u8) bool {
    // Numbers of odd length cannot be repeated sequences because: l * 2 is even
    if (id.len % 2 != 0) {
        return false;
    }

    const middle_index = id.len / 2;

    // Not as fast as hand-roled code because we have less branches and the numbers are very short
    // but less verbose
    return eql(u8, id[0..middle_index], id[middle_index..id.len]);
}

fn is_complex_invalid_id(id: []const u8) bool {
    const middle_index = id.len / 2;

    // Windows over half the size of ID never fit
    outer: for (1..middle_index + 1) |windows_size| {
        // Windows do not fully fit into ID
        if (id.len % windows_size != 0) {
            continue;
        }

        const initial_window = id[0..windows_size];
        var index = windows_size;

        while (index < id.len) : (index += windows_size) {
            const repeating_window = id[index .. index + windows_size];

            if (!eql(
                u8,
                initial_window,
                repeating_window,
            )) {
                continue :outer;
            }
        }

        return true;
    }

    return false;
}
