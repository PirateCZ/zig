const std = @import("std");
const rl = @import("raylib");
const Vector2 = @import("./vector.zig").Vector2;
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
    var circle2 = Particle{ .position = Vector2{ .x = 640, .y = 100 }, .radius = 10.0, .mass = 0.1, .coefResistance = 0.47, .coefRestitution = -0.5 };

    try world.particles.append(&circle1);
    try world.particles.append(&circle2);

    last_time = std.time.milliTimestamp();

    while (!rl.windowShouldClose()) {
        delta = @as(f32, @floatCast(getDeltaTime()));
        for (world.particles.items) |circle| {
            circle.*.update();
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

fn getDeltaTime() f64 {
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

const Particle = struct {
    radius: f32,
    position: Vector2,

    velocity: Vector2 = Vector2.zero(),
    acceleration: Vector2 = Vector2.zero(),

    mass: f32,
    force: Vector2 = Vector2.zero(),

    coefRestitution: f32,
    coefResistance: f32 = 0.0,

    fn update(self: *Particle) void {
        const rho = 1.2; //1000 for water;
        self.force = Vector2.zero();

        self.force = Vector2.add(self.force, Vector2{ .x = 0, .y = self.mass * 9.80665 });

        self.force = Vector2.add(self.force, Vector2.mult(Vector2.dot(self.velocity, self.velocity), -1 * 0.5 * rho * self.coefResistance * (std.math.pi * self.radius * self.radius / 10_000)));

        const distance: Vector2 = Vector2.add(
            Vector2.mult(self.velocity, delta),
            Vector2.mult(self.acceleration, 0.5 * delta * delta),
        );

        self.position = Vector2.add(self.position, Vector2.mult(distance, 100));

        const newAcceleration: Vector2 = Vector2.mult(self.force, 1 / self.mass);

        const avgAcceleration: Vector2 = Vector2.mult(Vector2.add(self.acceleration, newAcceleration), 0.5);

        self.velocity = Vector2.add(self.velocity, Vector2.mult(avgAcceleration, delta));

        self.acceleration = newAcceleration;

        if (self.position.y + self.radius > 720 and self.velocity.y > 0) {
            self.velocity = Vector2.mult(self.velocity, self.coefRestitution);

            self.position = Vector2{ .x = self.position.x, .y = 720 - self.radius };
        }

        for (world.particles.items) |particle| {
            if (self == particle) {
                continue;
            } else if (Vector2.length(Vector2.sub(self.position, particle.position)) < self.radius + particle.radius) {
                std.debug.print("Collision\n", .{});
                var impulse: Vector2 = undefined;
                const relativeVelocity = Vector2.sub(particle.velocity, self.velocity);
                const contactVelocity = Vector2.dot(relativeVelocity, Vector2{ .x = 1, .y = 0 }).x + Vector2.dot(relativeVelocity, Vector2{ .x = 1, .y = 0 }).y;
                if (contactVelocity > 0) {
                    impulse = Vector2{ .x = 0, .y = 0 };
                }
                const denom = (1.0 / self.mass) + (1.0 / particle.mass);
                const j = -(1 + self.coefRestitution) * contactVelocity / denom;
                impulse = Vector2.mult(Vector2{ .x = 1, .y = 0 }, j);
                self.velocity = Vector2.add(self.velocity, Vector2.mult(Vector2.mult(impulse, -1), 1 / self.mass));
                particle.velocity = Vector2.add(particle.velocity, Vector2.mult(impulse, 1 / self.mass));
            }
        }
    }
};
