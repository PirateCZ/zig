const std = @import("std");
const sqrt = std.math.sqrt;
const cos = std.math.cos;
const sin = std.math.sin;

pub const Vector2 = struct {
    x: f32,
    y: f32,

    pub fn zero() Vector2 {
        return Vector2{ .x = 0, .y = 0 };
    }

    pub fn length(self: Vector2) f32 {
        return sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn add(vec1: Vector2, vec2: Vector2) Vector2 {
        return Vector2{ .x = vec1.x + vec2.x, .y = vec1.y + vec2.y };
    }

    pub fn sub(vec1: Vector2, vec2: Vector2) Vector2 {
        return Vector2{ .x = vec1.x - vec2.x, .y = vec1.y - vec2.y };
    }

    pub fn mult(vec: Vector2, scaler: f32) Vector2 {
        return Vector2{
            .x = vec.x * scaler,
            .y = vec.y * scaler,
        };
    }

    pub fn dot(vec1: Vector2, vec2: Vector2) Vector2 {
        return Vector2{ .x = vec1.x * vec2.x, .y = vec1.y * vec2.y };
        //return dox.x + dox.y;
    }

    pub fn cross(vec1: Vector2, vec2: Vector2) Vector2 {
        return Vector2{ .x = vec1.x * vec2.y, .y = vec1.y * vec2.x };
    }

    pub fn rotate(self: *Vector2, angle: f32, vec: Vector2) Vector2 {
        const x = self.x - vec.x;
        const y = self.y - vec.y;

        const x_prime = vec.x + ((x * cos(angle)) - (y * sin(angle)));
        const y_prime = vec.y + ((x * sin(angle)) + (y * cos(angle)));

        return Vector2{ .x = x_prime, .y = y_prime };
    }

    pub fn normalize(v: Vector2) Vector2 {
        const len = Vector2.length(v);
        if (len == 0) {
            return Vector2{ .x = 0, .y = 0 };
        }
        return Vector2.mult(v, 1.0 / len);
    }
};
