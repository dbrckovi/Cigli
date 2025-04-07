package cigli

import sa "core:container/small_array"
import "core:fmt"
import rl "vendor:raylib"

BRICK_SIZE: [2]f32 : {32, 16}
COLOR_BRICK_BORDER: rl.Color = {55, 105, 55, 255}
COLOR_BRICK_STR1: rl.Color = {33, 44, 33, 255}
COLOR_BRICK_STR2: rl.Color = {66, 99, 66, 255}
COLOR_BRICK_STR3: rl.Color = {99, 166, 99, 255}
COLOR_BACKGROUND: rl.Color = {0, 15, 0, 255}
COLOR_BORDER: rl.Color = {44, 99, 44, 255}
COLOR_PADDLE: rl.Color = {99, 166, 99, 255}
COLOR_PADDLE_MAGNETIZED: rl.Color = {99, 99, 255, 255}
COLOR_BALL: rl.Color = {144, 243, 144, 255}
BORDER_OFFSET: f32 : 8
PADDLE_DEFAULT_WIDTH: f32 : 120
PADDLE_HEIGHT: f32 : 12
BALL_RADIUS: f32 : 8

Level :: struct {
	bricks:       [8][23]Brick,
	paddle:       Paddle,
	currentBalls: sa.Small_Array(16, Ball), //TODO: rethink max amount of balls
	lives:        int, //reset to 3 at level start. Game over if 0 is rached
	score:        int, //reset to 0 at level start. Added to total score when level finished
}

Brick :: struct {
	location: [2]f32,
	size:     [2]f32,
	visible:  bool,
	strength: i32,
}

Paddle :: struct {
	center:     [2]f32,
	width:      f32,
	speed:      f32,
	magnetized: bool, //when magnetized, the next ball that touches it, will stick to it at that location
}

Ball :: struct {
	center:        [2]f32,
	velocity:      [2]f32,
	suspended:     bool, //suspended ball doesn't move until space is pressed
	gluedToPaddle: bool, //when true, ball will follow paddle
}

InitializeLevel :: proc(level: ^Level) {
	for &row, rowIndex in level.bricks {
		for &brick, colIndex in row {
			brick.visible = true
			brick.size = BRICK_SIZE
			brick.strength = 3
			brick.location = {
				f32(colIndex) * (brick.size.x + 2) + BORDER_OFFSET + 2,
				f32(rowIndex) * (brick.size.y + 2) + BORDER_OFFSET + 32,
			}
		}
	}

	level.paddle.center = {f32(_appInfo.size.x) / 2, f32(_appInfo.size.y) - 30}
	level.paddle.width = PADDLE_DEFAULT_WIDTH
	level.paddle.speed = 400
	level.paddle.magnetized = false
	level.lives = 3
	level.score = 0

	PrepareNextBall(level)
}

//Puts ball into center, magnetizes the paddle and waits for space for it to release
PrepareNextBall :: proc(level: ^Level) {
	if sa.len(level.currentBalls) > 0 {
		panic("Can't start next ball when there is already a ball in play")
	}

	newBall: Ball = {
		center    = {f32(_appInfo.size.x / 2), 500},
		velocity  = {0, 400},
		suspended = true,
	}

	sa.append(&level.currentBalls, newBall)
	level.paddle.magnetized = true
}

//Processes everything that needs to happen when space is pressed
ProcessSpace :: proc(level: ^Level) {

	//release suspended balls
	for x := 0; x < sa.len(level.currentBalls); x += 1 {
		ball := sa.get_ptr(&level.currentBalls, x)
		if ball.suspended {ball.suspended = false}
	}
}

//updates ball position and resolves collisions
UpdateBallPosition :: proc(ball: ^Ball, ft: f32) {
	ball.center += ball.velocity * ft
}

DrawLevel :: proc(level: ^Level) {
	bigRect: rl.Rectangle = {0, 0, f32(_appInfo.size.x), f32(_appInfo.size.y)}
	smallRect: rl.Rectangle = {4, 4, f32(_appInfo.size.x - 8), f32(_appInfo.size.y - 8)}
	rl.DrawRectangleLinesEx(bigRect, 3, COLOR_BORDER)
	rl.DrawRectangleLinesEx(smallRect, 1, COLOR_BORDER)

	for row in level.bricks {
		for brick in row {
			if brick.visible {
				DrawBrick(brick)
			}
		}
	}

	DrawPaddle(level.paddle)
	DrawBalls(level)
}

DrawBrick :: proc(brick: Brick) {
	using brick;{
		brickOuter: rl.Rectangle = {f32(location.x), f32(location.y), f32(size.x), f32(size.y)}
		brickInner := ScaleRectangle(brickOuter, -2)

		rl.DrawRectangleLinesEx(brickOuter, 1, COLOR_BRICK_BORDER)

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
		if paddle.magnetized {
			rl.DrawRectangleRec(paddleRect, COLOR_PADDLE_MAGNETIZED)
		} else {
			rl.DrawRectangleRec(paddleRect, COLOR_PADDLE)
		}
	}
}

DrawBalls :: proc(level: ^Level) {
	for x := 0; x < sa.len(level.currentBalls); x += 1 {
		ball: Ball = sa.get(level.currentBalls, x)
		rl.DrawCircleV(ball.center, BALL_RADIUS, COLOR_BALL)
	}
}

