extends AnimatedSprite

const TOTAL = 1
const DELAY = 0.5

onready var Anims = $Anims
onready var Delay = $Delay

func _ready():

	for i in range(TOTAL):
		Anims.play(str(i))
		yield(Anims, "animation_finished")
		Delay.start(DELAY)
		yield(Delay, "timeout")

	LOADER.change_scene(LOADER.SCENE.MENU)
