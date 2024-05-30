const std = @import("std");
const known = @import("known-folders");

pub fn main() !void {
    const j = try known.getPath(std.heap.page_allocator, .home) orelse {
        std.debug.print("Womp womp.\n", .{});
        return error.CouldNotFindHome;
    };

    std.debug.print("~ is where the heart is -- or {s}.\n", .{j});
}
