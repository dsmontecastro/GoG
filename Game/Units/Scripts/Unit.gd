extends Area2D


# Initializing References ----------------------------------------------------------------------- #

var Board = null
var Grid = null
var Anim = null
var Kill = null
var Filter = null
var Glitch = null

func _init():

	Anim = $Anim
	Kill = $Kill
	Filter = $Filters
	Glitch = $Filters/Glitch

	Grid = get_parent()
	if Grid != null:
		Board = Grid.get_parent()
	else: Board = null


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	connect("mouse_entered", self, "mouse_in")
	connect("mouse_exited", self, "mouse_out")
	add_to_group("Units", true)
	randomize()

func _start(): pass
func _reset(): pass


# Type & Team Setting --------------------------------------------------------------------------- #

var TEAM = 1
var TYPE = 0
const TYPES = 16

func set_type(val: int):
	TYPE = val
	if val <= 0: val = 0
	swap_anim(val)

func set_team(val: int): TEAM = val

func swap_team():
	TEAM *= -1
	swap_color()
	if TYPE != 1: set_dir(PI)

const invertModulate = Color(0.25, 0.25, 0.25)	# Matches Board Color
var invertMaterial = load("res://_Misc/Shaders/Invert.material")

func swap_color():
	Anim.material = invertMaterial
	Anim.modulate = invertModulate
	Anim.visible = true


# Mouse Handling -------------------------------------------------------------------------------- #

func mouse_in():
	rescale(BIGGER)
	play_anim()

func mouse_out():
	rescale(NORMAL)
	exit_anim()

func mouse_toggle(val: bool):
	input_pickable = val
	monitorable = val
	monitoring = val


# Scale Pop Tweening ---------------------------------------------------------------------------- #

const NORMAL = Vector2(0.1, 0.1)
const BIGGER = NORMAL * 1.1

func rescale(val: Vector2):
	var tween = create_tween()
	tween.tween_property(Anim, "scale", val, 0.25)


# Animation Controls (Media) -------------------------------------------------------------------- #

func swap_anim(val: int):
	Anim.animation = "%02dA" % val
	Anim.stop()

func play_anim():
	if TYPE > 0:
		var anim = Anim.animation
		anim[-1] = "A"
		Anim.play(anim)

func exit_anim():
	if TYPE > 0:
		var anim = Anim.animation
		anim[-1] = "B"
		Anim.play(anim)


# Animation Controls (Direction) ---------------------------------------------------------------- #

var DIR = 0

func set_dir(val: float):
	DIR = val
	face_anim(val)

func face_anim(val: float): Anim.global_rotation = val

func spin_anim(val: float = DIR):

	if abs(val - Anim.global_rotation) > PI: val += 2 * PI

	var tween = Anim.create_tween()
	tween.tween_property(Anim, "global_rotation", val, 0.25)


# Movement Controls ----------------------------------------------------------------------------- #

func move(cell: Vector2):

	if Grid == null: return

	var tween = create_tween()
	var move = Grid.map_to_world(cell) + Board.tileHalf
	tween.tween_property(self, "position", move, 0.25)

	yield(tween, "finished")
	_reset()

	SIGNALS.emit_signal("done_moving")


# Death Animations ------------------------------------------------------------------------------ #

enum KILLS { BURST, SLICE, PIXEL }

func die():

	var anim = randi() % KILLS.size()
	Kill.play("%02d" % anim)
	
	yield(get_tree().create_timer(1.0), "timeout")
	Glitch.hide()
	Anim.hide()

	yield(Kill, "animation_finished")
	queue_free()

	SIGNALS.emit_signal("done_killing")
