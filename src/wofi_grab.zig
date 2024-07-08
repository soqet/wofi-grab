const std = @import("std");

const c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("wofi_api.h");
    @cInclude("map.h");
});

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const globalAlloc = gpa.allocator();

const widgetList = std.DoublyLinkedList(*c.widget);
var widgets = widgetList{};

const HyprlandWindow = struct {
    address: []u8,
    pid: u64,
    title: []u8,
};

fn createWidget(alloc: std.mem.Allocator, mode: *c.mode, text: []u8, cmd: []u8) ?*c.widget {
    var cText: []u8 = alloc.alloc(u8, text.len + 1) catch return null;
    @memcpy(cText[0..text.len], text);
    cText[text.len] = 0;
    var cCmd: []u8 = alloc.alloc(u8, cmd.len + 1) catch return null;
    @memcpy(cCmd[0..cmd.len], cmd);
    cCmd[cmd.len] = 0;
    return c.wofi_create_widget(mode, @ptrCast(&cText), @ptrCast(cText), @ptrCast(&cCmd), 1);
}

export fn init(mode: *c.mode, _: *c.map) void {
    const in = std.io.getStdIn();
    var bufIn = std.io.bufferedReader(in.reader());
    const maxReadSize = 1024 * 100;
    const data = bufIn.reader().readAllAlloc(globalAlloc, maxReadSize) catch |err| {
        std.debug.print("couldn't read from stdin: {any}", .{err});
        unreachable;
    };
    var parsed = std.json.parseFromSlice([]HyprlandWindow, globalAlloc, data, .{ .ignore_unknown_fields = true }) catch |err| {
        std.debug.print("invalid json: {any}", .{err});
        c.wofi_exit(1);
        unreachable;
    };
    defer parsed.deinit();
    for (parsed.value) |window| {
        const widget = createWidget(globalAlloc, mode, window.title, window.address) orelse {
            std.debug.print("couldn't create widget", .{});
            unreachable;
        };
        const node = globalAlloc.create(widgetList.Node) catch |err| {
            std.debug.print("couldn't alloc memory: {any}", .{err});
            unreachable;
        };
        node.data = widget;
        widgets.append(node);
    }
}

// export fn init(mode: *c.mode, _: *c.map) void {
//     const in = std.io.getStdIn();
//     var bufIn = std.io.bufferedReader(in.reader());
//     const bufferSize = 100;
//     var buf: [bufferSize]u8 = undefined;
//     while (bufIn.reader().readUntilDelimiterOrEof(&buf, '\n')) |scanned| {
//         const line = scanned orelse break;
//         const w = createWidget(globalAlloc, mode, line, line) orelse {
//             std.debug.print("couldn't create widget\n", .{});
//             unreachable;
//         };
//         const node = globalAlloc.create(widgetList.Node) catch |err| {
//             std.debug.print("couldn't allocate memory: {any}\n", .{err});
//             unreachable;
//         };
//         node.data = w;
//         widgets.append(node);
//     } else |err| {
//         std.debug.print("couldn't read from stdin: {any}\n", .{err});
//         unreachable;
//     }
// }

export fn get_widget() ?*c.widget {
    const n = widgets.pop() orelse return null;
    defer globalAlloc.destroy(n);
    const w = n.data;
    return w;
}

export fn exec(cmd: *c_char) void {
    const sCmd: [*:0]u8 = @ptrCast(cmd);
    std.io.getStdOut().writer().print("{s}", .{sCmd}) catch |err| {
        std.debug.print("can't use stdin: {any}", .{err});
        unreachable;
    };
    c.wofi_exit(0);
}
