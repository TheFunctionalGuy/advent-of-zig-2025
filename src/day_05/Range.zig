from: usize,
to: usize,

const Self = @This();

pub fn contains(self: Self, number: usize) bool {
    return self.from <= number and number <= self.to;
}

pub fn lessThan(_: @TypeOf(.{}), lhs: Self, rhs: Self) bool {
    return lhs.from < rhs.from;
}
