extends Area2D

var unitScene = preload("res://Game/Units/Scenes/Unit.tscn")


# Tilemap Info ---------------------------------------------------------------------------------- #

onready var Tiles = $Tiles
onready var tileSize = Tiles.get_cell_size()
onready var tileHalf = tileSize / 2

var SPECS = Vector2.ZERO
var ARRAY = []


# Basic Functions (to be Overriden) ------------------------------------------------------------- #

func _ready(): pass
	#SIGNALS.connect("game_play", self, "game_play")
	#SIGNALS.connect("game_over", self, "game_over")
	#SIGNALS.connect("setup_ready", self, "setup_ready")
	#SIGNALS.connect("setup_reset", self, "setup_reset")

func _start(): pass
func _reset(): pass


# Setup Functions ------------------------------------------------------------------------------- #

func setup_reset(): pass
func setup_ready(_val: bool): pass


# Empty Checkers -------------------------------------------------------------------------------- #

func is_empty(x: int, y: int) -> bool: return ARRAY[y][x] == null

func is_clear() -> bool:
	for r in range(SPECS.x):
		for c in range(SPECS.y):
			if ARRAY[r][c] != null:
				return false
	return true


# Grid-to-Position (Transposed) ----------------------------------------------------------------- #

func get_grid_idx(pos: Vector2): return Tiles.world_to_map(pos)

func get_grid_pos(x: int, y: int) -> Vector2:	
	var pos = Tiles.map_to_world(Vector2(y, x))
	return pos + tileHalf


# Reset Functions ------------------------------------------------------------------------------- #

func reset_map():
	for node in Tiles.get_children():
		Tiles.remove_child(node)
		node.queue_free()

func reset_arr():
	for r in range(SPECS.x):
		for c in range(SPECS.y):
			ARRAY[r][c] = null


func null_matrix(rows: int, cols: int) -> Array:

	var matrix = []

	for _i in range(rows):
		var row = []
		row.resize(cols)
		matrix.append(row)

	return matrix


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
