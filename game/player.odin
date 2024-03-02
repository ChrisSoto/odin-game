package game

import "core:fmt"
import rl "vendor:raylib"

SpriteSheet :: struct {
	texture:       rl.Texture2D,
	frames:        int,
	frame_length:  f32,
	timer:         f32,
	current_frame: int,
	offset:        f32,
	scale:         f32,
}

SpriteSheetAction :: struct {
	start: int,
	end:   int,
	depth: int,
}

Player :: struct {
	// state
	pos:            rl.Vector2,
	vel:            rl.Vector2,
	grounded:       bool,
	flip:           bool,
	source:         rl.Rectangle,
	dest:           rl.Rectangle,

	// animations
	sheet:          SpriteSheet,
	actions:        MikeActions,
	current_action: SpriteSheetAction,
}

UpdatePlayer :: proc(player: ^Player) {
	// moving dino
	if (rl.IsKeyDown(.A)) {
		player.vel.x = -400
		player.flip = true
	} else if (rl.IsKeyDown(.D)) {
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

	if (player.pos.y > f32(rl.GetScreenHeight()) - player.dest.height + player.sheet.offset) {
		player.pos.y = f32(rl.GetScreenHeight()) - player.dest.height + player.sheet.offset
		player.grounded = true
	}

	player.sheet.timer += rl.GetFrameTime()

	if (player.sheet.timer > player.sheet.frame_length) {

		if (rl.IsKeyDown(.A) || rl.IsKeyDown(.D)) && player.grounded {
			player.current_action = player.actions.MOVE
		} else if rl.IsKeyDown(.SPACE) || !player.grounded {
			player.current_action = player.actions.JUMP
		} else if rl.IsKeyDown(.LEFT_SHIFT) {
			player.current_action = player.actions.ATTACK1
			if rl.IsKeyPressedRepeat(.LEFT_SHIFT) {
				player.current_action = player.actions.ATTACK2
			}
		} else {
			player.current_action = player.actions.IDLE
		}

		if player.sheet.current_frame < player.current_action.start {
			player.sheet.current_frame = player.current_action.start
		}

		player.sheet.current_frame += 1

		if (player.sheet.current_frame >= player.current_action.end) {
			player.sheet.current_frame = player.current_action.start
		}

		player.sheet.timer = 0
	}

	player.source.x =
		f32(player.sheet.current_frame) *
		f32(player.sheet.texture.width) /
		f32(player.sheet.frames)

	if (player.flip) {
		if (player.source.width > 0) {
			player.source.width = player.source.width * -1
		}
	} else {
		player.source.width = abs(player.source.width)
	}

	player.dest.x = player.pos.x
	player.dest.y = player.pos.y

	rl.DrawTexturePro(player.sheet.texture, player.source, player.dest, 0, 0, rl.WHITE)
}
