extends "res://Game/Setup.gd"

onready var Game = get_parent().get_parent()

var unitScene = preload("res://Game/Units/Scenes/Unit.tscn")
var dragScript = load("res://Game/Units/Scripts/Drag.gd")

const _order = [
			[1, 0, 0, 15],
			[3, 0, 0, 15],
			[2, 4, 0, 10],
			[2, 5, 0, 11],
			[2, 6, 7, 12],
			[2, 0, 8, 13],
			[2, 0, 9, 14]]


const order = [   # Test
			[5, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]]


# Built-in Functions
func _ready() -> void:
	specs = Vector2(len(order), len(order[0]))
	$Tiles.collision_use_parent = true
	resetGrid()

# Ready Function
signal finished

func setupFinished():
	if allEmpty():
		queue_free()
		emit_signal("finished")


# Reset Functions
signal reset

func reset():
	emit_signal("reset")
	resetGrid()

func resetGrid():

	resetMap()

	grid = order.duplicate(true)

	for r in range(specs.x):
		for c in range(specs.y):
			var type = grid[r][c]
			if type: createUnit(type, c, r)


# Helper Functions
func createUnit(type: int, x: int, y: int):

	# Unit Creations
	var unit = unitScene.instance()
	unit.set_script(dragScript)
	tiles.add_child(unit)

	# Basic Unit Properties
	var pos = gridToGlobal(x, y)
	unit.add_to_group("Units", true)
	unit.originate(pos, self)
	unit.set_type(type)
	unit.swapAnim(type)

	# Team-based Properties
	if !isHost:
		unit.swapColor()
		if type != 1: unit.face(PI)

	unit.connect("drop", Game, "dropUnit")
	

func gridToGlobal(x: int, y: int) -> Vector2:
	var pos = tiles.map_to_world(Vector2(x, y))
	return pos + tileHalf
