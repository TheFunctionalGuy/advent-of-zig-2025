const std = @import("std");

const Dial = @import("Dial.zig");
const RestingDial = Dial.RestingDial;
const VisitingDial = Dial.VisitingDial;
const Rotation = Dial.Rotation;

const assert = std.debug.assert;

const BUFFER_SIZE: usize = 1024;

pub fn main() !void {
    var stdout_buffer: [BUFFER_SIZE]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stdin_buffer: [BUFFER_SIZE]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const stdin_input = try stdin.allocRemaining(allocator, std.Io.Limit.unlimited);
    defer allocator.free(stdin_input);

    var resting_dial = RestingDial.init(100, 50);
    var visiting_dial = VisitingDial.init(100, 50);

    var chunks = std.mem.tokenizeScalar(u8, stdin_input, '\n');

    while (chunks.next()) |chunk| {
        const rotation = try Rotation.parse(chunk);

        resting_dial.apply(rotation);
        visiting_dial.apply(rotation);
    }

    try stdout.print("Part 1: {d}\n", .{resting_dial.times_at_zero});
    try stdout.print("Part 2: {d}\n", .{visiting_dial.times_at_zero});

    try stdout.flush();
}
