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

	for r in range(specs.x):
		grid.append([])
		for _c in range(specs.y):
			grid[r].append(null)

	test()

	for unit in tiles.get_children():

		var pos = unit.position
		pos = tiles.world_to_map(pos)
		grid[pos.y][pos.x] = unit

		unit.connect("move", Game, "moveUnit")
		if unit.type > 0:
			unit.disconnect("drop", Game, "dropUnit")


func moveUnit(from: Vector2, move: Vector2):
	print(from, " to ", move)


# Testing
var unitScene = preload("res://Game/Units/Scenes/Unit.tscn")
var foeScript = load("res://Game/Units/Scripts/Foe.gd")

func test():

	var type = -15
	var pos = Vector2.ZERO

	
	var unit = unitScene.instance()
	tiles.add_child(unit)

	unit.set_script(foeScript)
	unit.set_type(type)
	unit._ready()

	if GlobalSteam.isHost:
		unit.swapColor()
		#unit.face(PI)

	pos = tiles.map_to_world(pos)
	unit.position = pos + tileHalf

	grid[pos.y][pos.x] = unit
