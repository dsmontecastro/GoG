extends "res://Game/Units/Scripts/Unit.gd"

onready var Moves = $Moves


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	add_to_group("Units", true)
	add_to_group("Allies", true)
	disconnect("mouse_exited", self, "mouse_out")
	connect("input_event", self, "move_unit")
	connect("mouse_exited", self, "unfocus")
	set_dir(Anim.global_rotation)
	set_process(false)

func _reset():
	connect("input_event", self, "move_unit")
	connect("mouse_exited", self, "unfocus")
	toggle_foes(true)
	spin_anim(DIR)
	Anim.stop()


# Basic Functions ------------------------------------------------------------------------------- #

func unfocus():
	toggle_moves(false)
	spin_anim(DIR)

func toggle_foes(val: bool):
	get_tree().call_group("Enemies", "toggle", val)

func toggle_moves(val: bool):

	set_process(val)
	toggle_foes(!val)
	if !val: mouse_out()

	Moves.visible = val
	Moves.collision_use_parent = val



# Movement Functions --------------------------------------------------------------------------- #

func move_unit(_v, _e, _i):
	if Input.is_action_just_pressed("Click"):
		if is_processing() and USER.IS_TURN:
			send_move(get_global_mouse_position())
		else: toggle_moves(true)


func send_move(move: Vector2):

	var from = Grid.world_to_map(position)

	move = Moves.to_local(move)
	move = Moves.world_to_map(move)

	if move != Vector2.ZERO:
		if Board.is_valid_move(from + move):
			disconnect("input_event", self, "move_unit")
			disconnect("mouse_exited", self, "unfocus")
			SIGNALS.emit_signal("move", from, move)
			toggle_moves(false)


# Orient towards Mouse -------------------------------------------------------------------------- #

func _process(_delta):
	var mouse = get_global_mouse_position()
	Anim.look_at(mouse)
	Anim.rotate(-PI/2)
