extends "res://Game/Units/Scripts/Unit.gd"


# Built-in Functions
func _ready():
	connect("input_event", self, "clickUnit")
	Glitch.show()


# Clicking Handler
onready var icon = 16
onready var clickable = true

func toggleInput(val: bool): clickable = val

func clickUnit(_v, _e, _i):

	if !clickable: return

	var click = Input.is_action_just_pressed("Click")
	var swapUp = Input.is_action_just_pressed("SwapUp")
	var swapDown = Input.is_action_just_pressed("SwapDown")

	var newIcon = icon
	if click or swapUp: newIcon += 1
	elif swapDown: newIcon -= 1
	
	if newIcon != icon: cycleIcon(newIcon)


# Helper Functions
const types = 16
func cycleIcon(val: int):
	icon = val % types
	orientIcon(icon)
	swapAnim(icon)

#const exempt = [1, 16]
func orientIcon(val: int):
	if team > 0: return
	#if val in exempt: face(0)
	if val > 1: faceAnim(dir + PI)
	else: faceAnim(0)
