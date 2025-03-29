package cigli

import rl "vendor:raylib"

Level :: struct {
	bricks: [8][20]Brick,
}

Brick :: struct {
	location: [2]i32,
	size:     [2]i32,
	visible:  bool,
}

draw_level :: proc() {
	bigRect: rl.Rectangle = {0, 0, f32(WINDOW_SIZE.x), f32(WINDOW_SIZE.y)}
	smallRect: rl.Rectangle = {4, 4, f32(WINDOW_SIZE.x - 8), f32(WINDOW_SIZE.y - 8)}
	rl.DrawRectangleLinesEx(bigRect, 3, rl.WHITE)
	rl.DrawRectangleLinesEx(smallRect, 1, rl.WHITE)
}

