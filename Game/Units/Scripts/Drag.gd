extends "res://Game/Units/Scripts/Unit.gd"


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	connect("area_entered", self, "area_entered")
	connect("area_exited", self, "area_exited")
	connect("input_event", self, "drag_unit")
	add_to_group("Units", true)
	set_process(false)

func _start(): #: Is this necessary?
	disconnect("area_entered", self, "area_entered")
	disconnect("area_exited", self, "area_exited")
	disconnect("input_event", self, "drag_unit")

func _reset(): set_global_position(ORIGIN)


# Initalizing Origin (for resetting Drag-&-Drop) ------------------------------------------------ #

var ORIGIN = Vector2.ZERO
func originate(pos: Vector2, area: Area2D):
	currArea = area
	set_position(pos)
	ORIGIN = global_position


# Area Tracking (for validating Drag-&-Drop) ---------------------------------------------------- #

var currArea: Area2D = null
func area_entered(area: Area2D): currArea = area
func area_exited(_area: Area2D): currArea = null


# Drag-&-Drop Functions ------------------------------------------------------------------------- #

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var new_pos = lerp(global_position, mouse_pos, 25 * delta)
	set_global_position(new_pos)


const GROUP = "Units"
func toggle_drag(val: bool):

	if val:
		z_index = 10
		if GROUP in get_groups():
			remove_from_group(GROUP)
	else:
		z_index = 0
		add_to_group(GROUP)

	get_tree().call_group(GROUP, "mouse_toggle", !val)
	set_process(val)


func drag_unit(_vp, _event, _idx):

	var locked = is_processing()

	if not locked and Input.is_action_just_pressed("Click"): toggle_drag(true)

	elif locked and Input.is_action_just_released("Click"):

		toggle_drag(false)

		if currArea == null: _reset()

		else: SIGNALS.emit_signal("drop", self, get_global_mouse_position())


func drop_unit(pos: Vector2):

	var t_size = get_parent().get_cell_size()
	var offset = t_size / 2

	position = pos * t_size + offset
	ORIGIN = global_position
