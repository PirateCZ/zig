const Vector2 = @import("./vector.zig").Vector2;

pub const Rectangle = struct {
    width: f32,
    height: f32,

    topLeft: Vector2,
    topRight: Vector2,
    bottomLeft: Vector2,
    bottomRight: Vector2,

    velocity: Vector2 = Vector2.zero(),
    acceleration: Vector2 = Vector2.zero(),

    rotation: f32 = 0,
    angular_velocity: f32 = 0,
    angular_acceleration: f32 = 0,

    mass: f32,
    force: Vector2 = Vector2.zero(),
    torque: f32 = 0,

    J: f32,

    pub fn init(x: f32, y: f32, w: f32, h: f32, m: f32) Rectangle {
        return Rectangle{
            .width = w,
            .height = h,
            .topLeft = Vector2{ .x = x, .y = y },
            .topRight = Vector2{ .x = x + w, .y = y },
            .bottomLeft = Vector2{ .x = x, .y = y + h },
            .bottomRight = Vector2{ .x = x + w, .y = y + h },
            .mass = m,
            .J = m * (h * h + w * w) / 12_000,
        };
    }

    pub fn center(self: *Rectangle) Vector2 {
        const diagonal = Vector2.sub(self.bottomRight, self.topLeft);
        const midpoint = Vector2.add(self.topLeft, Vector2.mult(diagonal, 0.5));
        return midpoint;
    }

    pub fn rotate(self: *Rectangle, angle: f32) void {
        const c = self.center();
        self.rotation += angle; //* 180 / std.math.pi;
        self.topLeft = self.topLeft.rotate(angle, c);
        self.topRight = self.topRight.rotate(angle, c);
        self.bottomLeft = self.bottomLeft.rotate(angle, c);
        self.bottomRight = self.bottomRight.rotate(angle, c);
    }

    pub fn move(self: *Rectangle, vec: Vector2) void {
        self.topLeft = Vector2.add(self.topLeft, vec);
        self.topRight = Vector2.add(self.topRight, vec);
        self.bottomLeft = Vector2.add(self.bottomLeft, vec);
        self.bottomRight = Vector2.add(self.bottomRight, vec);
    }

    pub fn update(self: *Rectangle) void {
        const delta = @import("./main.zig").delta;
        self.force = Vector2.zero();
        self.torque = 0;
        self.move(Vector2.mult(Vector2.add(Vector2.mult(self.velocity, delta), Vector2.mult(self.acceleration, 0.5 * delta * delta)), 100));
        self.force = Vector2.add(self.force, Vector2{ .x = 0, .y = self.mass * 9.81 });
        self.force = Vector2.add(self.force, Vector2.mult(self.velocity, -1));

        const spring = Vector2{ .x = 200, .y = 0 };
        const springForce = Vector2.mult(Vector2.sub(self.topLeft, spring), -1 * 0.5);
        const r = Vector2.sub(self.center(), self.topLeft);
        const rxf = Vector2.cross(r, springForce);

        self.torque += -1 * (rxf.x - rxf.y);
        self.force = Vector2.add(self.force, springForce);

        const new_acce = Vector2.mult(self.force, 1 / self.mass);
        const dv = Vector2.mult(Vector2.add(self.acceleration, new_acce), 0.5 * delta);
        self.velocity = Vector2.add(self.velocity, dv);

        self.torque += self.angular_velocity * -7;
        self.rotation = self.torque / self.J;
        self.angular_velocity += self.rotation * delta;
        const deltaTheta = self.angular_velocity * delta;
        self.rotate(deltaTheta);
    }
};
