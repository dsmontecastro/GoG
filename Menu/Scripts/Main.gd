extends Control

# Major Menu Elements
onready var Find = $Find
onready var Make = $Make
onready var Main = $Main
onready var Opts = $Opts
onready var FirstButton = $Main/VBox/Buttons/VBox/Find


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	_reset()
	SIGNALS.connect("play", self, "start_game")
	SIGNALS.connect("exit_opts", self, "opts_exit")

func _start():
	_resize()
	FirstButton.grab_focus()

func _reset(): _start()


#  Scene Change --------------------------------------------------------------------------------- #

func start_game(msg: String):
	print(msg)
	print(LOBBY._debug() + "\n")
	LOADER.change_scene(LOADER.SCENE["GAME"])


#  Menus ---------------------------------------------------------------------------------------- #

func quit(): ROOT.quit()

func find(): Find._start()

func make():
	slideR(Main)
	slideR(Make)
	Make._start()

func make_exit():
	slideL(Main)
	slideL(Make)
	self._start()

func opts():
	slideL(Main)
	slideL(Opts)
	Opts._start()

func opts_exit():
	slideR(Main)
	slideR(Opts)
	self._start()


# Tweens ---------------------------------------------------------------------------------------- #

const TWEEN_DURATION = 0.15
onready var TWEEN_OFFSET = Vector2.ZERO

func _resize(): TWEEN_OFFSET = Vector2(get_viewport().size.x, 0)

func slideL(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position", pos - TWEEN_OFFSET, TWEEN_DURATION)

func slideR(object: Control):
	var pos = object.rect_position
	var tween = create_tween()
	tween.tween_property(object, "rect_position", pos + TWEEN_OFFSET, TWEEN_DURATION)
