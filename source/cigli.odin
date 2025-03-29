package cigli

import "core:fmt"
import rl "vendor:raylib"

WINDOW_SIZE: [2]i32 : {800, 600}
BORDER_OFFSET: i32 : 8
_current_level: Level

game_init :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE.x, WINDOW_SIZE.y, "Cigli")
	rl.SetTargetFPS(200)
	rl.InitAudioDevice()
	rl.SetMasterVolume(1)
	_current_level = {}
}

game_update :: proc() {

}

game_draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.DARKBLUE)

	draw_level()

	rl.EndDrawing()
}

main :: proc() {

	game_init()

	for !rl.WindowShouldClose() {
		game_update()
		game_draw()
	}
}

