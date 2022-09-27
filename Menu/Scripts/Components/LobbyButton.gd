extends MarginContainer

var id = -1
const LIM = 15
const TAG = LOBBY.TAG

onready var Host = $Host
onready var Name = $Name

func _ready():
	set_host(Host.text)
	set_name(Name.text)

func set_id(val: int): id = val

func set_host(val: String): Host.text = limit(val) + "    "

func set_name(val: String):
	if val: val = val.replace(TAG, "")
	Name.text = "  " + limit(val)


func limit(val: String) -> String:
	if len(val) > LIM:
		val = val.substr(0, LIM-3) + "..."
	return val


func _on_Lobby_pressed(): LOBBY.join_lobby(id)
