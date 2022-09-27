extends Control

onready var Find = $Find
onready var Make = $Make
onready var Main = $Main
onready var Opts = $Opts
onready var Warning = $Warning

const TWEEN_DURATION = 0.15
onready var TWEEN_OFFSET = Vector2(get_viewport().size.x, 0)


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	$Main/VBox/Buttons/VBox/Find.grab_focus()
	for button in get_tree().get_nodes_in_group("returnOpts"):
		button.connect("pressed", self, "_on_Opts_returned")

func _resize(): TWEEN_OFFSET = Vector2(get_viewport().size.x, 0)


# Quitting ------------------------------------------------------------------------------------- #

const QUIT = MainLoop.NOTIFICATION_WM_QUIT_REQUEST

func _on_Quit_pressed(): get_tree().notification(QUIT)

func _notification(what):
	if what == QUIT:
		LOBBY.leave()
		get_tree().quit()


# Popup Menus ----------------------------------------------------------------------------------- #

func _on_Find_pressed(): Find._start()
func _on_Warning(message): Warning._start(message)


# Major/Tweened Menus --------------------------------------------------------------------------- #

func _on_Make_pressed():
	slideR(Main)
	slideR(Make)
	Make._start()

func _on_Make_returned():
	slideL(Main)
	slideL(Make)

func _on_Opts_pressed():
	slideL(Main)
	slideL(Opts)

func _on_Opts_returned():
	slideR(Main)
	slideR(Opts)


# Tweens ---------------------------------------------------------------------------------------- #

func slideL(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position", pos - TWEEN_OFFSET, TWEEN_DURATION)

func slideR(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position", pos + TWEEN_OFFSET, TWEEN_DURATION)
