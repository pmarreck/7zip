const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create static library for 7z archive reading/extraction
    const lib = b.addLibrary(.{
        .name = "7z",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const c_path = b.path("C");

    // Common C flags
    const cflags: []const []const u8 = &.{
        "-fvisibility=hidden",
        "-D_7ZIP_ST", // Single-threaded mode (simpler, no pthreads needed)
    };

    // Core 7z archive reading files
    const c_sources: []const []const u8 = &.{
        "C/7zAlloc.c",
        "C/7zArcIn.c",
        "C/7zBuf.c",
        "C/7zBuf2.c",
        "C/7zCrc.c",
        "C/7zCrcOpt.c",
        "C/7zDec.c",
        "C/7zFile.c",
        "C/7zStream.c",
        "C/Bcj2.c",
        "C/Bra.c",
        "C/Bra86.c",
        "C/BraIA64.c",
        "C/CpuArch.c",
        "C/Delta.c",
        "C/Lzma2Dec.c",
        "C/LzmaDec.c",
        "C/Ppmd7.c",
        "C/Ppmd7Dec.c",
    };

    for (c_sources) |src| {
        lib.addCSourceFile(.{
            .file = b.path(src),
            .flags = cflags,
        });
    }

    // Add C/ as include path for internal headers
    lib.addIncludePath(c_path);

    // Install public headers needed by consumers
    lib.installHeader(b.path("C/7z.h"), "7z.h");
    lib.installHeader(b.path("C/7zAlloc.h"), "7zAlloc.h");
    lib.installHeader(b.path("C/7zBuf.h"), "7zBuf.h");
    lib.installHeader(b.path("C/7zCrc.h"), "7zCrc.h");
    lib.installHeader(b.path("C/7zFile.h"), "7zFile.h");
    lib.installHeader(b.path("C/7zTypes.h"), "7zTypes.h");
    lib.installHeader(b.path("C/7zWindows.h"), "7zWindows.h");
    lib.installHeader(b.path("C/Compiler.h"), "Compiler.h");
    lib.installHeader(b.path("C/CpuArch.h"), "CpuArch.h");
    lib.installHeader(b.path("C/Precomp.h"), "Precomp.h");

    b.installArtifact(lib);
}
