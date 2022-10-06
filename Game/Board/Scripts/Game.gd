extends "res://Game/Board/Scripts/Setup.gd"

var EDGE = 0


# Gameplay Functions ---------------------------------------------------------------------------- #

func _play():
	print("BP: Game")
	SIGNALS.connect("move", self, "process_move")
	SIGNALS.connect("game_over", self, "_over")
	if USER.HOSTING: EDGE = SPECS.y - 1

func _over(win: bool):

	if win: pass

	else: pass


# Move Processing ------------------------------------------------------------------------------- #

func is_valid_move(to: Vector2) -> bool:
	return to.y in range(SPECS.x) and to.x in range(SPECS.y)

func process_move(from: Vector2, move: Vector2):

	move += from
	var unit = ARRAY[from.y][from.x]
	var cell = ARRAY[move.y][move.x]


	# Unit moves to free-space
	if cell == null:
		move_unit(from, move, true)
		SIGNALS.emit_signal("end_turn")

	# Unit confronts Enemy
	elif unit.TEAM != cell.TEAM:

		var u = unit.TYPE
		var c = abs(cell.TYPE)

		# Unit Loss
		if (u == 15 and c == 2): kill_unit(from, true)
		elif u < c and not (u == 2 and c == 15): kill_unit(from, true)

		else:	# Unit Win

			kill_unit(move, true)
			yield(SIGNALS, "done_killing")

			move_unit(from, move, true)
			yield(SIGNALS, "done_moving")

			if c == 1: SIGNALS.emit_signal("game_over", true)

		SIGNALS.emit_signal("end_turn")


# Unit-based Functions -------------------------------------------------------------------------- #

func kill_unit(pos: Vector2, send: bool = false):

	if send: P2P.send(P2P.MSSG.KILL_UNIT, pos)

	var unit = ARRAY[pos.y][pos.x]
	ARRAY[pos.y][pos.x] = null
	unit.die()

	#print("Kill: %d @ (%d:%d)" % [unit.type, pos.y, pos.x] )


func move_unit(from: Vector2, move: Vector2, send: bool = false):

	if send: P2P.send(P2P.MSSG.MOVE_UNIT, [from, move])

	var unit = ARRAY[from.y][from.x]
	ARRAY[from.y][from.x] = null
	ARRAY[move.y][move.x] = unit
	unit.move(move)

	#print("Move: %d to (%d:%d)" % [unit.type, move.y, move.x] )

	# Flag moves to Opposite End
	if unit.TYPE == 1 and move.x == EDGE:
		SIGNALS.emit_signal("game_over", true)
