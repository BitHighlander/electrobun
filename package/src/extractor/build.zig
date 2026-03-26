const std = @import("std");

pub fn build(b: *std.Build) void {
    // zig build -Doptimize=Debug to enable debug mode
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "extractor",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link with libc for chmod and other system calls
    exe.linkLibC();

    // Reserve space for Apple codesign's LC_CODE_SIGNATURE load command.
    // Without this, codesign overwrites __TEXT:__text on x86_64 (ziglang/zig#23704).
    if (target.result.os.tag == .macos) {
        exe.headerpad_size = 0x1000;
    }

    // Use Console subsystem on all platforms so users can see extraction progress
    // The console window will automatically close when extraction completes

    b.installArtifact(exe);
}
