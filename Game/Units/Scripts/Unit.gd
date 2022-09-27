extends Area2D

# Resusable Refs
var Board = null
var Grid = null
var Anim = null
var Kill = null
var Filter = null
var Glitch = null


# Built-in Functions
func _init():

	Anim = $Anim
	Kill = $Kill
	Filter = $Filters
	Glitch = $Filters/Glitch

	Grid = get_parent()
	if Grid != null:
		Board = Grid.get_parent()
	else: Board = null

func _ready():
	Kill.connect("animation_finished", self, "queue_free")
	connect("mouse_entered", self, "mouseIn")
	connect("mouse_exited", self, "mouseOut")
	add_to_group("Units", true)
	randomize()


# To be Overriden
func _reset(): pass


# Mouse Handling
func mouseIn():
	rescale(bigger)
	playAnim()

func mouseOut():
	rescale(normal)
	exitAnim()


# Toggle Pickability
func areaToggle(val: bool):
	input_pickable = val
	monitorable = val
	monitoring = val


# Animations
func swapAnim(val: int):
	Anim.animation = "%02dA" % val
	Anim.stop()

func playAnim():
	if type > 0:
		var _anim = Anim.animation
		_anim[-1] = "A"
		Anim.play(_anim)

func exitAnim():
	if type > 0:
		var _anim = Anim.animation
		_anim[-1] = "B"
		Anim.play(_anim)


# Animation Direction
var dir = 0

func set_dir(val: float):
	dir = val
	faceAnim(val)

func faceAnim(val: float): Anim.global_rotation = val

func rotateAnim(val: float):

	if (val - Anim.global_rotation) > PI: val += 2 * PI

	var tween = Anim.create_tween()
	tween.tween_property(Anim, "global_rotation", val, 0.25)


# Death Animation
const kills = 3

func die():

	var anim = randi() % kills
	Kill.play("%02d" % anim)

	yield(get_tree().create_timer(1.0), "timeout")
	Glitch.hide()
	Anim.hide()


# Scale Tween
const normal = Vector2(0.1, 0.1)
const bigger = normal * 1.1

func rescale(val: Vector2):
	var tween = create_tween()
	tween.tween_property(Anim, "scale", val, 0.25)


# Movement Tween
signal move(unit, move)

func move(cell: Vector2):

	if Grid == null: return

	var tween = create_tween()
	var move = Grid.map_to_world(cell) + Board.tileHalf
	tween.tween_property(self, "position", move, 0.25)

	yield(get_tree().create_timer(0.25), "timeout")
	_reset()


# Type/Team Swapping
var type = 0
func set_type(val: int):
	type = val
	print(val)
	if val > 0: swapAnim(val)
	else: swapAnim(0)

onready var team = 1
func swapTeam():
	team *= -1
	swapColor()
	if type != 1: set_dir(PI)

func swapColor():
	Anim.material = load("res://Shaders/Invert.material")
	Anim.modulate = Color(0.25, 0.25, 0.25) # Match to Board Color
	Anim.visible = true
