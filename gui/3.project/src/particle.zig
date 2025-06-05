const std = @import("std");
const Vector2 = @import("vector.zig").Vector2;

pub const Particle = struct {
    radius: f32,
    position: Vector2,

    velocity: Vector2 = Vector2.zero(),
    acceleration: Vector2 = Vector2.zero(),

    mass: f32,
    force: Vector2 = Vector2.zero(),

    coefRestitution: f32,
    coefResistance: f32 = 0.0,

    pub fn update(self: *Particle, delta: f32) void {
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
    }
};
