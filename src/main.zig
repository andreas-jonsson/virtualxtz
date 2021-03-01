const std = @import("std");
//const vxt = @import("libvxt");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

const ErrorSet = error{SDLError};

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_AUDIO) != 0) {
        std.debug.warn("Unable to initialize SDL: {s}", sdl.SDL_GetError());
        return ErrorSet.SDLError;
    }
    defer sdl.SDL_Quit();

    const screen_width = 160;//vxt.the_number();
    const screen_height = 144;
    const undefined_pos = 0x1FFF0000;

    const window = sdl.SDL_CreateWindow(
        "VirtualXT",
        undefined_pos,
        undefined_pos,
        screen_width,
        screen_height,
        sdl.SDL_WINDOW_SHOWN,
    );
    if (window == null) {
        std.debug.warn("Cannot create window: {s}", sdl.SDL_GetError());
        return ErrorSet.SDLError;
    }
    defer sdl.SDL_DestroyWindow(window);
    const screen = sdl.SDL_GetWindowSurface(window);
    std.os.nanosleep(5, 0);
}
