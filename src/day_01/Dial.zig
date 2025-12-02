const std = @import("std");
const fmt = std.fmt;

const assert = std.debug.assert;
const parseInt = fmt.parseInt;

pub const Rotation = struct {
    pub fn parse(tokens: []const u8) !isize {
        assert(tokens.len >= 2);

        const direction = tokens[0];
        const distance = tokens[1..];
        var parsed_distance = try parseInt(isize, distance, 10);

        switch (direction) {
            'L' => parsed_distance = -parsed_distance,
            'R' => {},
            else => unreachable,
        }

        return parsed_distance;
    }
};

const CountingType = enum {
    /// Counts number of times the dial is resting at zero
    resting,
    /// Counts number of times the dial is visiting zero
    visiting,
};

fn Dial(comptime count_type: CountingType) type {
    return struct {
        size: isize,
        position: isize,
        times_at_zero: usize,

        const Self = @This();

        pub fn init(size: isize, starting_position: isize) Self {
            return Self{ .size = size, .position = starting_position, .times_at_zero = 0 };
        }

        pub fn apply(self: *Self, rotation: isize) void {
            const unbound_result = self.position + rotation;
            const updated_position = @mod(unbound_result, self.size);

            switch (count_type) {
                .resting => {
                    if (updated_position == 0) {
                        self.times_at_zero += 1;
                    }
                },
                .visiting => {
                    if (unbound_result >= self.size or unbound_result <= 0) {
                        var rotations = @abs(@divTrunc(unbound_result, self.size));
                        if (unbound_result <= 0 and self.position != 0) {
                            rotations += 1;
                        }

                        self.times_at_zero += rotations;
                    }
                },
            }

            self.position = updated_position;
        }
    };
}

pub const RestingDial = Dial(.resting);
pub const VisitingDial = Dial(.visiting);
