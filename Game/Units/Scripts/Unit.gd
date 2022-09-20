extends Area2D



# Built-in Functions
func _ready():
	connect("mouse_entered", self, "mouseIn")
	connect("mouse_exited", self, "mouseOut")
	


# Movement (Index)
#onready var Board = get_node("/root/Game/")
signal move(unit, move)

func moveUnit(cell: Vector2):
	var grid = get_parent()
	if grid != null:
		var pos = get_parent().map_to_world(cell)
		position = pos + grid.tileHalf


# Mouse Handling
func mouseIn():
	scaleUp()
	playAnim()

func mouseOut():
	scaleDown()
	exitAnim()


# Animation
func stopAnim(): $Anim.stop()
func playAnim(): $Anim.play("default")
func exitAnim(): $Anim.play("exit")


# Tweens

const normal = Vector2(0.1, 0.1)
const bigger = normal * 1.25

func scaleUp():
	var tween = create_tween()
	tween.tween_property($Anim, "scale", bigger, 0.25)

func scaleDown():
	var tween = create_tween()
	tween.tween_property($Anim, "scale", normal, 0.25)



# Team Swapping
const invertColor = Color(0.25, 0.25, 0.25)
var invertShader = load("res://Game/Shaders/Invert.material")

func swapColor():
	swapTeam()
	$Anim.material = invertShader
	$Anim.self_modulate = invertColor
	$Icon.self_modulate = invertColor
	$Icon.material = invertShader

func face(val: float):
	$Anim.global_rotation = val
	$Icon.global_rotation = val


# Type Swapping
var type = 0
func set_type(val: int): type = val

var team = 1
func swapTeam(): team *= -1

const iconPath = "res://Game/Units/Assets/Frames/%02d/01.png"
func swapIcon(val: int):
	if val:
		var icon = (iconPath % abs(val))
		$Icon.texture = load(icon)

const animPath = "res://Game/Units/Assets/%02d.tres"
func swapAnim(val: int):
	if val:
		var anim = (animPath % abs(val))
		$Anim.frames = load(anim)
