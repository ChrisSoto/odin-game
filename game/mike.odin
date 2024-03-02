package game

import rl "vendor:raylib"

MikeActions :: struct {
	ATTACK1: SpriteSheetAction,
	ATTACK2: SpriteSheetAction,
	COMBO:   SpriteSheetAction,
	DEATH:   SpriteSheetAction,
	CANNON:  SpriteSheetAction,
	HIT:     SpriteSheetAction,
	IDLE:    SpriteSheetAction,
	JUMP:    SpriteSheetAction,
	MOVE:    SpriteSheetAction,
}

InitMike :: proc(player: ^Player) {
	player.pos = {SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}
	player.sheet.texture = rl.LoadTexture("assets/sheets/MechanicMike/all.png")
	player.sheet.frames = 54 // 80 px frame for some reason
	sheet_width := f32(player.sheet.texture.width)
	sheet_height := f32(player.sheet.texture.height)
	player.sheet.scale = 4
	player.sheet.offset = 16 * player.sheet.scale
	player.sheet.frame_length = 0.1

	player.actions = GetMikeActions()

	player.current_action = player.actions.IDLE

	player.source = {
		x      = 0,
		y      = 0,
		width  = sheet_width / f32(player.sheet.frames),
		height = sheet_height,
	}

	player.dest = {
		x      = player.pos.x,
		y      = player.pos.y,
		width  = sheet_width * player.sheet.scale / f32(player.sheet.frames),
		height = sheet_height * player.sheet.scale,
	}
}

GetMikeActions :: proc() -> (actions: MikeActions) {

	actions.IDLE = {
		start = 0,
		end   = 6,
	}

	actions.MOVE = {
		start = 7,
		end   = 12,
	}

	actions.JUMP = {
		start = 13,
		end   = 19,
	}

	actions.ATTACK1 = {
		start = 20,
		end   = 23,
	}

	actions.ATTACK2 = {
		start = 25,
		end   = 32,
	}

	return actions
}
