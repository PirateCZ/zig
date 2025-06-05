const std = @import("std");
const rl = @import("raylib");
const Vector2 = @import("vector.zig").Vector2;
const Particle = @import("particle.zig").Particle;
var world: World = undefined;
var last_time: i64 = undefined;
pub var delta: f32 = undefined;
pub fn main() !void {
    rl.initWindow(1280, 720, "Particle Simulation");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var allocator = std.heap.page_allocator;
    world = World.init(&allocator);
    var circle1 = Particle{ .position = Vector2{ .x = 640, .y = 0 }, .radius = 10.0, .mass = 1, .coefResistance = 0.47, .coefRestitution = -0.5 };
    var circle2 = Particle{ .position = Vector2{ .x = 640, .y = 100 }, .radius = 10.0, .mass = 1, .coefResistance = 0.47, .coefRestitution = -0.5 };

    try world.particles.append(&circle1);
    try world.particles.append(&circle2);

    last_time = std.time.milliTimestamp();

    while (!rl.windowShouldClose()) {
        delta = @floatCast(getDeltaTime());
        for (world.particles.items) |circle| {
            circle.*.update(delta);

            for (world.particles.items) |particle| {
                if (circle == particle) {
                    continue;
                } else if (Vector2.length(Vector2.sub(circle.position, particle.position)) < circle.radius + particle.radius) {
                    std.debug.print("Collision!\n", .{});
                    //here we put what we learned from the paper
                }
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        for (world.particles.items) |circle| {
            rl.drawCircle(@intFromFloat(circle.*.position.x), @intFromFloat(circle.*.position.y), circle.*.radius, rl.Color.black);
        }

        rl.drawFPS(1200, 700);
    }
}

pub fn getDeltaTime() f64 {
    const current_time = std.time.milliTimestamp();
    const delta_time: f64 = @as(f64, @floatFromInt(current_time - last_time)) / 1000.0;
    last_time = current_time;
    return delta_time;
}

const World = struct {
    particles: std.ArrayList(*Particle),

    fn init(allocator: *std.mem.Allocator) World {
        return World{
            .particles = std.ArrayList(*Particle).init(allocator.*),
        };
    }
};
