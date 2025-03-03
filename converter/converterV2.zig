const std = @import("std");
const expect = std.testing.expect;

const print = std.debug.print;
pub fn main() !void {
    print("Convert Temperature:\n", .{});
    var buffer: [16]u8 = undefined;
    print("From: (C, F, K)\n", .{});
    const from: u8 = (try readLine(&buffer))[0];
    print("To: (C, F, K)\n", .{});
    const to: u8 = (try readLine(&buffer))[0];
    print("Enter Temperature: \n", .{});
    var temp = try std.fmt.parseFloat(f64, std.mem.trim(u8, try readLine(&buffer), &std.ascii.whitespace));
    temp = try calcTemp(std.ascii.toUpper(from), std.ascii.toUpper(to), temp);
    print("from {c} to {c} is {d}\n", .{ from, to, temp });
}

fn calcTemp(from: u8, to: u8, temp: f64) !f64 {
    if (from == to) {
        return error.Invalid;
    }
    if (from == 'C') {
        if (to == 'F') { // https://www.youtube.com/watch?v=CpFmg7FCftA
            print("C to F\n", .{});
            return temp * 9 / 5 + 32;
        } else if (to == 'K') {
            print("C to K\n", .{});
            return temp + 273.15;
        } else {
            return error.Invalid;
        }
    } else if (from == 'F') {
        if (to == 'C') {
            print("F to C\n", .{});
            return (temp - 32) * 5 / 9;
        } else if (to == 'K') {
            print("F to K\n", .{});
            return (temp + 459.67) * 5 / 9;
        } else {
            return error.Invalid;
        }
    } else if (from == 'K') { //miluju deti
        if (to == 'C') {
            print("K to C\n", .{});
            return temp - 273.15;
        } else if (to == 'F') {
            print("K to F\n", .{});
            return temp * 9 / 5 - 459.67;
        } else {
            return error.Invalid;
        }
    } else {
        return error.Invalid;
    }
}

fn readLine(buff: []u8) ![]u8 {
    const reader = std.io.getStdIn().reader();
    return buff[0..try reader.read(buff)];
}

test "testConversions" {
    try expect(try calcTemp('C', 'F', 100) == 212);
    try expect(try calcTemp('C', 'K', 100) == 373.15);
    try expect(try calcTemp('F', 'C', 100) == 37.77777777777778);
    try expect(try calcTemp('F', 'K', 100) == 310.9277777777778);
    try expect(try calcTemp('K', 'C', 100) == -173.14999999999998);
    try expect(try calcTemp('K', 'F', 100) == -279.67);
}
