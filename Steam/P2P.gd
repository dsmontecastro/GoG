extends Node

func _ready():
	Steam.connect("p2p_session_request", self, "request")
	Steam.connect("p2p_session_connect_fail", self, "connection_failed")

func handshake():
	print("Sending P2P handshake to the lobby")
	send(0, {"message": "handshake", "from": USER.ID})


func request(from_id: int):

	# Get the requester's name
	#var REQUESTER: String = Steam.getFriendPersonaName(from_id)

	# Accept the P2P session; can apply logic to deny this request if needed
	Steam.acceptP2PSessionWithUser(from_id)

	# Make the initial handshake
	handshake()


func connection_failed(id: int, err: int):

	var message = "WARNING: Session failure with %d [_]." % str(id)

	match err:
		0: message.replace("_", "no error given")
		1: message.replace("_", "target user not running the same game")
		2: message.replace("_", "local user doesn't own app / game")
		3: message.replace("_", "target user isn't connected to Steam")
		4: message.replace("_", "connection timed out")
		5: message.replace("_", "unused")
		_: message.replace("_", "unknown error (Code: %d)" % err)

	print(message)



func read():

	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(0)

	# There is a packet
	if PACKET_SIZE > 0:

		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, 0)

		if PACKET.empty() or PACKET == null:
			print("WARNING: read an empty packet with non-zero size!")

		# Get the remote user's ID
		#var PACKET_SENDER: int = PACKET['steam_id_remote']

		# Make the packet data readable
		var PACKET_CODE: PoolByteArray = PACKET['data']
		var READABLE: Dictionary = bytes2var(PACKET_CODE)

		# Print the packet to output
		print("Packet: "+str(READABLE))

		# Append logic here to deal with packet data

func send(target: int, packet_data: Dictionary):

	# Set the send_type and channel
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	var CHANNEL: int = 0

	# Create a data array to send the data through
	var DATA: PoolByteArray
	DATA.append_array(var2bytes(packet_data))

	# If sending a packet to everyone
	if target == 0:
		# If there is more than one user, send packets
		if LOBBY.MEMBERS.size() > 1:
			# Loop through all members that aren't you
			for MEMBER in LOBBY.MEMBERS:
				if MEMBER['steam_id'] != USER.ID:
					Steam.sendP2PPacket(MEMBER['steam_id'], DATA, SEND_TYPE, CHANNEL)
	# Else send it to someone specific
	else:
		Steam.sendP2PPacket(target, DATA, SEND_TYPE, CHANNEL)
