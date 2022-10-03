extends CanvasLayer

func _ready(): _reset()


# Starting and Resetting ------------------------------------------------------------------------ #

signal finished_playing
signal finished_exiting

func _start():
	show_logo()
	play_anim(false)
	yield(Anim, "animation_finished")
	emit_signal("finished_playing")

func _reset():
	hide_logo()
	play_anim(true)
	yield(Anim, "animation_finished")
	swap_anim()
	emit_signal("finished_exiting")


# Logo Tweens ----------------------------------------------------------------------------------- #

const delay = 0.5
onready var Logo = $Logo

const a = Vector2(1.0, 1.0)

func show_logo():
	var tween = Logo.create_tween()
	tween.tween_property(Logo, "scale", a, delay)
	tween.tween_property(Logo, "modulate:a", 1.0, delay)
	set_process(true)

const b = Vector2(0.1, 0.1)

func hide_logo():
	var tween = Logo.create_tween()
	tween.tween_property(Logo, "scale", b, delay)
	tween.tween_property(Logo, "modulate:a", 0.0, delay)
	yield(tween, "finished")
	set_process(false)


func _process(delta): Anim.rotation *= delta
	

# Anim Functions -------------------------------------------------------------------------------- #

enum ANIMS { PIXEL }
onready var Anim = $Anim

func set_anim(val: int = 0):
	val = val % ANIMS.size()
	Anim.animation = str(val)

func play_anim(rev: bool):
	var anim = Anim.animation
	Anim.play(anim, rev)

func swap_anim():
	randomize()
	set_anim(randi())
	Anim.flip_v = bool(randi() % 2)


# Error Handling -------------------------------------------------------------------------------- #

const ERROR = {
	"MISSING": "Error: Unable to load the resource from path.",
	"LOADING": "Error: Issue occured while loading files.",
	"NULLIFY": "Error: Post-processing failed.",
	"TIMEOUT": "Error: Timeout."
}

func _error(msg: String):
	SIGNALS.emit_signal("warning", msg)
	print(msg)
	_reset()


# Scene Change Functions ------------------------------------------------------------------------ #

var THREAD
const SCENE = {
	"MENU": "res://Menu/Scenes/Main.tscn",
	"GAME": "res://Game/Game.tscn"
}

func change_scene(path: String):
	_start()
	THREAD = Thread.new()
	yield(self, "finished_playing")
	THREAD.start(self, "load_scene", path)
	

const MAX_DELAY = 150000
func load_scene(path: String):

	var loader = ResourceLoader.load_interactive(path)

	if loader == null: _error(ERROR["MISSING"])

	else:

		var TIMEOUT = OS.get_ticks_msec() + MAX_DELAY

		while OS.get_ticks_msec() < TIMEOUT:

			var err = loader.poll()

			if err == OK:

				if err != ERR_FILE_EOF: _error(ERROR["LOADING"])

				else: call_deferred("start_scene", loader.get_resource())

				return

			#yield(get_tree(), "idle_frame")

		_error(ERROR["TIMEOUT"])


func start_scene(res: Resource):

	THREAD.wait_to_finish()

	if res == null: _error(ERROR["NULLIFY"])

	else:

		var tree = get_tree()
		var new_scene = res.instance()

		tree.current_scene.free()
		tree.current_scene = null

		tree.root.add_child(new_scene)
		tree.current_scene = new_scene
	
		_reset()

		yield(self, "finished_exiting")

		new_scene._start()
