package game

import rl "vendor:raylib"

screen_title_pos: [2]f32 = {20, 10}
text_margin_left := i32(120)
exit_screen := 0
start_selected := true

Screens :: enum {
	TITLE,
	GAMEPLAY,
	OPTIONS,
}

GoToScreen :: proc(screen: Screens) {
	g_mem.current_screen = screen
}

InitTitleScreen :: proc() {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.RED)
	// screen title
	rl.DrawTextEx(font, "TITLE SCREEN", screen_title_pos, f32(font.baseSize * 3), 4, rl.DARKGREEN)
}

UpdateTitleScreen :: proc() {
	// Option Colors
	start_color: rl.Color
	exit_color: rl.Color
	// option positions
	start_y := i32(SCREEN_HEIGHT / 2)
	exit_y := i32(start_y + font.baseSize * 2) // two lines down
	selector_y: i32
	// menu options

	if rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.UP) {
		start_selected = !start_selected
	}

	// update text color
	if (start_selected) {
		start_color = rl.GREEN
		exit_color = rl.DARKGREEN
		selector_y = start_y + font.baseSize / 2
	} else {
		start_color = rl.DARKGREEN
		exit_color = rl.GREEN
		selector_y = exit_y + font.baseSize / 2
	}

	// draw selector
	rl.DrawCircle(text_margin_left - 20, selector_y, f32(font.baseSize) / 2, rl.GREEN)

	// draw text
	rl.DrawText("START", text_margin_left, start_y, 20, start_color)
	rl.DrawText("EXIT", text_margin_left, exit_y, 20, exit_color)

	// screen change
	if rl.IsKeyPressed(.ENTER) && start_selected {
		exit_screen = 1
	}
	if rl.IsKeyPressed(.ENTER) && !start_selected {
		exit_screen = 2
	}
}

ExitTitleScreen :: proc() -> int {
	return exit_screen
}

UpdateGamePlay :: proc(dino: ^Dino) {
	update_dino(dino)
}

UpdateOptionsScreen :: proc() {}
