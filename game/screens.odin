package game

import rl "vendor:raylib"

title_screen_pos: [2]f32
exit_screen := 0

Screens :: enum {
	TITLE,
	GAMEPLAY,
	OPTIONS,
}

go_to_screen :: proc(screen: Screens) {
	current_screen = screen
}

draw_title_screen :: proc() {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.RED)
	title_screen_pos = {20, 10}
	rl.DrawTextEx(font, "TITLE SCREEN", title_screen_pos, f32(font.baseSize * 3), 4, rl.DARKGREEN)
	rl.DrawText("PRESS ENTER to go to GAMEPLAY SCREEN", 120, SCREEN_HEIGHT / 2, 20, rl.DARKGREEN)
}

update_title_screen :: proc() {
	if rl.IsKeyPressed(.ENTER) {
		exit_screen = 1
	}
}

exit_title_screen :: proc() -> int {
	return exit_screen
}

udpate_game_play :: proc() {}

udpate_options_screen :: proc() {}
