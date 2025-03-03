const std = @import("std");
const print = std.debug.print;
const aloctation = std.mem.Allocator;
const fs = std.fs;
// const RndGen = std.rand.DefaultPrng;

pub fn main() !void {
    print("Welcome in the Testing Grounds\n", .{});
    //const alocator = std.mem.Allocator.init();
    var list1 = std.ArrayList(u8).init(std.heap.page_allocator);
    try list1.append('8');
    
    for(list1.items) |x|{
        print("{c}", .{x});
    }















    // const filename = "example.txt";
    // var file = try fs.cwd().createFile(filename, .{.read = true});
    // defer file.close();
    
    // try file.writeAll("Hello World!");
    
    // var readFile = try fs.cwd().openFile(filename, .{});
    // defer readFile.close();

    // var buffer: [100]u8 = undefined;
    // const bytes_read = try readFile.readAll(&buffer);
    // print("{s}", .{buffer[0..bytes_read]});




















    //var buffer: [8]u8 = undefined;
    //var rnd = RndGen.init(0);
    //const rnd_num = rnd.random().intRangeAtMost(i32, 1, 100);
    //print("{}", .{rnd_num});
    // print("Nu1: {};", .{try std.fmt.parseInt(i32, std.mem.trim(u8, try readLine(&buffer), &std.ascii.whitespace), 10)});
}

// fn readLine(buffer: []u8) ![]const u8 {
//     const input = try std.io.getStdIn().reader().read(buffer);
//     return buffer[0..input];
// }
