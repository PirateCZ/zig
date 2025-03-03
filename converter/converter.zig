const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var unitBuff: [16]u8 = undefined;
    var tempBuff: [16]u8 = undefined;

    print("Enter units: (C or F)\n", .{});
    const unit: []const u8 = try readLine(&unitBuff);
    print("Enter temperature: \n", .{});
    const temp: []const u8 = try readLine(&tempBuff);

    var temperature: f32 = try std.fmt.parseFloat(f32, std.mem.trim(u8, temp, &std.ascii.whitespace));

    // print("{s} {s}", .{ unit, temp });
    if (std.ascii.toUpper(unit[0]) == 'C') {
        print("From C to F: \n", .{});
        temperature = (temperature * 9.0 / 5.0) + 32.0;
    } else if (std.ascii.toUpper(unit[0]) == 'F') {
        print("From F to C: \n", .{});
        temperature = (temperature - 32.0) * 5.0 / 9.0;
    } else {
        print("Invalid units!\n", .{});
        return;
    }
    print("{d}C \n", .{temperature});
    print("Press ENTER to exit.\n", .{});
    _ = try std.io.getStdIn().reader().readByte();
}

fn readLine(buffer: []u8) ![]const u8 {
    const input = try std.io.getStdIn().reader().read(buffer);
    return buffer[0..input];
}
