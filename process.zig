///usr/bin/env zig test -freference-trace "$0" "$@" ; exit $?
const std = @import("std");
const testing = std.testing;

test "get cwd path" {
    const allocator = testing.allocator;

    const cwdPath = try std.process.getCwdAlloc(allocator);
    defer allocator.free(cwdPath);

    std.debug.print("cwd path: {s}\n", .{cwdPath});
}

// test "get env vars" {
//     const allocator = testing.allocator;
//
//     const hasPath = try std.process.hasEnvVar(allocator, "path");
//
//     if (hasPath) {
//         const path = try std.process.getEnvVarOwned(allocator, "path");
//         defer allocator.free(path);
//
//         var iter = std.mem.splitAny(u8, path, ";");
//         while (iter.next()) |elm| {
//             std.debug.print("{s}\n", .{elm});
//         }
//     }
// }

test "run cmd success" {
    const allocator = testing.allocator;

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "zen" },
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqual(0, result.term.Exited);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "Edge cases matter") != null);
    try testing.expectEqualStrings("", result.stderr);
}

test "run cmd failed" {
    const allocator = testing.allocator;

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "-asdfak" },
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqual(1, result.term.Exited);
    try testing.expectEqualStrings("", result.stdout);
    try testing.expect(std.mem.indexOf(u8, result.stderr, "error") != null);
}

test "run cmd not found" {
    const allocator = testing.allocator;

    const cmdResult = std.process.Child.run(.{ .allocator = allocator, .argv = &[_][]const u8{"zigg"} });
    try testing.expectError(error.FileNotFound, cmdResult);
}

test "run shell cmd" {
    const allocator = testing.allocator;

    const builtin = @import("builtin");

    const cmd = "zig -sdfs 2>&1";

    const shellCmd = switch (builtin.os.tag) {
        .windows => [_][]const u8{ "pwsh", "-NoProfile", "-NoLogo", "-Command", cmd },
        else => [_][]const u8{ "sh", "-c", cmd },
    };

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &shellCmd,
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqual(1, result.term.Exited);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "error") != null);
    try testing.expectEqualStrings("", result.stderr);
}
