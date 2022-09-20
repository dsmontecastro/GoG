extends Control

const TWEEN_DURATION = 0.15
onready var TWEEN_OFFSET = Vector2(get_viewport().size.x, 0)


func _ready():
	$Main/VBox/Buttons/VBox/Find.grab_focus()
	for button in get_tree().get_nodes_in_group("returnOpts"):
		button.connect("pressed", self, "_on_Opts_returned")

func _on_menuMain_resized():
	TWEEN_OFFSET = Vector2(get_viewport().size.x, 0)


func slideL(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position",
			pos - TWEEN_OFFSET, TWEEN_DURATION)

func slideR(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position",
			pos + TWEEN_OFFSET, TWEEN_DURATION)


func _on_Find_pressed():
	$Find.visible = true
	$Main.visible = false

func _on_Find_returned():
	$Main.visible = true
	$Find.visible = false


func _on_Make_pressed():
	slideR($Main)
	slideR($Make)

func _on_Make_returned():
	slideL($Main)
	slideL($Make)


func _on_Opts_pressed():
	slideL($Main)
	slideL($Opts)

func _on_Opts_returned():
	slideR($Main)
	slideR($Opts)


func _on_Quit_pressed():
	get_tree().quit()


