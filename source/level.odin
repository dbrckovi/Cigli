package cigli

import "core:fmt"
import rl "vendor:raylib"

BRICK_SIZE: [2]i32 : {32, 16}
COLOR_BRICK_STR1: rl.Color = {180, 180, 180, 255}
COLOR_BRICK_STR2: rl.Color = {250, 180, 180, 255}
COLOR_BRICK_STR3: rl.Color = {250, 80, 80, 255}
BORDER_OFFSET: i32 : 8
PADDLE_DEFAULT_WIDTH: i32 : 120
PADDLE_HEIGHT: i32 : 12

Level :: struct {
	bricks: [8][23]Brick,
	paddle: Paddle,
}

Brick :: struct {
	location: [2]i32,
	size:     [2]i32,
	visible:  bool,
	strength: i32,
}

Paddle :: struct {
	center: [2]i32,
	width:  i32,
	speed:  f32,
}

InitializeLevel :: proc(level: ^Level) {
	for &row, rowIndex in level.bricks {
		for &brick, colIndex in row {
			brick.visible = true
			brick.size = BRICK_SIZE
			brick.strength = 3
			brick.location = {
				i32(colIndex) * (brick.size.x + 2) + BORDER_OFFSET + 2,
				i32(rowIndex) * (brick.size.y + 2) + BORDER_OFFSET + 32,
			}
		}
	}

	level.paddle.center = {_appInfo.size.x / 2, _appInfo.size.y - 30}
	level.paddle.width = PADDLE_DEFAULT_WIDTH
	level.paddle.speed = 400
}

DrawLevel :: proc(level: ^Level) {
	bigRect: rl.Rectangle = {0, 0, f32(_appInfo.size.x), f32(_appInfo.size.y)}
	smallRect: rl.Rectangle = {4, 4, f32(_appInfo.size.x - 8), f32(_appInfo.size.y - 8)}
	rl.DrawRectangleLinesEx(bigRect, 3, rl.WHITE)
	rl.DrawRectangleLinesEx(smallRect, 1, rl.WHITE)

	for row in level.bricks {
		for brick in row {
			if brick.visible {
				DrawBrick(brick)
			}
		}
	}

	DrawPaddle(level.paddle)
}

DrawBrick :: proc(brick: Brick) {
	using brick;{
		brickOuter: rl.Rectangle = {f32(location.x), f32(location.y), f32(size.x), f32(size.y)}
		brickInner := ScaleRectangle(brickOuter, -2)

		rl.DrawRectangleLinesEx(brickOuter, 2, rl.WHITE)

		switch brick.strength {
		case 1:
			rl.DrawRectangleRec(brickInner, COLOR_BRICK_STR1)
		case 2:
			rl.DrawRectangleRec(brickInner, COLOR_BRICK_STR2)
		case 3:
			rl.DrawRectangleRec(brickInner, COLOR_BRICK_STR3)
		}
	}
}

DrawPaddle :: proc(paddle: Paddle) {
	using paddle;{
		paddleRect: rl.Rectangle = {
			f32(center.x - width / 2),
			f32(center.y - PADDLE_HEIGHT / 2),
			f32(paddle.width),
			f32(PADDLE_HEIGHT),
		}
		rl.DrawRectangleRec(paddleRect, COLOR_BRICK_STR1)
	}
}

