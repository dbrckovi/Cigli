package cigli

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

_appInfo: AppInfo
_appInfoVisible: bool
_debugMessage: string
_currentLevel: Level

game_init :: proc() {
	_appInfo.size = {800, 600}

	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(_appInfo.size.x, _appInfo.size.y, "Cigli")
	rl.SetTargetFPS(200)
	rl.InitAudioDevice()
	rl.SetMasterVolume(1)
	InitializeLevel(&_currentLevel)
}

game_update :: proc() {
	ft := rl.GetFrameTime()
	_appInfo = GetWindowInformation()

	// handle input
	if rl.IsKeyPressed(.F1) {
		_appInfoVisible = !_appInfoVisible
	}

	if rl.IsKeyDown(.L) ||
	   rl.IsKeyDown(.D) ||
	   rl.IsKeyDown(.RIGHT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_FACE_RIGHT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_FACE_RIGHT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_1) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_2) {
		using _currentLevel.paddle;center.x += i32(speed * ft)
	}

	if rl.IsKeyDown(.J) ||
	   rl.IsKeyDown(.A) ||
	   rl.IsKeyDown(.LEFT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_FACE_LEFT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_FACE_LEFT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_TRIGGER_1) ||
	   rl.IsGamepadButtonDown(0, .LEFT_TRIGGER_2) {
		using _currentLevel.paddle;center.x -= i32(speed * ft)
	}

	//TODO: update paddle size here, or it could be outside level

	using _currentLevel.paddle;{
		if center.x + width / 2 > _appInfo.size.x - BORDER_OFFSET {
			center.x = _appInfo.size.x - BORDER_OFFSET - width / 2
		}
		if center.x - width / 2 < BORDER_OFFSET {
			center.x = BORDER_OFFSET + width / 2
		}
	}
}

game_draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.DARKBLUE)

	DrawLevel(&_currentLevel)

	if _appInfoVisible {
		rl.DrawText(AppInfo_ToString(_appInfo), 10, 10, 16, rl.WHITE)
	}

	if len(_debugMessage) > 0 {
		rl.DrawText(strings.clone_to_cstring(_debugMessage), 10, _appInfo.size.y - 24, 20, rl.RED)
	}

	rl.EndDrawing()
}

main :: proc() {

	game_init()

	for !rl.WindowShouldClose() {
		game_update()
		game_draw()
	}
}

