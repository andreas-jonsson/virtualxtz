const std = @import("std");
const vxt = @import("vxt");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const ErrorSet = error{SDLError};

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) != 0) {
        std.debug.warn("Unable to initialize SDL: {s}", .{c.SDL_GetError()});
        return ErrorSet.SDLError;
    }
    defer c.SDL_Quit();

    _ = c.SDL_SetHint(c.SDL_HINT_RENDER_SCALE_QUALITY, "0");
    _ = c.SDL_SetHint(c.SDL_HINT_WINDOWS_NO_CLOSE_ON_ALT_F4, "1");

    const screen_width = vxt.the_number();
    const screen_height = 144;

    const window = c.SDL_CreateWindow(
        "VirtualXT",
        c.SDL_WINDOWPOS_UNDEFINED_MASK,
        c.SDL_WINDOWPOS_UNDEFINED_MASK,
        640,
        480,
        c.SDL_WINDOW_RESIZABLE,
    ) orelse {
        std.debug.warn("Cannot create window: {s}", .{c.SDL_GetError()});
        return ErrorSet.SDLError;
    };
    defer c.SDL_DestroyWindow(window);

    c.SDL_SetWindowTitle(window, "VirtualXT");

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        std.debug.warn("Cannot create renderer: {s}", .{c.SDL_GetError()});
        return ErrorSet.SDLError;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ABGR8888, c.SDL_TEXTUREACCESS_STREAMING, 640, 200) orelse {
        std.debug.warn("Cannot create texture: {s}", .{c.SDL_GetError()});
        return ErrorSet.SDLError;
    };
    defer c.SDL_DestroyTexture(texture);

    if (c.SDL_RenderSetLogicalSize(renderer, 640, 480) != 0) {
        std.debug.warn("Unable to set logical renderer size: {s}", .{c.SDL_GetError()});
    }

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    return;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, texture, null, null);
        c.SDL_RenderPresent(renderer);

        std.time.sleep(16*1000000);
    }
}
