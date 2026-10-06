# svg2tvg - convert svg to tvg and render tvg to image!

- written in zig 0.17.0
- dependency name: svg2tvg, module name: svg2tvg

## status / background

- the main goal is to convert and render icons
- the renderer has options to overwrite color and stroke width
- only a small subset of svg is supported
- related project: [zig-lib-icons](https://github.com/nat3Github/zig-lib-icons/tree/main)
- as of now used in the [dvui](https://github.com/david-vanderson/dvui) project to render icons

# api

- tvg_from_svg(...) - convert svg to tvg
- renderStream(...) - render tvg to an image
- RenderOptions - Options for rendering

## tests

`zig build test` runs the existing TinyVG and SVG parser fixtures, plus a
conversion-and-rendering test for filled and stroked SVG paths.

## usage:

```zig
test "convert to tvg and render" {
    const svg2tvg = @import("svg2tvg");
    const gpa = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const alloc = arena.allocator();

    const Wrapper = struct {
        width: isize,
        height: isize,
        img: *MyImage,
        pub fn setPixel(self: *@This(), x: isize, y: isize, color: [4]u8) void {
            const pix: MyPixel = .init_from_u8_slice(&color);
            self.img.set_pixel(@intCast(x), @intCast(y), pix);
        }
    };

    const width_and_height = 200;

    var myImage = try MyImageType.init(alloc, width_and_height, width_and_height);
    const my_svg_icon_data = icons.svg.feather.activity;

    const tvg_bytes = try svg2tvg.tvg_from_svg(alloc, my_svg_icon_data, .{});
    defer alloc.free(tvg_bytes);

    var image_wrapper = Wrapper{
        .img = &myImage,
        .width = @intCast(myImage.get_width()),
        .height = @intCast(myImage.get_height()),
    };

    var reader: std.Io.Reader = .fixed(tvg_bytes);
    try svg2tvg.renderStream(alloc, &image_wrapper, &reader, .{});

    ...
}
```

## Credit:

- Chris Marchesi: https://github.com/vancluever/z2d (used to render tvg as image)
- Ian Johnson: https://github.com/ianprime0509/zig-xml (used for parsing xml)
- Chris Marchesi: https://github.com/vancluever/zig-svg (for svg color attribute parsing)
- https://github.com/TinyVG/sdk/tree/main (used for writing tvg)

## Licence

- this library is under MIT
- svg.zig from https://github.com/vancluever/zig-svg is MPL licenced
- z2d is MPL licenced
- zig-xml is under 0BSD
- tinyVG/sdk is under MIT
