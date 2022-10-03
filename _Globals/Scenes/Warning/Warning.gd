extends Popup

onready var Message = $"%Message"
const DEF_MSG = "Unknown error occured."

func _ready(): SIGNALS.connect("warning", self, "_start")


func _start(msg: String = DEF_MSG):
	print("[WARNING] %s" % msg)
	Message.text = msg
	self.show()
	raise()

func _reset():
	Message.text = ""
	self.hide()
