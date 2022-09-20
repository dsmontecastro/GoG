extends Area2D

# Differentiate White/Black Teams
onready var isHost = GlobalSteam.isHost

# Tilemap Specs
onready var tiles = $Tiles
onready var tileSize = tiles.get_cell_size()
onready var tileHalf = tileSize / 2

# Grid Specs (to be set in _ready() functions)
var specs = Vector2.ZERO
var grid = []


# Reset Functions
func resetMap():
	for node in tiles.get_children():
		tiles.remove_child(node)
		node.queue_free()


# Cell-check Functions
func isEmpty(x: int, y: int) -> bool:
	return !grid[x][y]

func allEmpty() -> bool:
	for r in range(specs.x):
		for c in range(specs.y):
			if grid[r][c]:
				return false
	return true
