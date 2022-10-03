extends "res://Game/Units/Scripts/Unit.gd"


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	add_to_group("Units", true)
	add_to_group("Enemies", true)
	connect("input_event", self, "cycle_unit")
	Glitch.show()


# Cycling Toggle -------------------------------------------------------------------------------- #

var ACTIVE = true
func toggle(val: bool): ACTIVE = val


# Icon Cycling ---------------------------------------------------------------------------------- #

var ICON = 16

func cycle_unit(_v, _e, _i):

	if not ACTIVE: return

	var click = Input.is_action_just_pressed("Click")
	var swapUp = Input.is_action_just_pressed("SwapUp")
	var swapDown = Input.is_action_just_pressed("SwapDown")

	var newIcon = ICON
	if click or swapUp: newIcon += 1
	elif swapDown: newIcon -= 1
	
	if newIcon != ICON: cycle(newIcon)


# Helper Functions ------------------------------------------------------------------------------ #

func cycle(val: int):
	ICON = val % TYPES
	swap_anim(ICON)
	redirect(ICON)

func redirect(val: int):
	if TEAM == -1:
		if val > 1: face_anim(DIR + PI)
		else: face_anim(0)
