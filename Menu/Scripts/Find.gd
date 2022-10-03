extends Popup

onready var Counter = $"%Counter"
onready var Cancel = $"%Cancel"


# Default Parameters
var DIST = LOBBY.DIST.CLOSE
const MODE = LOBBY.MODE.AUTO
const TYPE = LOBBY.TYPE.INVISIBLE


# Basic Functions ------------------------------------------------------------------------------ #

func _ready(): set_process(false)

func _start():
	Cancel.grab_focus()
	DIST = LOBBY.DIST.CLOSE
	LOBBY.connect("lobby_update", self, "match_hosted")
	LOBBY.connect("join_success", self, "match_joined")
	LOBBY.connect("get_lobbies", self, "matchmaking")
	set_counter(0, 0)
	set_process(true)
	find_match()
	self.show()
	
func _reset():
	LOBBY.disconnect("lobby_update", self, "match_hosted")
	LOBBY.disconnect("join_success", self, "match_joined")
	LOBBY.disconnect("get_lobbies", self, "matchmaking")
	set_process(false)
	self.hide()


# Signaling Functions --------------------------------------------------------------------------- #

func _play(msg: String): SIGNALS.emit_signal("play", msg)

func _error(msg: String):
	SIGNALS.emit_signal("warning", msg)
	_reset()


# Timer Functions ------------------------------------------------------------------------------- #

var time = 0.0
const TIMEOUT = "Failed to automatically match you with a lobby. Please try again."

func set_counter(mins: int = 0, secs: int = 0):
	Counter.text = "%02d : %02d" % [mins, secs]

func _process(delta):

	if DIST < 4:

		time += delta
		var secs = int(time) % 60
		var mins = int(time / 60) % 60

		set_counter(mins, secs)

		if mins > 0 and !(secs % 30):
			DIST += 1
			if isHosting: find_match()

	else: _error(TIMEOUT)


# Matchmaking Functions ------------------------------------------------------------------------- #

var isHosting = false

func find_match():
	LOBBY.leave()
	LOBBY.request_lobbies(MODE, DIST)
	isHosting = false

func host_match(): 
	LOBBY.leave()
	LOBBY.host_lobby(MODE, TYPE)
	isHosting = true


func match_hosted(status: int, msg: String):
	if status == 1: _play(msg)
	else: _error(msg)

func match_joined(success: bool, msg: String):
	if success: _play(msg)
	else: _error(msg)

#func match_found(status, msg: String): # Not working
#	# Idea: Catch true and code: 1
#	if int(status) == 1: _play(msg)
#	else: _error(msg)


func matchmaking(lobbies: Array):

	if lobbies.size() > 0:

		for id in lobbies:
			LOBBY._debug(id)
			if id != LOBBY.ID:
				LOBBY.join_lobby(lobbies[0])
				return

	else: host_match()
