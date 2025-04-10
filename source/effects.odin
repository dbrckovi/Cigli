package cigli

import "core:fmt"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

_stars: [1000]StarEffect

StarEffect :: struct {
	position:   [2]f32,
	luminocity: f32,
	speed:      f32,
}

InitializeEffects :: proc() {
	for &star in _stars {
		randomizeStar(&star, false)
	}
}

UpdateEffects :: proc(ft: f32) {
	for &star in _stars {
		updateStarEffect(&star, ft)
	}
}

DrawEffects :: proc() {

	for &star in _stars {
		drawStar(&star)
	}
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
	star.speed = rand.float32() + 0.1
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

drawStar :: proc(effect: ^StarEffect) {
	c := _appInfo.size / 2
	screenCenter_f32: [2]f32 = {f32(c.x), f32(c.y)}
	centerDistance := GetDistance(effect.position, screenCenter_f32) / 3 * effect.luminocity
	if centerDistance > 255 {centerDistance = 255}
	alpha := u8(centerDistance)
	rl.DrawCircle(i32(effect.position.x), i32(effect.position.y), 1, {20, 255, 20, alpha})
}

