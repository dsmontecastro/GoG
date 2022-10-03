extends "res://Game/_Classes/Setup.gd"

var dragScript = load("res://Game/Units/Scripts/Drag.gd")

const _ORDER = [
			[1, 0, 0, 15],
			[3, 0, 0, 15],
			[2, 4, 0, 10],
			[2, 5, 0, 11],
			[2, 6, 7, 12],
			[2, 0, 8, 13],
			[2, 0, 9, 14]]


const ORDER = [   # Test
			[2, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0]]


# Basic Functions ------------------------------------------------------------------------------- #

func _ready() -> void:
	SPECS = Vector2(len(ORDER), len(ORDER[0]))
	Tiles.collision_use_parent = true
	reset_map()
	reset_arr()

func _start():
	if is_clear():
		queue_free()
		SIGNALS.emit_signal("setup_finished")

func _reset():
	reset_map()
	reset_arr()
	SIGNALS.emit_signal("setup_reset")


# Reset Grid Array ------------------------------------------------------------------------------ #

func reset_arr():

	ARRAY = ORDER.duplicate(true)

	for r in range(SPECS.x):
		for c in range(SPECS.y):
			var type = ARRAY[r][c]
			if type: make_unit(type, r, c)


# Make (Own) Units ------------------------------------------------------------------------------ #

func make_unit(type: int, x: int, y: int):

	var unit = unitScene.instance()
	unit.set_script(dragScript)
	Tiles.add_child(unit)

	if !HOSTING: unit.swap_team()
	unit.set_type(type)

	var pos = get_grid_pos(x, y)
	unit.originate(pos, self)
