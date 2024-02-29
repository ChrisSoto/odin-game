package game

import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

font: rl.Font

/* Our game's state lives within this struct. In
order for hot reload to work the game's memory
must be transferable from one game DLL to
another when a hot reload occurs. We can do that
when all the game's memory live in here. */
GameMemory :: struct {
	dino:           Dino,
	some_state:     int,
	current_screen: Screens,
}


/* Allocates the GameMemory that we use to store
our game's state. We assign it to a global
variable so we can use it from the other
procedures. */
g_mem: ^GameMemory

@(export)
game_init :: proc() -> ^GameMemory {
	rl.SetTargetFPS(60)
	g_mem = new(GameMemory)
	init_dino(&g_mem.dino)
	g_mem.current_screen = .TITLE
	return g_mem
}

@(export)
game_init_window :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "My First Game")
	font = rl.LoadFont("assets/font/mecha.png")
}


/* Simulation and rendering goes here. Return
false when you wish to terminate the program. */
@(export)
game_update :: proc() -> bool {

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLUE)

	switch g_mem.current_screen {
	case .TITLE:
		InitTitleScreen()
		if ExitTitleScreen() == 1 {
			GoToScreen(.GAMEPLAY)
		} else if (ExitTitleScreen() == 2) {
			return false
		}
		UpdateTitleScreen()
	case .GAMEPLAY:
		UpdateGamePlay(&g_mem.dino)
	case .OPTIONS:
		UpdateOptionsScreen()
	}

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
