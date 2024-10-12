const std = @import("std");
const config = @import("config");

pub fn main() !void {
    const cmd: []const u8 = config.cmd;
    const cmd_args: []const u8 = config.cmd_args;

    std.debug.print("Embedded command: {s}\n", .{cmd});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("leak");

    const alloc = gpa.allocator();
    const cmd_argv = &[_][]const u8{cmd};
    const cmd_args_argv = &[_][]const u8{cmd_args};

    std.debug.print("cmd_argv: {s}\n", .{cmd_argv});
    std.debug.print("cmd_args_argv: {s}\n", .{cmd_args_argv});
    var proc = std.process.Child.init(cmd_argv ++ cmd_args_argv, alloc);
    proc.stdout_behavior = .Inherit;
    proc.stdin_behavior = .Ignore;
    proc.stderr_behavior = .Ignore;

    try proc.spawn();

    std.debug.print("Spawned process PID={}\n", .{proc.id});

    const term = try proc.wait();
    _ = term;
}
