///usr/bin/env zig test "$0" "$@" ; exit $?
const std = @import("std");
const testing = std.testing;
const mem = std.mem;

test "multi-line string" {
    const s =
        \\{
        \\    "foo": "bar"
        \\}
    ;

    std.debug.print("{s}\n", .{s});
}

test "string bytes len" {
    const a = "你好";
    // bytes len
    try testing.expectEqual(a.len, 3 * 2);
}

test "string utf8 len" {
    const a = "你好";
    // utf8 len
    try testing.expectEqual(try std.unicode.utf8CountCodepoints(a), 2);
}

test "string is valid utf8 encoded" {
    try testing.expect(std.unicode.utf8ValidateSlice("你好"));
    try testing.expect(std.unicode.utf8ValidateSlice("helo"));
}

test "string is null-terminated" {
    const a = "你好";
    const last_byte = a[a.len];

    try testing.expectEqual(last_byte, 0);
}

test "string equal" {
    const a = "你好";
    const b = "你好";

    try testing.expect(mem.eql(u8, a, b));
}

test "string compare" {
    const a = "foo";
    const b = "fooo";

    // a < b
    try testing.expect(mem.order(u8, a, b) == std.math.Order.lt);
    try testing.expect(mem.lessThan(u8, a, b));
}

test "string concat" {
    const a = "你好";
    const b = "世界";
    const c = a ++ b;

    try testing.expectEqualStrings(c, "你好世界");
}

test "string repeat" {
    const a = "f";
    try testing.expectEqualStrings(a ** 3, "fff");
}

test "string slice" {
    const a = "你好，世界";
    const slice = a[0..(3 * 2)];

    try testing.expectEqualStrings(slice, "你好");
    try testing.expectEqual(slice.ptr, a);
    try testing.expectEqual(slice.len, 3 * 2);
}

test "string isBlank" {
    const a = " \t \r\n \t  ";
    try testing.expect(isBlank(a));

    const b = "  h ";
    try testing.expect(!isBlank(b));
}

fn isBlank(s: []const u8) bool {
    for (s) |c| {
        if (!std.ascii.isWhitespace(c)) return false;
    }
    return true;
}

test "string trim" {
    const a = " 你好 ";
    try testing.expectEqualStrings(mem.trim(u8, a, " "), "你好");
    try testing.expectEqualStrings(mem.trimLeft(u8, a, " "), "你好 ");
    try testing.expectEqualStrings(mem.trimRight(u8, a, " "), " 你好");

    try testing.expectEqualStrings(mem.trim(u8, "<你好>", "<>"), "你好");
}

test "string byte indexof" {
    const a = "hello";

    try testing.expectEqual(mem.indexOf(u8, a, "l").?, 2);
    try testing.expectEqual(mem.lastIndexOf(u8, a, "l").?, 3);

    try testing.expect(mem.indexOf(u8, a, "k") == null);
    try testing.expect(mem.lastIndexOf(u8, a, "k") == null);
}

test "string utf8 indexof" {
    const s = "你好好的";

    try testing.expectEqual(try utf8IndexOf(s, "好"), 1);
    try testing.expectEqual(try utf8LastIndexOf(s, "好"), 2);
}

fn utf8IndexOf(s: []const u8, find: []const u8) !?usize {
    var result: ?usize = null;

    var utf8 = (try std.unicode.Utf8View.init(s)).iterator();

    var i: usize = 0;
    while (utf8.nextCodepointSlice()) |slice| {
        if (mem.eql(u8, slice, find)) {
            result = i;
            break;
        }
        i += 1;
    }

    return result;
}

fn utf8LastIndexOf(s: []const u8, find: []const u8) !?usize {
    var result: ?usize = null;

    var utf8 = (try std.unicode.Utf8View.init(s)).iterator();

    var i: usize = 0;
    while (utf8.nextCodepointSlice()) |slice| {
        if (mem.eql(u8, slice, find)) result = i;
        i += 1;
    }

    return result;
}

test "string split" {
    const s = "hello,world,hello,zig";
    var split_iter = mem.splitAny(u8, s, ",");

    try testing.expectEqualStrings(split_iter.next().?, "hello");
    try testing.expectEqualStrings(split_iter.next().?, "world");
    try testing.expectEqualStrings(split_iter.next().?, "hello");
    try testing.expectEqualStrings(split_iter.next().?, "zig");
}

test "string startswith / endswith" {
    try testing.expect(mem.startsWith(u8, "hello", "hel"));
    try testing.expect(mem.endsWith(u8, "hello", "lo"));

    try testing.expectStringStartsWith("hello", "hel");
    try testing.expectStringEndsWith("hello", "lo");
}

test "string replace" {}
