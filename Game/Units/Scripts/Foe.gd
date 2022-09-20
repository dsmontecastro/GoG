extends "res://Game/Units/Scripts/Unit.gd"

onready var icon = 16

# Built-in Functions
func _ready():
	connect("input_event", self, "clickUnit")
	swapIcon(icon)


# Clicking Handler

func clickUnit(_v, _e, _i):

	var click = Input.is_action_just_pressed("Click")
	var swapUp = Input.is_action_just_pressed("SwapUp")
	var swapDown = Input.is_action_just_pressed("SwapDown")

	var newIcon = icon
	if click or swapUp: newIcon += 1
	elif swapDown: newIcon -= 1
	
	if newIcon != icon: swapUnit(newIcon)


# Helper Functions
func swapUnit(newIcon: int) -> void:
	icon = clampType(newIcon)
	swapIcon(icon)
	orient()

const types = 16
func clampType(val: int) -> int:
	val = val % types
	if !val: val = 16
	return val

func orient():

	if team > 0: return
	var flag = (icon == 1) or (icon == 16)
	if flag: face(0)
	else: face(PI)
