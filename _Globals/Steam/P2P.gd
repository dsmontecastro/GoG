extends Node


# Basic Functions ------------------------------------------------------------------------------- #

var ENEMY = 0

func _ready():
	Steam.connect("p2p_session_connect_fail", self, "on_failure")
	Steam.connect("p2p_session_request", self, "on_request")

func _start():
	ENEMY = 0
	for ID in LOBBY.MEMBERS:
		if ID != USER.ID: ENEMY = ID

func _reset(): ENEMY = 0

func _process(_d): Steam.run_callbacks()


# Initializaiton -------------------------------------------------------------------------------- #

func handshake():
	for ID in LOBBY.MEMBERS:
		if ID != USER.ID: send(P2P.MSSG.HANDSHAKE)

func on_request(userID: int):
	Steam.acceptP2PSessionWithUser(userID)
	handshake()


func on_failure(id: int, err: int):

	var message = "WARNING: Session failure with ID: %d [_]." % id

	match err:
		0: message.replace("_", "No error given")
		1: message.replace("_", "Target User not running the same game")
		2: message.replace("_", "Local User doesn't own app / game")
		3: message.replace("_", "Target User isn't connected to Steam")
		4: message.replace("_", "Connection timed out")
		5: message.replace("_", "Unused")
		_: message.replace("_", "Unknown error (Code: %d)" % err)

	SIGNALS.emit_signal("warning", message)


# Sending & Receiving --------------------------------------------------------------------------- #

const PORT = 0
const TYPE = Steam.P2P_SEND_RELIABLE
const NULL = "Error: Empty packet!"


func send(msg: int, val = true):
	var DATA = { "msg": msg, "val": val }
	Steam.sendP2PPacket(ENEMY, var2bytes(DATA), TYPE, PORT)
	print("Sent: ", DATA)


enum MSSG { HANDSHAKE, PLAY_GAME, GAME_OVER, MOVE_UNIT, KILL_UNIT }

func read() -> Dictionary:

	var DATA = {}
	var SIZE = Steam.getAvailableP2PPacketSize(PORT)

	if SIZE > 0:

		var PACKET: Dictionary = Steam.readP2PPacket(SIZE, 0)

		if PACKET.empty() or PACKET == null:
			SIGNALS.emit_signal("warning", NULL)

		elif PACKET['steam_id_remote'] in LOBBY.MEMBERS:
			DATA = bytes2var(PACKET['data'])

	return DATA
