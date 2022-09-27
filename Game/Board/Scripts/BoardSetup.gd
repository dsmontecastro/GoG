extends "res://Game/Setup.gd"

onready var Game = get_parent()
onready var Landing = $Landing
onready var Blockade = $Blockade

var ownScript = load("res://Game/Units/Scripts/Own.gd")
var foeScript = load("res://Game/Units/Scripts/Foe.gd")


# Built-in Functions
func _ready() -> void:
	
	specs = Vector2(8, 9)

	for r in range(specs.x):
		grid.append([])
		for _c in range(specs.y):
			grid[r].append(0)

	if !isHost:
		var offset = tileSize.y * 5
		Landing.move_local_y(offset)
		offset = -(tileSize.y * 3)
		Blockade.move_local_y(offset)

	toggleLanding(true)


# Ready Functions
func setupFinished():

	toggleLanding(false)

	createEnemy(-1, 0, 0) # test1
	createEnemy(-2, 0, 1) # test2
	createEnemy(-9, 1, 0) # test3

	for unit in tiles.get_children():

		var type = unit.type
		if type > 0:
			unit.setupFinished()
			unit.set_script(ownScript)
			unit.set_type(type)
			unit._ready()

func toggleLanding(val: bool) -> void:

	Landing.disabled = !val
	tiles.collision_use_parent = !val

	var color = Blockade.modulate
	if val: color.a = 1
	else: color.a = 0

	var tween = Blockade.create_tween()
	tween.tween_property(Blockade, "modulate", color, 0.3)\


# Reset Functions
func reset():
	resetGrid()
	resetMap()

func resetGrid() -> void:
	for r in range(specs.x):
		for c in range(specs.y):
			grid[r][c] = null


# Place Enemies
func createEnemy(type: int, x: int, y: int):

	# Unit Creations
	var unit = unitScene.instance()

	unit.set_script(foeScript)
	if isHost: unit.swapColor()
	unit.set_type(type)

	unit.position = gridToGlobal(x, y)
	grid[x][y] = type

	tiles.add_child(unit)
	unit.add_to_group("Enemies", true)
	unit.connect("move", Game, "moveUnit")
