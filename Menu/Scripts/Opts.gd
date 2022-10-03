extends MarginContainer


func _ready(): pass

func _start(): pass

func _reset(): pass

func _exit(msg: String):
	SIGNALS.emit_signal("exit_opts")
	print(msg)
