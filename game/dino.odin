package game
import rl "vendor:raylib"

Dino :: struct {
	// state
	pos:            rl.Vector2,
	vel:            rl.Vector2,
	grounded:       bool,
	flip:           bool,
	source:         rl.Rectangle,
	dest:           rl.Rectangle,

	// animations
	sheet:          SpriteSheet,
	actions:        DinoActions,
	current_action: SpriteSheetAction,
}

DinoActions :: struct {
	IDLE: SpriteSheetAction,
	MOVE: SpriteSheetAction,
	KICK: SpriteSheetAction,
	HURT: SpriteSheetAction,
	SNEK: SpriteSheetAction,
}

dino_actions: DinoActions

init_dino :: proc(dino: ^Dino) {
	dino.pos = {SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}
	dino.sheet.texture = rl.LoadTexture("assets/sheets/dino/doux.png")
	dino.sheet.frames = 24
	sheet_width := f32(dino.sheet.texture.width)
	sheet_height := f32(dino.sheet.texture.height)
	dino.sheet.scale = 4
	dino.sheet.offset = 3 * dino.sheet.scale
	dino.sheet.frame_length = 0.1

	dino_actions.IDLE = {
		start = 0,
		end   = 4,
	}

	dino_actions.MOVE = {
		start = 5,
		end   = 10,
	}

	dino_actions.KICK = {
		start = 11,
		end   = 13,
	}

	dino_actions.HURT = {
		start = 14,
		end   = 17,
	}

	dino_actions.SNEK = {
		start = 18,
		end   = 24,
	}

	dino.current_action = dino_actions.IDLE

	dino.source = {
		x      = 0,
		y      = 0,
		width  = sheet_width / f32(dino.sheet.frames),
		height = sheet_height,
	}

	dino.dest = {
		x      = dino.pos.x,
		y      = dino.pos.y,
		width  = sheet_width * dino.sheet.scale / f32(dino.sheet.frames),
		height = sheet_height * dino.sheet.scale,
	}
}

update_dino :: proc(dino: ^Dino) {
	// moving dino
	if (rl.IsKeyDown(.A)) {
		dino.vel.x = -400
		dino.flip = true
	} else if (rl.IsKeyDown(.D)) {
		dino.vel.x = 400
		dino.flip = false
	} else {
		dino.vel.x = 0
	}

	dino.vel.y += 2000 * rl.GetFrameTime()

	if (dino.grounded && rl.IsKeyPressed(.SPACE)) {
		dino.vel.y = -600
		dino.grounded = false
	}

	dino.pos += dino.vel * rl.GetFrameTime()

	if (dino.pos.y > f32(rl.GetScreenHeight()) - dino.dest.height + dino.sheet.offset) {
		dino.pos.y = f32(rl.GetScreenHeight()) - dino.dest.height + dino.sheet.offset
		dino.grounded = true
	}

	dino.sheet.timer += rl.GetFrameTime()

	if (dino.sheet.timer > dino.sheet.frame_length) {

		if rl.IsKeyDown(.A) || rl.IsKeyDown(.D) {
			dino.current_action = dino_actions.MOVE
			if rl.IsKeyDown(.LEFT_SHIFT) {
				dino.current_action = dino_actions.SNEK
			}
		} else if rl.IsKeyDown(.SPACE) {
			// jump

		} else if rl.IsKeyDown(.E) {
			dino.current_action = dino_actions.KICK
		} else {
			dino.current_action = dino_actions.IDLE
		}

		if dino.sheet.current_frame < dino.current_action.start {
			dino.sheet.current_frame = dino.current_action.start
		}

		dino.sheet.current_frame += 1

		if (dino.sheet.current_frame >= dino.current_action.end) {
			dino.sheet.current_frame = dino.current_action.start
		}

		dino.sheet.timer = 0
	}

	dino.source.x =
		f32(dino.sheet.current_frame) * f32(dino.sheet.texture.width) / f32(dino.sheet.frames)

	if (dino.flip) {
		if (dino.source.width > 0) {
			dino.source.width = dino.source.width * -1
		}
	} else {
		dino.source.width = abs(dino.source.width)
	}

	dino.dest.x = dino.pos.x
	dino.dest.y = dino.pos.y

	rl.DrawTexturePro(dino.sheet.texture, dino.source, dino.dest, 0, 0, rl.WHITE)
}
