const std = @import("std");
const fs = std.fs;

const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const dialMax = 99;

const DialStatus = struct {
    position: u32,
    tickCount: u32,
};

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
    var status = DialStatus{
        .position = 50,
        .tickCount = 0,
    };
    while (try reader.interface.takeDelimiter('\n')) |line| {
        status = processLine(status, line);
        print("New location = {d}, New Ticks = {d}\n", .{ status.position, status.tickCount });
    }

    print("Final password = {d}\n", .{status.tickCount});
}

fn processLine(status: DialStatus, line: []const u8) DialStatus {
    // print("Read line: {s}\n", .{line});
    const direction = line[0];
    print("Found direction {c}\n", .{line[0]});
    const moveAmount = parseInt(u32, line[1..], 10) catch 0;
    if (moveAmount == 0) {
        return status;
    }

    return updateDial(status, moveAmount, direction == 'L');
}

fn updateDial(status: DialStatus, moveAmount: u32, isLeftMove: bool) DialStatus {
    var newTicks = moveAmount / (dialMax + 1);
    var newPosition = status.position;

    const normalizedMove = moveAmount % (dialMax + 1);
    print("Found move amount {d}\n", .{moveAmount});

    if (isLeftMove) {
        if (normalizedMove > status.position) {
            newPosition = (dialMax + 1) - (normalizedMove - status.position);
            if (status.position != 0) {
                newTicks += 1;
            }
        } else {
            newPosition = status.position - normalizedMove;
            if (newPosition == 0) {
                newTicks += 1;
            }
        }
    } else {
        newPosition = status.position + normalizedMove;
        if (newPosition > dialMax) {
            newTicks += 1;
            newPosition = newPosition % (dialMax + 1);
        }
    }

    return DialStatus{
        .position = newPosition % (dialMax + 1),
        .tickCount = status.tickCount + newTicks,
    };
}

test "starts at 0, no ticks" {
    const initialStatus = DialStatus{
        .position = 0,
        .tickCount = 0,
    };
    const newStatusRight = updateDial(initialStatus, 10, false);

    try std.testing.expectEqual(10, newStatusRight.position);
    try std.testing.expectEqual(0, newStatusRight.tickCount);

    const newStatusLeft = updateDial(initialStatus, 10, true);

    try std.testing.expectEqual(90, newStatusLeft.position);
    try std.testing.expectEqual(0, newStatusLeft.tickCount);
}
