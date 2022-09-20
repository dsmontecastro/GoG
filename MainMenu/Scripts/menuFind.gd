extends MarginContainer

export (int) var secs = 0
export (int) var mins = 0

onready var Min = $Find/Timer/Min
onready var Sec = $Find/Timer/Sec


func _ready():
	set_process(false)
	

var time = 0.0
func _process(delta):
	time += delta
	if time > 1.0:
		time = 0
		secs += 1
		if secs == 60:
			mins += 1
			secs = 0
		setText()



func reset() -> void:
	secs = 0
	mins = 0
	setText()
	set_process(true)
	
func setText() -> void:
	Min.text = ("%02d" % mins)
	Sec.text = ("%02d" % secs)



func _on_menuFind_visibility_changed():
	if self.visible: reset()
	else: set_process(false)

func _on_Cancel_pressed():
	self.visible = false
