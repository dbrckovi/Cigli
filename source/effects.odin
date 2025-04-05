package cigli

import "core:fmt"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

_backgroundLines: [20]MovingLineEffect

MovingLineEffect :: struct {
	position:  f32,
	vertical:  bool,
	velocity:  f32, //current direction and speed
	fadeSpeed: f32, //how fast the alpha channel is changing and direction. Flips direction when it reaches 255
	alpha:     f32, //current alpha channel value
}

InitializeEffects :: proc() {
	for &effect in _backgroundLines {
		randomizeMovingLineEffect(&effect)
	}
}

UpdateEffects :: proc(ft: f32) {
	for &effect in _backgroundLines {
		updateMovingLineEffect(&effect, ft)
	}
}

DrawEffects :: proc() {
	for &effect in _backgroundLines {
		drawMovingLineEffect(&effect)
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

