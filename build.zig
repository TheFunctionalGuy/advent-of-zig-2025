const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const mod = b.addModule("util", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
        });

        var directory = try b.build_root.handle.openDir("src", .{ .iterate = true });
        defer directory.close();

        var iter = directory.iterate();

        while (try iter.next()) |sub_directory| {
            if (std.mem.startsWith(u8, sub_directory.name, "day_")) {
                const path = try std.mem.concat(b.allocator, u8, &.{ "src", "/", sub_directory.name, "/", sub_directory.name, ".zig" });
                const input_path = try std.mem.concat(b.allocator, u8, &.{ "src", "/", sub_directory.name, "/input" });

                // === zig build (install) ===
                {
                    const exe = b.addExecutable(.{
                        .name = sub_directory.name,
                        .root_module = b.createModule(.{
                            .root_source_file = b.path(path),
                            .target = target,
                            .optimize = optimize,
                            .imports = &.{
                                .{ .name = "util", .module = mod },
                            },
                        }),
                    });

                    b.installArtifact(exe);

                    // === zig build run ===
                    {
                        const install_exe = b.addInstallArtifact(exe, .{});

                        const run_cmd = b.addRunArtifact(exe);
                        run_cmd.setStdIn(.{ .lazy_path = b.path(input_path) });

                        // Only install specific exe
                        run_cmd.step.dependOn(&install_exe.step);

                        const step_name = try std.mem.concat(b.allocator, u8, &.{ "run-", sub_directory.name });
                        const step_description = try std.mem.concat(b.allocator, u8, &.{ "Run ", sub_directory.name, " executable" });

                        const run_step = b.step(step_name, step_description);
                        run_step.dependOn(&run_cmd.step);
                    }

                    // === zig build benchmark ===
                    {
                        const release_exe = b.addExecutable(.{
                            .name = sub_directory.name,
                            .root_module = b.createModule(.{
                                .root_source_file = b.path(path),
                                .target = target,
                                .optimize = .ReleaseSafe,
                                .imports = &.{
                                    .{ .name = "util", .module = mod },
                                },
                            }),
                        });
                        const install_release_exe = b.addInstallArtifact(release_exe, .{
                            .dest_dir = .{
                                .override = .{
                                    .custom = "release",
                                },
                            },
                        });

                        const input_arg = try std.mem.concat(b.allocator, u8, &.{ "--input=", try b.build_root.join(b.allocator, &.{input_path}) });
                        const exe_arg = try std.mem.concat(b.allocator, u8, &.{ b.install_path, "/", "release", "/", sub_directory.name });

                        const benchmark_cmd = b.addSystemCommand(&.{ "hyperfine", "--shell=none", "--warmup=10", input_arg });
                        benchmark_cmd.addArg(exe_arg);
                        benchmark_cmd.step.dependOn(&install_release_exe.step);

                        const step_name = try std.mem.concat(b.allocator, u8, &.{ "benchmark-", sub_directory.name });
                        const step_description = try std.mem.concat(b.allocator, u8, &.{ "Benchmark ", sub_directory.name, " executable with hyperfine" });

                        const benchmark_step = b.step(step_name, step_description);
                        benchmark_step.dependOn(&benchmark_cmd.step);
                    }
                }
            }
        }
    }
}
