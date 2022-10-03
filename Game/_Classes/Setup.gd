extends Area2D

var unitScene = preload("res://Game/Units/Scenes/Unit.tscn")

onready var HOSTING = USER.isHost	# decide if unit swaps team


# Tilemap Info ---------------------------------------------------------------------------------- #

onready var Tiles = $Tiles
onready var tileSize = Tiles.get_cell_size()
onready var tileHalf = tileSize / 2

var SPECS = Vector2.ZERO
var ARRAY = []


# Basic Functions (To Override) ----------------------------------------------------------------- #

func _ready(): pass
func _start(): pass
func _reset(): pass


# Empty Checkers -------------------------------------------------------------------------------- #

func is_empty(x: int, y: int) -> bool: return !ARRAY[y][x]

func is_clear() -> bool:
	for r in range(SPECS.x):
		for c in range(SPECS.y):
			if ARRAY[r][c]:
				return false
	return true


# Reset Tilemap --------------------------------------------------------------------------------- #

func reset_map():
	for node in Tiles.get_children():
		Tiles.remove_child(node)
		node.queue_free()


# Grid-to-Position ------------------------------------------------------------------------------ #
# :Note: Indices are transposed ----------------------------------------------------------------- #

func get_grid_pos(x: int, y: int) -> Vector2:	
	var pos = Tiles.map_to_world(Vector2(y, x))
	return pos + tileHalf
