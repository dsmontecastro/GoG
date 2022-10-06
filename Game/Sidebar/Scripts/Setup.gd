extends "res://Game/_Classes/Setup.gd"

var dragScript = load("res://Game/Units/Scripts/Drag.gd")
onready var Ready = $"%Ready"
onready var Reset = $"%Reset"


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	SPECS = Vector2(len(ORDER), len(ORDER[0]))
	ARRAY = null_matrix(SPECS.x, SPECS.y)
	Tiles.collision_use_parent = true
	reset_arr()

func _start(): pass
func _reset(): pass


# In-game Functions ----------------------------------------------------------------------------- #

func game_play():
	self.hide()

func game_over():
	self.show()


# Setup Functions ------------------------------------------------------------------------------- #

func reset_pressed(): SIGNALS.emit_signal("setup_reset")

func ready_toggled(val: bool):
	if is_clear(): SIGNALS.emit_signal("setup_ready", val)
	else: Ready.set_pressed_no_signal(false)


func setup_reset():
	Ready.set_pressed_no_signal(false)
	reset_map()
	reset_arr()

func setup_ready(val: bool):

	var alpha = 1.0
	if val: alpha = 0.5

	var tween = Tiles.create_tween()
	tween.tween_property(Tiles, "modulate:a", alpha, 0.25)


# Reset Grid Array ------------------------------------------------------------------------------ #

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


func reset_arr():
	for r in range(SPECS.x):
		for c in range(SPECS.y):
			var type = ORDER[r][c]
			if type: make_ally(type, r, c)
			else: ARRAY[r][c] = null


func make_ally(type: int, x: int, y: int):

	var ally = unitScene.instance()
	ally.set_script(dragScript)
	Tiles.add_child(ally)

	if not USER.HOSTING:
		ally.swap_team()
	ally.set_type(type)

	var pos = get_grid_pos(x, y)
	ally.originate(pos, self)
	ARRAY[x][y] = ally
