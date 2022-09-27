extends Popup

onready var Message = $"%Message"
const DEF_MSG = "Unknown error occured."


func _start(msg: String = DEF_MSG):
	Message.text = msg
	self.show()

func _reset():
	Message.text = ""
	self.hide()
