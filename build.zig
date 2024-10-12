const std = @import("std");

const required_zig_version = std.SemanticVersion.parse("0.14.0-dev.367+a57479afc") catch unreachable;

pub fn build(b: *std.Build) void {
    if (comptime @import("builtin").zig_version.order(required_zig_version) == .lt) {
        std.debug.print("Warning: Your version of Zig too old. You will need to download a newer build\n", .{});
        std.os.exit(1);
    }

    const cmd = b.option([]const u8, "cmd", "Command to embed in the binary") orelse {
        std.debug.panic("No command provided. Use -Dcmd=<command> to provide a command.", .{});
    };
    const cmd_args = b.option([]const u8, "cmd_args", "Args to embed in the binary") orelse "";

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "process-executor.zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const options = b.addOptions();
    options.addOption([]const u8, "cmd", cmd);
    options.addOption([]const u8, "cmd_args", cmd_args);

    exe.root_module.addOptions("config", options);

    b.installArtifact(exe);
}
