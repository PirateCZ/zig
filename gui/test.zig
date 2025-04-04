const std = @import("std");
const math = std.math;

const Vec2 = struct {
    x: f64,
    y: f64,

    pub fn add(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn scale(v: Vec2, s: f64) Vec2 {
        return .{ .x = v.x * s, .y = v.y * s };
    }

    pub fn dot(a: Vec2, b: Vec2) f64 {
        return a.x * b.x + a.y * b.y;
    }
};

const Particle = struct {
    mass: f64,
    velocity: Vec2,
    position: Vec2,

    pub fn applyImpulse(self: *Particle, impulse: Vec2) void {
        self.velocity = Vec2.add(self.velocity, Vec2.scale(impulse, 1.0 / self.mass));
    }
};

pub fn computeImpulse(a: *Particle, b: *Particle, normal: Vec2, restitution: f64) Vec2 {
    const relative_velocity = Vec2.sub(b.velocity, a.velocity);
    const contact_velocity = Vec2.dot(relative_velocity, normal);

    if (contact_velocity > 0) return .{ .x = 0, .y = 0 }; // Objects moving apart

    const denom = (1.0 / a.mass) + (1.0 / b.mass);

    const j = -(1 + restitution) * contact_velocity / denom;
    return Vec2.scale(normal, j);
}

pub fn main() void {
    var particleA = Particle{ .mass = 2.0, .velocity = .{ .x = 1.0, .y = 0.0 }, .position = .{ .x = 0.0, .y = 0.0 } };
    var particleB = Particle{ .mass = 2.0, .velocity = .{ .x = -1.0, .y = 0.0 }, .position = .{ .x = 2.0, .y = 0.0 } };

    const normal = .{ .x = 1.0, .y = 0.0 };
    const restitution = 0.8;

    const impulse = computeImpulse(&particleA, &particleB, normal, restitution);

    particleA.applyImpulse(Vec2.scale(impulse, -1.0));
    particleB.applyImpulse(impulse);
}
