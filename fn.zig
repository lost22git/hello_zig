///usr/bin/env zig test -freference-trace "$0" "$@" ; exit $?
const std = @import("std");
const testing = std.testing;

fn ptrArgs(a: *u32) void {
    _ = a;
}

fn ptrArgs2(a: *const u32) void {
    _ = a;
}

fn functionPtrArgs(f: *const fn (x: u32) void) *const fn (x: u32) void {
    return f;
}

fn genericArgs(T: type, a: T) T {
    _ = a;
}

fn anytypeArgs(a: anytype) void {
    _ = a;
}

fn anytypeArgs2(a: anytype, b: @TypeOf(a)) void {
    _ = b;
}

fn inferReturnTypeByArgs(a: anytype) switch (@typeInfo(@TypeOf(a))) {
    .Pointer => |ptr| ptr.child,
    else => void,
} {}

fn comptimeArgs(comptime a: []const u8) void {
    _ = a;
}
