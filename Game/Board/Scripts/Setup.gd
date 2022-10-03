extends "res://Game/_Classes/Setup.gd"

onready var Landing = $Landing
onready var Blockade = $Blockade

var ownScript = load("res://Game/Units/Scripts/Own.gd")
var foeScript = load("res://Game/Units/Scripts/Foe.gd")


# Basic Functions ------------------------------------------------------------------------------- #

func _ready() -> void:
	
	SPECS = Vector2(8, 9)
	ARRAY = ROOT.matrix(SPECS.x, SPECS.y, 0)

	toggle_landing(true)
	if !HOSTING: move_landing()


func _start():

	toggle_landing(false)

	make_unit(-1, 0, 0) # test1
	make_unit(-2, 0, 1) # test2
	make_unit(-9, 1, 0) # test3

	for unit in Tiles.get_children():

		var type = unit.TYPE

		if type > 0:
			
			var team = unit.TEAM
			var dir = unit.DIR

			unit._start()
			unit.set_script(ownScript)

			unit.set_type(type)
			unit.set_team(team)
			unit.set_dir(dir)
			unit._ready()


func _reset():
	reset_arr()
	reset_map()


# Toggle Landing for Drag-&-Drop ---------------------------------------------------------------- #

func move_landing():

	var offset1 = tileSize.y * 5
	var offset2 = -(tileSize.y * 3)

	Landing.move_local_y(offset1)
	Blockade.move_local_y(offset2)


func toggle_landing(val: bool) -> void:

	Landing.disabled = !val
	Tiles.collision_use_parent = !val

	var color = Blockade.modulate
	if val: color.a = 1
	else: color.a = 0

	var tween = Blockade.create_tween()
	tween.tween_property(Blockade, "modulate", color, 0.3)\


# Reset Grid Array ------------------------------------------------------------------------------ #

func reset_arr():
	for r in range(SPECS.x):
		for c in range(SPECS.y):
			ARRAY[r][c] = 0


# Make (Enemy) Units ---------------------------------------------------------------------------- #

func make_unit(type: int, x: int, y: int):

	var unit = unitScene.instance()
	unit.set_script(foeScript)
	Tiles.add_child(unit)

	if HOSTING: unit.swap_team()
	unit.set_type(type)

	unit.position = get_grid_pos(x, y)
	ARRAY[x][y] = type
