const std = @import("std");
const print = std.debug.print;
const errorSet = error{ InvalidOperator, DivisionByZero };

pub fn main() !void {
    var buffer: [16]u8 = undefined;
    var opbuffer: [16]u8 = undefined;

    var result: f64 = undefined;
    print("Calculator! \n", .{});

    print("Enter first number: \n", .{});
    const num1 = try std.fmt.parseFloat(f64, std.mem.trim(u8, try readLine(&buffer), &std.ascii.whitespace));

    print("Choose operation: (+, -, *, /)\n", .{});
    const operator: []const u8 = try readLine(&opbuffer);

    print("Enter second number: \n", .{});
    const num2 = try std.fmt.parseFloat(f64, std.mem.trim(u8, try readLine(&buffer), &std.ascii.whitespace));

    result = try calculate(num1, num2, operator[0]);
    print("{d} {c} {d} = {d}\n", .{ num1, operator[0], num2, result });

    print("Press ENTER to exit.\n", .{});
    _ = try std.io.getStdIn().reader().readByte();
}

fn calculate(num1: f64, num2: f64, operator: u8) !f64 {
    if (operator == '+') {
        return addition(num1, num2);
    } else if (operator == '-') {
        return subtraction(num1, num2);
    } else if (operator == '*') {
        return multiplication(num1, num2);
    } else if (operator == '/') {
        return try division(num1, num2);
    } else {
        print("Invalid operation!", .{});
        return errorSet.InvalidOperator;
    }
}

fn addition(num1: f64, num2: f64) f64 {
    return num1 + num2;
}

fn subtraction(num1: f64, num2: f64) f64 {
    return num1 - num2;
}

fn multiplication(num1: f64, num2: f64) f64 {
    return num1 * num2;
}

fn division(num1: f64, num2: f64) !f64 {
    if (num2 == 0) {
        print("Division by Zero", .{});
        return errorSet.DivisionByZero;
    } else {
        return num1 / num2;
    }
}

fn readLine(buffer: []u8) ![]const u8 {
    const input = try std.io.getStdIn().reader().read(buffer);
    return buffer[0..input];
}
