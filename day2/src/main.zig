const std = @import("std");
const fs = std.fs;
const parseInt = std.fmt.parseInt;

const Range = struct {
    lower: u64,
    upper: u64
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var part1Ranges = try readRanges(allocator, "part1.txt");
    defer part1Ranges.deinit(allocator);
    const part1Solution = try part1(part1Ranges);
    std.debug.print("part1 solution: {d}\n", .{part1Solution});

    // var part2Ranges = try readRanges(allocator, "part1.txt");
    // defer part2Ranges.deinit(allocator);
    // const part2Solution = part2(part2Ranges);
    // std.debug.print("part2 solution: {d}\n", .{part2Solution});
}

fn readRanges(allocator: std.mem.Allocator, filename: []const u8) !std.ArrayList(Range) {
    const file = try fs.cwd().openFile(filename, .{});
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);

    const line = try reader.interface.takeDelimiter('\n') orelse return std.ArrayList(Range).empty;


    var ranges: std.ArrayList(Range) = .{};

    var it = std.mem.splitScalar(u8, line, ',');
    while (it.next()) |rangeSpec| {
        var rangeIt = std.mem.splitScalar(u8, rangeSpec, '-');
        const lower = parseInt(u64, rangeIt.next() orelse return std.ArrayList(Range).empty, 10) catch 0;
        const upper = parseInt(u64, rangeIt.next() orelse return std.ArrayList(Range).empty, 10) catch 0;
        if (lower == 0 or upper == 0) {
            std.debug.print("Invalid range bound found\n", .{});
            return std.ArrayList(Range).empty;
        }
        const range = Range {
            .lower = lower,
            .upper = upper,
        };

        try ranges.append(allocator, range);
        std.debug.print("range found lower={d}, upper={d}\n", .{range.lower, range.upper});
    }

    return ranges;
}

fn part1(ranges: std.ArrayList(Range)) !u64 {

    var total: u64 = 0;
    for (ranges.items) |range| {
        for (range.lower..range.upper+1) |productId| {
            // std.debug.print("productId = {d}\n", .{productId});
            if (!try isProductIDValid(productId)) {
                // std.debug.print("Invalid\n", .{});
                total += productId;
            } else {
                // std.debug.print("Valid\n", .{});
            }
        }
        // break;
    }

    return total;
}

fn isProductIDValid(id: u64) !bool {
    const productIDString = try std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{id});
    if ((productIDString.len % 2) != 0) {
        return true;
    } else if (productIDString.len == 2) {
        // std.debug.print("char[0]={c}, char[1]={c}\n", .{productIDString[0], productIDString[1]});
        return productIDString[0] != productIDString[1];
    }

    // [2, 1, 2, 1, 2, 1, 2, 1, 2, 1]
    // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    const midpoint = productIDString.len / 2;
    for (0..midpoint) |index| {
        // std.debug.print("Comparing char[{d}]={c} to char[{d}]={c}\n", .{index, productIDString[index], index+midpoint, productIDString[index+midpoint]});
        if (productIDString[index] != productIDString[index + midpoint]) {
            return true;
        }
    }

    return false;
}


test "invalid test ID" {
    // try std.testing.expectEqual(false, isProductIDValid(2121212121));

    try std.testing.expectEqual(false, isProductIDValid(38593859));
    try std.testing.expectEqual(false, isProductIDValid(1188511885));
}

fn part2(ranges: std.ArrayList(Range)) u64 {
    return ranges.items.len;
}