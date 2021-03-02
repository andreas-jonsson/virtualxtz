const std = @import("std");
const Builder = std.build.Builder;
const Target = std.build.Target;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("virtualxt", "src/main.zig");
    exe.setBuildMode(mode);

    const windows = b.option(bool, "windows", "Create Windows build") orelse false;
    if (windows) {
        std.debug.print("Building for Windows!\n", .{});
        exe.setTarget(.{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
            .abi = .gnu,
        });
    }

    const sdl_path = b.option([]const u8, "sdl-path", "Path to SDL2 headers and libs") orelse null; 
    if (sdl_path != null) {
        const p = .{sdl_path};
        std.debug.print("SDL2 location: {s}\n", p);

        exe.addLibPath(b.fmt("{s}/lib", p));
        exe.addIncludeDir(b.fmt("{s}/include", p));

        if (windows) {
            exe.addLibPath(b.fmt("{s}/lib/x64", p));
        }
    }

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");

    exe.addPackagePath("vxt", "libs/vxt/vxt.zig");

    const run_cmd = exe.run();
    const run_step = b.step("run", "Run VirtualXT");
    run_step.dependOn(&run_cmd.step);

    var tests = b.addTest("src/main.zig");
    tests.setBuildMode(mode);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&tests.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
