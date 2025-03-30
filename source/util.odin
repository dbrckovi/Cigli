package cigli

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

AppInfo :: struct {
	position:       [2]f32,
	size:           [2]i32,
	currentMonitor: i32,
	dpi:            rl.Vector2,
	fps:            i32,
}

GetWindowInformation :: proc() -> AppInfo {
	ret: AppInfo
	ret.size.x = rl.GetRenderWidth()
	ret.size.y = rl.GetRenderHeight()
	ret.position = rl.GetWindowPosition()
	ret.fps = rl.GetFPS()
	ret.currentMonitor = rl.GetCurrentMonitor()
	ret.dpi = rl.GetWindowScaleDPI()
	return ret
}

AppInfo_ToString :: proc(appInfo: AppInfo) -> cstring {
	return fmt.ctprint(_appInfo)
}

// Makes rectangle bigger or smaller, based on offset
ScaleRectangle :: proc(rect: rl.Rectangle, offset: f32) -> rl.Rectangle {
	return {rect.x - offset, rect.y - offset, rect.width + offset * 2, rect.height + offset * 2}
}

