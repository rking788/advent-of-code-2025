const std = @import("std");
const fs = std.fs;

const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const dialMax = 99;

pub fn main() !void {
    try run();
}

fn run() !void {
    const file = try fs.cwd().openFile("part1.txt", .{});
    // const file = try fs.cwd().openFile("sample.txt", .{});
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);
    // Start dial location at 50
    var loc: u32 = 50;
    var zeroCount: u32 = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        loc = processLine(loc, line);
        if (loc == 0) {
            zeroCount += 1;
        }
        print("New location = {d}\n", .{loc});
    }

    print("Final password = {d}\n", .{zeroCount});
}

fn processLine(currentPosition: u32, line: []const u8) u32 {
    // print("Read line: {s}\n", .{line});
    const direction = line[0];
    print("Found direction {c}\n", .{line[0]});
    const moveAmount = parseInt(u32, line[1..], 10) catch 0;
    if (moveAmount == 0) {
        return currentPosition;
    }
    const normalizedMove = moveAmount % (dialMax + 1);
    print("Found move amount {d}\n", .{moveAmount});

    var newPosition: u32 = 0;
    if (direction == 'L') {
        if (normalizedMove > currentPosition) {
            newPosition = (dialMax + 1) - (normalizedMove - currentPosition);
        } else {
            newPosition = currentPosition - normalizedMove;
        }
    } else {
        newPosition = currentPosition + normalizedMove % (dialMax + 1);
    }

    return newPosition % (dialMax + 1);
}
