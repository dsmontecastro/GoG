extends "res://Game/Units/Scripts/Unit.gd"

# Path Constants (isValid)
const gridMap = "/root/Game/Board/Tiles"
const setupMap = "/root/Game/Sidebar/Setup/Tiles"

# Group Constants (toggleDrag)
const group = "Units"
const gFunc = "areaToggle"


# Trackers
var origin = Vector2.ZERO
var currArea = null


# Inherited Functions
func _ready():
	connect("area_entered", self, "areaEntered")
	connect("area_exited", self, "areaExited")
	connect("input_event", self, "dragUnit")
	set_process(false)


# Disconnect Signals
func setupFinished():
	disconnect("area_entered", self, "areaEntered")
	disconnect("area_exited", self, "areaExited")
	disconnect("input_event", self, "dragUnit")


# Initalization (during Setup)
func originate(pos: Vector2, area: Area2D):
	currArea = area
	set_position(pos)
	origin = global_position


# Area Tracking
func areaEntered(area: Area2D): currArea = area
func areaExited(_area: Area2D): currArea = null


# Dragging and Positioning
signal drop(unit, move)

func dragUnit(_vp, _event, _idx):
	var locked = is_processing()
	if not locked and Input.is_action_just_pressed("Click"):
		toggleDrag(true)
	elif locked and Input.is_action_just_released("Click"):
		toggleDrag(false)
		if currArea != null:
			var pos = get_global_mouse_position()
			emit_signal("drop", self, pos)
		else: set_global_position(origin)

func _process(delta):
	var mouse = get_global_mouse_position()
	var pos = lerp(global_position, mouse, 25 * delta)
	set_global_position(pos)


# Helper Functions
func toggleDrag(val: bool):

	if val:
		z_index = 9
		if group in get_groups():
			remove_from_group(group)
	else:
		z_index = 0
		add_to_group(group)

	get_tree().call_group(group, gFunc, !val)
	set_process(val)


func positionByIndex(pos: Vector2):

	var t_size = get_parent().get_cell_size()
	var offset = t_size / 2

	position = pos * t_size + offset
	origin = global_position
