package cigli

import "core:fmt"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

_backgroundLines: [20]MovingLineEffect
_stars: [500]StarEffect

MovingLineEffect :: struct {
	position:  f32,
	vertical:  bool,
	velocity:  f32, //current direction and speed
	fadeSpeed: f32, //how fast the alpha channel is changing and direction. Flips direction when it reaches 255
	alpha:     f32, //current alpha channel value
}

StarEffect :: struct {
	position:   [2]f32,
	luminocity: f32,
	speed:      f32,
}

InitializeEffects :: proc() {
	for &effect in _backgroundLines {
		randomizeMovingLineEffect(&effect)
	}

	for &star in _stars {
		randomizeStar(&star, false)
	}
}

UpdateEffects :: proc(ft: f32) {
	for &effect in _backgroundLines {
		updateMovingLineEffect(&effect, ft)
	}
	for &star in _stars {
		updateStarEffect(&star, ft)
	}
}

DrawEffects :: proc() {
	for &effect in _backgroundLines {
		drawMovingLineEffect(&effect)
	}

	for &star in _stars {
		drawStar(&star)
	}
}

randomizeMovingLineEffect :: proc(effect: ^MovingLineEffect) {
	effect.vertical = rand.int_max(2) == 1
	effect.velocity = f32(rand.int_max(100) - 50)
	if effect.vertical {
		if effect.velocity >
		   0 {effect.position = f32(rand.int_max(int(_appInfo.size.y / 2)))} else {effect.position = f32(rand.int_max(int(_appInfo.size.y / 2)) + int(_appInfo.size.y / 2))}
	} else {
		if effect.velocity >
		   0 {effect.position = f32(rand.int_max(int(_appInfo.size.x / 2)))} else {effect.position = f32(rand.int_max(int(_appInfo.size.x / 2)) + int(_appInfo.size.x / 2))}
	}
	effect.fadeSpeed = f32(rand.int_max(200))
	effect.alpha = 0
}

randomizeStar :: proc(star: ^StarEffect, forceCenter: bool) {
	if forceCenter {
		star.position = {f32(_appInfo.size.x / 2), f32(_appInfo.size.y / 2)}
	} else {
		star.position = {
			rand.float32() * f32(_appInfo.size.x),
			rand.float32() * f32(_appInfo.size.y),
		}
	}

	if star.position.x == f32(_appInfo.size.x / 2) || star.position.y == f32(_appInfo.size.y / 2) {
		star.position.x += rand.float32() - 0.5
		star.position.y += rand.float32() - 0.5
	}

	star.luminocity = rand.float32()
	star.speed = rand.float32() + 0.01
}

updateMovingLineEffect :: proc(effect: ^MovingLineEffect, ft: f32) {
	effect.position += effect.velocity * ft
	effect.alpha += effect.fadeSpeed * ft

	if effect.alpha > 255 {
		effect.alpha = 255
		effect.fadeSpeed = -effect.fadeSpeed
	} else if effect.alpha <= 0 {
		randomizeMovingLineEffect(effect)
	}
}

updateStarEffect :: proc(star: ^StarEffect, ft: f32) {
	centerX: i32 = _appInfo.size.x / 2
	centerY: i32 = _appInfo.size.y / 2

	using star;{
		position.x += (position.x - f32(centerX)) * speed * ft
		position.y += (position.y - f32(centerY)) * speed * ft


		if position.x < 0 ||
		   position.x > f32(_appInfo.size.x) ||
		   position.y < 0 ||
		   position.y > f32(_appInfo.size.y) {
			randomizeStar(star, true)
		}
	}

}


drawMovingLineEffect :: proc(effect: ^MovingLineEffect) {
	if effect.vertical {
		rl.DrawLine(
			i32(effect.position),
			0,
			i32(effect.position),
			_appInfo.size.y,
			{0, 40, 0, u8(effect.alpha)},
		)
	} else {
		rl.DrawLine(
			0,
			i32(effect.position),
			_appInfo.size.x,
			i32(effect.position),
			{0, 40, 0, u8(effect.alpha)},
		)
	}
}

drawStar :: proc(effect: ^StarEffect) {
	rl.DrawCircle(i32(effect.position.x), i32(effect.position.y), 2, {255, 255, 255, 255})
}

