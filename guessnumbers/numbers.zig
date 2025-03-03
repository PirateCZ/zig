const std = @import("std");
const trim = std.mem.trim;
const print = std.debug.print;
const RndGen = std.rand.DefaultPrng;

pub fn main() !void {
    var rnd = RndGen.init(@intCast(std.time.milliTimestamp()));
    const reader = std.io.getStdIn().reader();
    const rnd_num = rnd.random().intRangeAtMost(u8, 1, 100);
    var buffer: [32]u8 = undefined;
    const number_of_gueses = 10;

    print("Guess the number: (1 - 100)\n", .{});

    var bytes_read: usize = undefined;
    var guess: u8 = undefined;
    for (1..number_of_gueses) |i| {
        print("{d}. guess: \n", .{i});
        bytes_read = try reader.read(&buffer);
        guess = try std.fmt.parseInt(u8, std.mem.trim(u8, buffer[0..bytes_read], &std.ascii.whitespace), 10);
        if (guess < rnd_num) {
            print("Too small. Try again!\n", .{});
        } else if (guess > rnd_num) {
            print("Too big. Try again!\n", .{});
        } else {
            print("You guessed it!\n", .{});
            return;
        }
    }
    print("You lost!", .{});
}
