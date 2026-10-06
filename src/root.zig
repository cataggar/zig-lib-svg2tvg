const std = @import("std");
pub const ut = @import("util.zig");
pub const z2d = @import("z2d");
pub const svg_ut = @import("svg-util.zig");
const tinyvg2 = @import("tinyvg/tinyvg.zig");
pub const tvg = tinyvg2;
pub const rendering = @import("rendering.zig");
pub const conversion = @import("conversion.zig");
pub const renderStream = rendering.renderStream;
pub const RenderOptions = rendering.Options;
pub const tvg_from_svg = conversion.tvg_from_svg;

pub const Color = tvg.Color;

test "Typecheck everything" {
    // Force the compiler to typecheck these modules
    _ = .{ tvg_from_svg, renderStream, rendering, conversion };
}

test "convert and render SVG paths" {
    const Image = struct {
        width: isize = 16,
        height: isize = 16,
        pixels: [16 * 16][4]u8 = @splat(@splat(0)),

        pub fn setPixel(self: *@This(), x: isize, y: isize, color: [4]u8) void {
            self.pixels[@intCast(y * self.width + x)] = color;
        }
    };
    const svg =
        \\<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16">
        \\  <g fill="#ff0000" stroke="none">
        \\    <path d="M2 2 H14 V14 H2 Z"/>
        \\    <path fill="none" stroke="#0000ff" stroke-width="2" d="M4 8 L12 8"/>
        \\  </g>
        \\</svg>
    ;
    const bytes = try tvg_from_svg(std.testing.allocator, svg, .{});
    defer std.testing.allocator.free(bytes);
    var reader: std.Io.Reader = .fixed(bytes);
    var image: Image = .{};
    try renderStream(std.testing.allocator, &image, &reader, .{});
    try std.testing.expectEqual([4]u8{ 0, 0, 255, 255 }, image.pixels[8 * 16 + 8]);
    try std.testing.expectEqual([4]u8{ 255, 0, 0, 255 }, image.pixels[4 * 16 + 8]);
    try std.testing.expectEqual(@as(u8, 0), image.pixels[0][3]);
}
