extends Popup

onready var Counter = $"%Counter"

var DIST = LOBBY.DIST.CLOSE
const MODE = LOBBY.MODE.AUTO
const TYPE = LOBBY.TYPE.INVISIBLE
enum STATE { JOINED, LEFT, KICKED, BANNED }

signal warning(message)
const timeout = "Failed to automatically match you with a lobby. Please try again."


# Basic Parameters & Functions ------------------------------------------------------------------ #

func _ready(): set_process(false)

func _start():
	print("FIND.START")
	DIST = LOBBY.DIST.CLOSE
	LOBBY.connect("lobby_update", self, "match_found")
	LOBBY.connect("join_success", self, "match_found")
	LOBBY.connect("get_lobbies", self, "match_list")
	set_counter(0, 0)
	set_process(true)
	find_match()
	self.show()
	
func _reset():
	print("FIND.RESET")
	LOBBY.disconnect("lobby_update", self, "match_found")
	LOBBY.disconnect("join_success", self, "match_found")
	LOBBY.disconnect("get_lobbies", self, "match_list")
	set_process(false)
	self.hide()

func _error(msg: String):
	emit_signal("warning", msg)
	_reset()


# Timer Functions ------------------------------------------------------------------------------- #

func set_counter(mins: int = 0, secs: int = 0): Counter.text = "%02d : %02d" % [mins, secs]

var time = 0.0
func _process(delta):

	if DIST < 4:

		time += delta
		var secs = int(time) % 60
		var mins = int(time / 60) % 60

		set_counter(mins, secs)

		if mins > 0 and !(secs % 30): DIST += 1

	else: _error(timeout)


# Matchmaking Functions ------------------------------------------------------------------------- #

func start_game(msg: String = ""):
	print(msg)
	print(LOBBY._debug(LOBBY.ID))


func find_match():
	print("FIND.MATCH")
	LOBBY.host_lobby(MODE, TYPE)
	LOBBY.request_lobbies(MODE, DIST)


func match_found(status, msg: String):
	status = int(status)
	if status == 1: start_game(msg)
	else: _error(msg)


func match_list(lobbies: Array):

	print("Results: (%d)" % len(lobbies))

	if lobbies.size() > 0:

		for id in lobbies:
			LOBBY._debug(id)
			if id != LOBBY.ID:
				LOBBY.join_lobby(lobbies[0])
				return

	else: print("-blank-")
