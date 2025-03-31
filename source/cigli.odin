package cigli

import sa "core:container/small_array"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

_appInfo: AppInfo
_appInfoVisible: bool
_debugMessage: string
_currentLevel: Level
_totalScore: int = 0 //score of each level is added to this until game over

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

	// display app info
	if rl.IsKeyPressed(.F1) {
		_appInfoVisible = !_appInfoVisible
	}

	// move paddle left
	if rl.IsKeyDown(.L) ||
	   rl.IsKeyDown(.D) ||
	   rl.IsKeyDown(.RIGHT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_FACE_RIGHT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_FACE_RIGHT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_1) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_TRIGGER_2) {
		using _currentLevel.paddle;center.x += speed * ft
	}

	// move paddle right
	if rl.IsKeyDown(.J) ||
	   rl.IsKeyDown(.A) ||
	   rl.IsKeyDown(.LEFT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_FACE_LEFT) ||
	   rl.IsGamepadButtonDown(0, .RIGHT_FACE_LEFT) ||
	   rl.IsGamepadButtonDown(0, .LEFT_TRIGGER_1) ||
	   rl.IsGamepadButtonDown(0, .LEFT_TRIGGER_2) {
		using _currentLevel.paddle;center.x -= speed * ft
	}

	//move balls
	for x := 0; x < sa.len(_currentLevel.currentBalls); x += 1 {
		ball: ^Ball = sa.get_ptr(&_currentLevel.currentBalls, x)
		if !ball.suspended {
			UpdateBallPosition(ball, ft)
		}
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsGamepadButtonPressed(0, .RIGHT_FACE_DOWN) {
		ProcessSpace(&_currentLevel)
	}

	//TODO: update paddle size here, or it could be outside level

	using _currentLevel.paddle;{
		if center.x + width / 2 > f32(_appInfo.size.x) - f32(BORDER_OFFSET) {
			center.x = f32(_appInfo.size.x) - f32(BORDER_OFFSET) - width / 2
		}
		if center.x - width / 2 < BORDER_OFFSET {
			center.x = BORDER_OFFSET + width / 2
		}
	}
}

game_draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(COLOR_BACKGROUND)

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

