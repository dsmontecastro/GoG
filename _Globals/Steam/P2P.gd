extends Node

const LIMIT = 32

func _ready():
	Steam.connect("p2p_session_request", self, "request")
	Steam.connect("p2p_session_connect_fail", self, "failure")


# Initializaiton -------------------------------------------------------------------------------- #

func handshake():
	print("Sending P2P handshake to the lobby")
	send(0, {"message": "handshake", "from": USER.ID})


func request(userID: int):

	# Get the requester's name
	#var REQUESTER: String = Steam.getFriendPersonaName(userID)

	# Accept the P2P session; can apply logic to deny this request if needed
	Steam.acceptP2PSessionWithUser(userID)

	# Make the initial handshake
	handshake()

signal warning(message)
func failure(id: int, err: int):

	var message = "WARNING: Session failure with %d [_]." % str(id)

	match err:
		0: message.replace("_", "no error given")
		1: message.replace("_", "target user not running the same game")
		2: message.replace("_", "local user doesn't own app / game")
		3: message.replace("_", "target user isn't connected to Steam")
		4: message.replace("_", "connection timed out")
		5: message.replace("_", "unused")
		_: message.replace("_", "unknown error (Code: %d)" % err)

	emit_signal("warning", message)


# Sending $ Receiving --------------------------------------------------------------------------- #

const PORT = 0
const TYPE = Steam.P2P_SEND_RELIABLE
const empty = "Error: Empty packet!"


func send(target: int, packet_data: Dictionary):

	#var DATA: PoolByteArray
	#DATA.append_array(var2bytes(packet_data))
	var DATA: PoolByteArray = var2bytes(packet_data)

	if target == 0:
		for ID in LOBBY.MEMBERS:
			if ID != USER.ID:
				Steam.sendP2PPacket(ID, DATA, TYPE, PORT)

	else: Steam.sendP2PPacket(target, DATA, TYPE, PORT)


func read():

	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(0)

	if PACKET_SIZE > 0:

		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, 0)

		if PACKET.empty() or PACKET == null: emit_signal("warning", empty)

		elif PACKET['steam_id_remote'] in LOBBY.MEMBERS:

			var DATA: Dictionary = bytes2var(PACKET['data'])
			print("Packet: " + str(DATA))
