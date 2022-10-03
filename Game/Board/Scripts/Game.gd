extends Area2D

onready var Game = get_parent()

var EDGE = 0


# Tilemap Info ---------------------------------------------------------------------------------- #

onready var Tiles = $Tiles
onready var tileSize = Tiles.get_cell_size()
onready var tileHalf = tileSize / 2

const SPECS = Vector2(8, 9)
var ARRAY = []


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():

	SIGNALS.connect("move", self, "process_move")

	if USER.isHost: EDGE = SPECS.y - 1

	ARRAY = ROOT.matrix(SPECS.x, SPECS.y)

	for unit in Tiles.get_children():
		var pos = Tiles.world_to_map(unit.position)
		ARRAY[pos.y][pos.x] = unit


# Movement Processing --------------------------------------------------------------------------- #

func is_valid_move(to: Vector2) -> bool:
	return to.y in range(SPECS.x) and to.x in range(SPECS.y)

func process_move(from: Vector2, move: Vector2):

	move += from
	var unit = ARRAY[from.y][from.x]
	var cell = ARRAY[move.y][move.x]


	# Unit moves to free-space
	if cell == null: move_unit(from, move, true)

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


# Unit-based Functions -------------------------------------------------------------------------- #

func kill_unit(pos: Vector2, send: bool = false):

	# if send: emit_steam_signal("kill", move)

	var unit = ARRAY[pos.y][pos.x]
	ARRAY[pos.y][pos.x] = null
	unit.die()

	#print("Kill: %d @ (%d:%d)" % [unit.type, pos.y, pos.x] )


func move_unit(from: Vector2, move: Vector2, send: bool = false):

	# if send: emit_steam_signal("move", from, move)

	var unit = ARRAY[from.y][from.x]
	ARRAY[from.y][from.x] = null
	ARRAY[move.y][move.x] = unit

	unit.move(move)

	#print("Move: %d to (%d:%d)" % [unit.type, move.y, move.x] )

	# Flag moves to Opposite End
	if unit.TYPE == 1 and move.x == EDGE:
		SIGNALS.emit_signal("gameOver", true)


# :DEBUGGING: ----------------------------------------------------------------------------------- #

func printGrid():
	for r in range(SPECS.x):
		var row = ""
		for c in range(SPECS.y):
			var unit = ARRAY[r][c]
			var type = 0
			if unit != null:
				type = unit.TYPE
			row += ("%0+3d " % type)
		print(row)
	print()
