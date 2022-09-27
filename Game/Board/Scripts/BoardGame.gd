extends Area2D

onready var Game = get_parent()


# Grid Specs (to be set in _ready() functions)
var specs = Vector2.ZERO
var grid = []

# Tilemap Specs
onready var tiles = $Tiles
onready var tileSize = tiles.get_cell_size()
onready var tileHalf = tileSize / 2


# Built-in Functions
func _ready() -> void:

	specs = Vector2(8, 9)
	#Game.connect("victory")

	for r in range(specs.x):
		grid.append([])
		for _c in range(specs.y):
			grid[r].append(null)

	for unit in tiles.get_children():

		var pos = unit.position
		pos = tiles.world_to_map(pos)
		grid[pos.y][pos.x] = unit

		unit.connect("move", self, "moveUnit")
		if unit.type > 0:
			unit.disconnect("drop", Game, "dropUnit")

# Artificial Delay
func _wait(val: float):
	yield(get_tree().create_timer(val), "timeout")


# Unit Movement
signal gameOver(win)

func isValidMove(to: Vector2):
	return to.y in range(specs.x) and to.x in range(specs.y)

func moveUnit(from: Vector2, move: Vector2):

	move += from
	var unit = grid[from.y][from.x]
	var cell = grid[move.y][move.x]

	# Unit moves to free-space
	if unit == null or cell == null: move(from, move, true)

	# Unit Match-up
	else:
		var u = unit.type
		var c = abs(cell.type)

		# Unit Loss
		if (u == 15 and c == 2): kill(from, true)
		elif u < c and not (u == 2 and c == 15): kill(from, true)

		# Unit Win
		else:

			kill(move, true)
			yield(get_tree().create_timer(1.5), "timeout")

			move(from, move, true)
			if c == 1: emit_signal("gameOver", true)


# Helper Functions
func kill(pos: Vector2, send: bool = false):

	# if send: emit_steam_signal("kill", move)

	var unit = grid[pos.y][pos.x]
	grid[pos.y][pos.x] = null
	unit.die()

	#print("Kill: %d @ (%d:%d)" % [unit.type, pos.y, pos.x] )

func move(from: Vector2, move: Vector2, send: bool = false):

		# if send: emit_steam_signal("move", from, move)

		var unit = grid[from.y][from.x]
		grid[from.y][from.x] = null
		grid[move.y][move.x] = unit

		#print("Move: %d to (%d:%d)" % [unit.type, move.y, move.x] )

		unit.move(move)

		# Flag moves to Opposite End 
		if unit.type == 1 and move.y == 0:
			emit_signal("gameOver", true)


# Debugging
func printGrid():
	for r in range(specs.x):
		var row = ""
		for c in range(specs.y):
			var unit = grid[r][c]
			var type = 0
			if unit != null:
				type = unit.type
			row += ("%0+3d " % type)
		print(row)
	print()
