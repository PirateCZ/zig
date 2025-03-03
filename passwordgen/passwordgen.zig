const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const print = std.debug.print;

pub fn main() void{
    var rnd = RndGen.init(@intCast(std.time.milliTimestamp()));
    const alphabet: []const u8 = "qwertzuiopasdfghjklyxcvbnm";
    const nums: []const u8 = "1234567890";
    const special_chars: []const u8 = "#_";
    const length = 10; 

    var password: [length]u8 = undefined;
    for(0..length) |i|{
        const rnd_index1 = rnd.random().intRangeAtMost(u16, 0, 100);
        if(rnd_index1 < 20) {
            const rnd_index2 = rnd.random().intRangeAtMost(u16, 0, special_chars.len-1);
            password[i] = special_chars[rnd_index2];
        }
        else if(rnd_index1 < 80){
            const rnd_index2 = rnd.random().intRangeAtMost(u16, 0, alphabet.len-1);
            password[i] = alphabet[rnd_index2];
        }
        else { 
            const rnd_index2 = rnd.random().intRangeAtMost(u16, 0, nums.len-1);
            password[i] = nums[rnd_index2];
        }
    }
    print("{s}", .{password});
}