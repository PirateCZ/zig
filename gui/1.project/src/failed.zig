const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(1280, 720, "Circles");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var allocator = std.heap.page_allocator;
    var world = World.init(&allocator);
    try world.addBody(Body{ .position = Vector2{ .x = 640, .y = 360 }, .rotation = 0, .velocity = 0, .angularVelocity = 0, .force = Vector2{ .x = 0, .y = 0 }, .torque = 0, .mass = 0, .inertia = 0, .gravity = 10, .coefFriction = 0, .coefRestitution = 0, .shape = Shape.circle });
    try world.addBody(Body{ .position = Vector2{ .x = 640, .y = 360 }, .rotation = 0, .velocity = 0, .angularVelocity = 0, .force = Vector2{ .x = 0, .y = 0 }, .torque = 0, .mass = 0, .inertia = 0, .gravity = 10, .coefFriction = 0, .coefRestitution = 0, .shape = Shape.circle });

    while (!rl.windowShouldClose()) {
        world.update(16);
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawCircle(@intFromFloat(world.bodies.items[0].position.x), @intFromFloat(world.bodies.items[0].position.y), 50.0, rl.Color.black);
    }
}

const Shape = enum {
    square,
    circle,
    triangle,
};

const World = struct {
    bodies: std.ArrayList(Body),

    fn init(allocator: *std.mem.Allocator) World {
        return World{ .bodies = std.ArrayList(Body).init(allocator.*) };
    }

    fn update(self: *World, deltaTime: i32) void {
        for (0..self.bodies.items.len - 1) |i| {
            self.bodies.items[i].update(deltaTime);
        }
    }

    fn addBody(self: *World, body: Body) !void {
        try self.bodies.append(body);
    }
};

const Body = struct {
    position: Vector2,
    rotation: f32,

    velocity: f32,
    angularVelocity: f32,

    force: Vector2,
    torque: f32,

    mass: f32,
    inertia: f32,

    gravity: f32,
    coefFriction: f32,
    coefRestitution: f32,

    shape: Shape,

    fn update(self: *Body, deltaTime: i32) void {
        const acceleration: Vector2 = self.force / self.mass + self.gravity;
        self.velocity += acceleration * deltaTime;
        self.position += self.velocity * deltaTime;

        const angularAcceleration: Vector2 = self.torque / self.inertia;
        self.angularVelocity += angularAcceleration;
        self.rotation += self.angularVelocity * deltaTime;

        self.force = Vector2.Zero;
        self.torque = 0;
    }
};

const Vector2 = struct {
    x: f32,
    y: f32,

    fn length(self: *Vector2) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }

    fn sqrtLength(self: *Vector2) f32 {
        return self.x * self.x + self.y * self.y;
    }

    fn normalize(self: *Vector2) void {
        const inv_len = 1 / self.length();
        self.x *= inv_len;
        self.y *= inv_len;
    }

    fn mult(v: Vector2, s: f32) Vector2 {
        return Vector2{ .x = v.x * s, .y = v.y * s };
    }

    fn dot(a: Vector2, b: Vector2) f32 {
        return a.x * b.x + a.y * b.y;
    }

    fn cross(a: Vector2, b: Vector2) f32 {
        return a.x * b.y - a.y * b.x;
    }
};

const Matrix2 = struct {
    m00: f32,
    m01: f32,
    m10: f32,
    m11: f32,

    fn set(self: *Matrix2, radians: f32) void {
        const cosine: f32 = std.math.cos(radians);
        const sine: f32 = std.math.sin(radians);

        self.m00 = cosine;
        self.m01 = -sine;
        self.m10 = sine;
        self.m11 = -cosine;
    }

    fn transpose(self: *Matrix2) Matrix2 {
        return Matrix2{ .m00 = self.m00, .m01 = self.m10, .m10 = self.m01, .m11 = self.m11 };
    }

    fn multVecMat(mat: Matrix2, vec: Vector2) Vector2 {
        return Vector2{ .y = mat.m00 * vec.x + mat.m01 * vec.y, .x = mat.m10 * vec.x + mat.m11 * vec.y };
    }
    fn multMat(mat1: Matrix2, mat2: Matrix2) Matrix2 {
        return Matrix2{ .m00 = mat1.m00 * mat2.m00 + mat1.m01 * mat2.m10, .m01 = mat1.m00 * mat2.m01 + mat1.m01 * mat2.m11, .m10 = mat1.m10 * mat2.m00 + mat1.m11 * mat2.m10, .m11 = mat1.m10 * mat2.m01 + mat1.m11 * mat2.m11 };
    }
};
