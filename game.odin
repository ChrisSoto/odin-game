package game

import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

title_screen_pos: [2]f32
exit_screen := 0

font: rl.Font

Screens :: enum {
	TITLE,
	GAMEPLAY,
	OPTIONS,
}

Player :: struct {
	// state
	pos:      rl.Vector2,
	vel:      rl.Vector2,
	grounded: bool,
	flip:     bool,
	source:   rl.Rectangle,
	dest:     rl.Rectangle,

	// animations
	run:      SpriteSheet,
}

SpriteSheet :: struct {
	texture:       rl.Texture2D,
	frames:        int,
	frame_length:  f32,
	timer:         f32,
	current_frame: int,
}

/* Our game's state lives within this struct. In
order for hot reload to work the game's memory
must be transferable from one game DLL to
another when a hot reload occurs. We can do that
when all the game's memory live in here. */
GameMemory :: struct {
	player:     Player,
	some_state: int,
}

current_screen: Screens

/* Allocates the GameMemory that we use to store
our game's state. We assign it to a global
variable so we can use it from the other
procedures. */
g_mem: ^GameMemory

init_player :: proc(player: ^Player) {
	player.pos = {SCREEN_WIDTH, SCREEN_HEIGHT}
	player.run.texture = rl.LoadTexture("cat_run.png")
	player.run.frames = 4
	run_sheet_width := f32(player.run.texture.width)
	run_sheet_height := f32(player.run.texture.height)

	player.run.frame_length = 0.1

	player.source = {
		x      = 0,
		y      = 0,
		width  = run_sheet_width / f32(player.run.frames),
		height = run_sheet_height,
	}

	player.dest = {
		x      = player.pos.x,
		y      = player.pos.y,
		width  = run_sheet_width * 4 / f32(player.run.frames),
		height = run_sheet_height * 4,
	}
}

update_player :: proc(player: ^Player) {
	// moving player
	if (rl.IsKeyDown(.LEFT)) {
		player.vel.x = -400
		player.flip = true
	} else if (rl.IsKeyDown(.RIGHT)) {
		player.vel.x = 400
		player.flip = false
	} else {
		player.vel.x = 0
	}

	player.vel.y += 2000 * rl.GetFrameTime()

	if (player.grounded && rl.IsKeyPressed(.SPACE)) {
		player.vel.y = -600
		player.grounded = false
	}

	player.pos += player.vel * rl.GetFrameTime()

	if (player.pos.y > f32(rl.GetScreenHeight()) - 64) {
		player.pos.y = f32(rl.GetScreenHeight()) - 64
		player.grounded = true
	}

	player.run.timer += rl.GetFrameTime()

	if (player.run.timer > player.run.frame_length) {
		player.run.current_frame += 1
		player.run.timer = 0

		if (player.run.current_frame == player.run.frames) {
			player.run.current_frame = 0
		}
	}

	player.source.x =
		f32(player.run.current_frame) * f32(player.run.texture.width) / f32(player.run.frames)

	if (player.flip) {
		if (player.source.width > 0) {
			player.source.width = player.source.width * -1
		}
	} else {
		player.source.width = abs(player.source.width)
	}

	player.dest.x = player.pos.x
	player.dest.y = player.pos.y

	rl.DrawTexturePro(player.run.texture, player.source, player.dest, 0, 0, rl.WHITE)
}

go_to_screen :: proc(screen: Screens) {
	current_screen = screen
}

draw_title_screen :: proc() {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.GREEN)
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

@(export)
game_init :: proc() -> ^GameMemory {
	rl.SetTargetFPS(60)
	g_mem = new(GameMemory)
	init_player(&g_mem.player)
	current_screen = .TITLE
	return g_mem
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "My First Game")
	font = rl.LoadFont("font/mecha.png")
}


/* Simulation and rendering goes here. Return
false when you wish to terminate the program. */
@(export)
game_update :: proc() -> bool {

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLUE)

	switch current_screen {
	case .TITLE:
		update_title_screen()
		if exit_title_screen() == 1 {
			go_to_screen(.GAMEPLAY)
		}
		draw_title_screen()
	case .GAMEPLAY:
		udpate_game_play()
	case .OPTIONS:
		udpate_options_screen()
	}

	// update_player(&g_mem.player)

	rl.EndDrawing()
	// g_mem.some_state += 1
	if (rl.WindowShouldClose()) {
		rl.CloseWindow()
		return false
	}
	return true
}

/* Called by the main program when the main loop
has exited. Clean up your memory here. */
@(export)
game_shutdown :: proc() {
	free(g_mem)
}

/* Returns a pointer to the game memory. When
hot reloading, the main program needs a pointer
to the game memory. It can then load a new game
DLL and tell it to use the same memory by calling
game_hot_reloaded on the new game DLL, supplying
it the game memory pointer. */
@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

/* Used to set the game memory pointer after a
hot reload occurs. See game_memory comments. */
@(export)
game_hot_reloaded :: proc(mem: ^GameMemory) {
	g_mem = mem
}
