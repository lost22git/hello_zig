///usr/bin/env zig test -freference-trace "$0" "$@" ; exit $?
const std = @import("std");
const testing = std.testing;
const io = std.io;

test "get slice reader" {
    const s = "hello";

    var fixedBufferStream = io.fixedBufferStream(s);
    var reader = fixedBufferStream.reader();

    try testing.expectEqualDeep('h', reader.readByte());
    try testing.expectEqualDeep('e', reader.readByte());
    try testing.expectEqualDeep('l', reader.readByte());
    try testing.expectEqualDeep('l', reader.readByte());
    try testing.expectEqualDeep('o', reader.readByte());
    try testing.expectError(error.EndOfStream, reader.readByte());
}

test "get arraylist reader" {
    const allocator = testing.allocator;

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    var writer = list.writer();
    try writer.writeAll("hello");

    var fixedBufferStream = io.fixedBufferStream(list.items);
    var reader = fixedBufferStream.reader();

    try testing.expectEqualDeep('h', reader.readByte());
    try testing.expectEqualDeep('e', reader.readByte());
    try testing.expectEqualDeep('l', reader.readByte());
    try testing.expectEqualDeep('l', reader.readByte());
    try testing.expectEqualDeep('o', reader.readByte());
    try testing.expectError(error.EndOfStream, reader.readByte());
}
