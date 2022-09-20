extends "res://Game/Units/Scripts/Unit.gd"

onready var Moves = $Moves


# Built-in Functions
func _ready():
	disconnect("mouse_exited", self, "mouseOut")
	connect("mouse_exited", self, "focusOff")
	connect("input_event", self, "clickUnit")


# Toggling Move State
onready var isMoving = false
func focusOff(): toggleMoves(false)

func toggleMoves(val: bool):
	isMoving = val
	$Moves.visible = val
	$Moves.collision_use_parent = val
	if !val: mouseOut()


# Clicking Handler
func clickUnit(_v, _e, _i):
	if Input.is_action_just_pressed("Click"):
		if isMoving: sendMove(get_global_mouse_position())
		else: toggleMoves(true)

func sendMove(move: Vector2):

	var from = get_parent().world_to_map(position)

	move = Moves.to_local(move)
	move = Moves.world_to_map(move)

	emit_signal("move", from, move + from)
