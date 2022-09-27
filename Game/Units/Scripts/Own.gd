extends "res://Game/Units/Scripts/Unit.gd"

onready var Moves = $Moves


# Built-in Functions
func _ready():
	disconnect("mouse_exited", self, "mouseOut")
	connect("mouse_exited", self, "focusOff")
	connect("input_event", self, "clickUnit")
	set_dir(Anim.global_rotation)
	set_process(false)


# Overriden Functions
func _reset():
	connect("mouse_exited", self, "focusOff")
	connect("input_event", self, "clickUnit")
	toggleEnemies(true)
	rotateAnim(dir)
	Anim.stop()


# Move Toggling
func focusOff():
	toggleMoves(false)
	rotateAnim(dir)

func toggleMoves(val: bool):

	$Moves.visible = val
	$Moves.collision_use_parent = val

	set_process(val)
	toggleEnemies(!val)
	if !val: mouseOut()

func toggleEnemies(val: bool):
	get_tree().call_group("Enemies", "toggleInput", val)


# Move Pickers
func clickUnit(_v, _e, _i):
	if Input.is_action_just_pressed("Click"):
		if is_processing(): sendMove(get_global_mouse_position())
		else: toggleMoves(true)

func _process(_delta):
	var mouse = get_global_mouse_position()
	Anim.look_at(mouse)
	Anim.rotate(-PI/2)


# Signal Emissions
func sendMove(move: Vector2):

	var from = Grid.world_to_map(position)

	move = Moves.to_local(move)
	move = Moves.world_to_map(move)

	if move != Vector2.ZERO:
		var to = from + move
		if Board.isValidMove(to):
			disconnect("mouse_exited", self, "focusOff")
			disconnect("input_event", self, "clickUnit")
			emit_signal("move", from, move)
			toggleMoves(false)

