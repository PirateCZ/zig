const std = @import("std");
const print = std.debug.print;
const fs = std.fs;

var stayOpen: bool = true;
var taskmngr: taskManager = undefined;
var filemngr: fileManager = undefined;
var file: std.fs.File = undefined;

pub fn main() !void {
    var allocator: std.mem.Allocator = std.heap.page_allocator;
    taskmngr = taskManager.init(&allocator);
    filemngr = try fileManager.init("task.txt");

    try taskmngr.loadFromFiles(&allocator);
    print("--\nSelect action: \n1. List Tasks \n2. Add Task \n3. Remove Task \n4. Change Status \n\n9. Save \n0. Exit \n--\n", .{});
    while (stayOpen) {
        try selectAction();
    }
}

const Task = struct {
    name: []const u8,
    isCompleted: bool = false,
};

const taskManager = struct {
    taskList: std.ArrayList(Task),

    fn init(allocator: *std.mem.Allocator) taskManager {
        return taskManager{
            .taskList = std.ArrayList(Task).init(allocator.*),
        };
    }

    fn listTasks(self: *taskManager) !void {
        for (self.taskList.items, 0..self.taskList.items.len) |task, i| {
            if (task.name[task.name.len - 1] == 'x' or task.name[task.name.len - 1] == '_') {
                print("{d}. {s}", .{ i + 1, task.name[0 .. task.name.len - 1] });
            } else {
                print("{d}. {s}", .{ i + 1, task.name });
            }

            if (task.isCompleted) {
                std.debug.print("\t[x]\n", .{});
            } else {
                std.debug.print("\t[_]\n", .{});
            }
        }
    }

    fn getIndexFromUser(self: *taskManager) !usize {
        const input: []const u8 = try readLine();

        var index: usize = 0;
        for (input) |char| {
            index = index * 10 + @as(usize, char - '0');
        }

        index -= 1;

        if (index > self.taskList.items.len or index < 0) {
            std.debug.print("Invalid: Not a valid index.\n", .{});
            return error.Invalid;
        }

        return index;
    }

    fn addTask(self: *taskManager, allocator: *std.mem.Allocator, text: []const u8) !void {
        const copy = try allocator.*.dupe(u8, text);
        std.debug.print("\"{s}\"", .{copy});
        try self.taskList.append(Task{ .name = copy });
    }

    fn changeTaskStatus(self: *taskManager, index: usize) void {
        self.taskList.items[index].isCompleted = !self.taskList.items[index].isCompleted;
    }

    fn changeTask(self: *taskManager) !void {
        const index = try self.getIndexFromUser();
        self.changeTaskStatus(index);
    }

    fn removeTask(self: *taskManager) !void {
        const index = try self.getIndexFromUser();
        _ = self.taskList.orderedRemove(index);
    }

    fn saveToFile(self: *taskManager) !void {
        try filemngr.creteFile();
        for (self.taskList.items) |item| {
            try filemngr.writeToFile(item);
        }
    }

    fn loadFromFiles(self: *taskManager, allocator: *std.mem.Allocator) !void {
        const fileContent = try filemngr.readFromFile(allocator);
        var complete = false;

        var start: usize = 0;
        var end: usize = 0;
        for (0..fileContent.len) |i| {
            if (fileContent[i] == '\n') {
                if (fileContent[i - 1] == 'x') {
                    complete = true;
                }
                end = i;
                try self.taskList.append(Task{ .name = std.mem.trim(u8, fileContent[start..end], &std.ascii.whitespace), .isCompleted = complete });
                complete = false;
                start = i;
            }
        }
    }
};

const fileManager = struct {
    fileName: []const u8,

    fn init(fileName: []const u8) !fileManager {
        return fileManager{ .fileName = fileName };
    }

    fn creteFile(self: *fileManager) !void {
        try std.fs.cwd().deleteFile(self.fileName);
        file = try std.fs.cwd().createFile(self.fileName, .{});
        defer file.close();
    }

    fn writeToFile(self: *fileManager, task: Task) !void {
        file = try std.fs.cwd().openFile(self.fileName, .{ .mode = .read_write });
        defer file.close();

        try file.seekFromEnd(0);

        if (task.name[task.name.len - 1] == 'x' or task.name[task.name.len - 1] == '_') {
            _ = try file.write(std.mem.trim(u8, task.name[0 .. task.name.len - 1], &std.ascii.whitespace));
        } else {
            _ = try file.write(std.mem.trim(u8, task.name, &std.ascii.whitespace));
        }

        if (task.isCompleted) {
            _ = try file.write("x");
        } else {
            _ = try file.write("_");
        }

        _ = try file.write("\n");
    }

    fn readFromFile(self: *fileManager, allocator: *std.mem.Allocator) ![]const u8 {
        file = try std.fs.cwd().openFile(self.fileName, .{ .mode = .read_write });
        defer file.close();

        const file_size = (try file.stat()).size;
        var buffer = try allocator.*.alloc(u8, file_size);
        const bytes_read = try file.reader().readAll(buffer);
        const fileContent = buffer[0..bytes_read];
        return fileContent;
    }
};

fn selectAction() !void {
    var allocator = std.heap.page_allocator;
    std.debug.print("Select action: \n", .{});
    const input: []const u8 = try readLine();

    if (input.len == 0) {
        std.debug.print("Invalid: Put something in.\n", .{});
        return;
    }

    if (input[0] == '1') {
        print("The list of tasks: \n", .{});
        try taskmngr.listTasks();
        std.debug.print("\n", .{});
    } else if (input[0] == '2') {
        print("Add a task: \n", .{});
        try taskmngr.addTask(&allocator, try readLine());
        std.debug.print("\n", .{});
    } else if (input[0] == '3') {
        std.debug.print("Remove task: \n", .{});
        try taskmngr.listTasks();
        try taskmngr.removeTask();
    } else if (input[0] == '4') {
        std.debug.print("Choose task to complete \n", .{});
        try taskmngr.listTasks();
        try taskmngr.changeTask();
    } else if (input[0] == '9') {
        try taskmngr.saveToFile();
        std.debug.print("Saved.\n", .{});
    } else if (input[0] == '0') {
        std.debug.print("Exiting...", .{});
        stayOpen = false;
    } else {
        print("Invalid: It has to be a number.\n", .{});
    }
}

fn readLine() ![]const u8 {
    var buff: [64]u8 = undefined;
    const bytes_read = try std.io.getStdIn().reader().read(&buff);
    return std.mem.trim(u8, buff[0..bytes_read], &std.ascii.whitespace);
}
