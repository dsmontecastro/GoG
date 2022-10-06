extends Node

# Lobby Types
enum TYPE { PRIVATE, FRIENDS, PUBLIC, INVISIBLE }	# for reference
enum DIST { CLOSE, DEFAULT, FAR, GLOBAL }
enum MODE { AUTO, MANUAL }

# Constants
const MAX_MEMBERS = 2
const TAG = "[GoG] "

# Trackers
var ID = 0
var NAME = ""
var FIND = MODE.AUTO
var MEMBERS = {}


# Startup --------------------------------------------------------------------------------------- #

func _ready():

	# Host / Join Signals
	Steam.connect("join_requested", self, "join_by_invite")
	Steam.connect("lobby_created", self, "host_status")
	Steam.connect("lobby_joined", self, "join_status")

	# Lobby / Update Signals
	Steam.connect("lobby_match_list", self, "get_lobbies")
	Steam.connect("persona_state_change", self, "user_update")
	Steam.connect("lobby_chat_update", self, "lobby_chat_update")
	Steam.connect("lobby_data_update", self, "lobby_data_update")

	
	var ARGS: Array = OS.get_cmdline_args()

	if ARGS.size() > 0: 					# There are arguments to process
		if ARGS[0] == "+connect_lobby": 	# A Steam connection argument exists
			if int(ARGS[1]) > 0: 			# Lobby invite exists so try to connect to it

				print("CMD Line Lobby ID: " + str(ARGS[1]))
				join_lobby(int(ARGS[1]))


func _debug(id: int = ID):

		if id <= 0: return "Error: Invalid lobby."

		else:

			var info = [id]
			info.append(Steam.getNumLobbyMembers(id))
			info.append(Steam.getLobbyMemberLimit(id))
			info.append(Steam.getLobbyData(id, "mode"))
			info.append(Steam.getLobbyData(id, "name"))
			info.append(Steam.getLobbyData(id, "host"))

			return "%d (%d/%d) [%s]: %s by %s" % info


# Reset Functions ------------------------------------------------------------------------------- #

func _reset():
	USER._reset()
	MEMBERS.clear()
	FIND = MODE.AUTO
	NAME = ""
	ID = 0

func _leave(lobbyID: int = ID):

	if lobbyID > 0:

		Steam.leaveLobby(lobbyID)
		for id in MEMBERS:
			if id != USER.ID:
				Steam.closeP2PSessionWithUser(id)

		P2P._reset()
		_reset()


# Update Functions ------------------------------------------------------------------------------ #

signal data_update(success, message)
func lobby_data_update(success: int, lobbyID: int, userID: int):

	if lobbyID != userID:

		var message = "Change to %s " % userID

		if success: message += "successful!"
		else: message += "failed..."

		update_members()
		emit_signal("data_update", success, message)

		print(message)
		var form = Steam.getLobbyMemberData(lobbyID, userID, "form")
		print("> %d: %s" % [userID, form])


signal lobby_update(state, message)
func lobby_chat_update(_lobbyID: int, changedID: int, _changerID: int, state: int):

	var changedName = Steam.getFriendPersonaName(changedID)

	var message = "%s has _ the lobby." % changedName

	match state:
		01: message.replace("_", "joined")
		02: message.replace("_", "left")
		08: message.replace("_", "been kicked from")
		16: message.replace("_", "been banned from")
		_:  message = "%s has done... something." % changedName

	update_members()
	emit_signal("lobby_update", state, message)


func user_update(_userID: int, _flag: int): update_members()


func update_members():

	MEMBERS.clear()
	var count = Steam.getNumLobbyMembers(ID)

	for index in range(0, count):
		var userID = Steam.getLobbyMemberByIndex(ID, index)
		var userName = Steam.getFriendPersonaName(userID)
		var userForm = Steam.getLobbyMemberData(ID, userID, "form")
		MEMBERS[userID] = { "name": userName, "form": str(userForm) }

	for id in MEMBERS: print("%d: %s" % [id, MEMBERS[id]])


# Matchmaking Functions ------------------------------------------------------------------------- #

func request_lobbies(lobbyMode: int, lobbyDist: int = DIST.GLOBAL, lobbyName: String = ""):
	Steam.addRequestLobbyListStringFilter("name", TAG + lobbyName, 2)
	Steam.addRequestLobbyListStringFilter("mode", str(lobbyMode), 0)
	Steam.addRequestLobbyListDistanceFilter(lobbyDist)
	Steam.addRequestLobbyListFilterSlotsAvailable(1)
	Steam.requestLobbyList()

signal get_lobbies(lobbies)
func get_lobbies(lobbies: Array): emit_signal("get_lobbies", lobbies)


# Hosting Functions ----------------------------------------------------------------------------- #

func host_lobby(lobbyMode: int, lobbyType: int, lobbyName: String = ""):
	FIND = lobbyMode
	NAME = lobbyName
	Steam.createLobby(lobbyType, MAX_MEMBERS)

signal host_success(val, message)
func host_status(connect: int, id: int):

	var success = true
	var message = "Lobby created successfully!"

	if connect == 1:

		ID = id
		USER.HOSTING = true
		if !NAME: NAME = str(id)

		Steam.setLobbyData(id, "host", USER.NAME)
		Steam.setLobbyData(id, "name", TAG + NAME)
		Steam.setLobbyData(id, "mode", str(FIND))
		Steam.setLobbyJoinable(id, true)

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var isRelaying = str(Steam.allowP2PPacketRelay(true))
		print("\nAllowing Steam to be relay backup: %s" % isRelaying)

	else:
		_reset()
		success = false
		match connect:
			02: message = "The server responded, but with an unknown internal error."
			03: message = "Your Steam client doesn't have a connection to the back-end."
			15: message = "Your Steam client doesn't have access to the game or the lobby."
			16: message = "The message was sent to the Steam servers, but it didn't respond."
			25: message = "You have created too many lobbies and are being rate limited."

	emit_signal("host_success", success, message)


# Joining Functions ----------------------------------------------------------------------------- #

func join_lobby(lobbyID: int): Steam.joinLobby(lobbyID)

func join_by_invite(lobbyID: int, friendID: int):
	var owner_name = Steam.getFriendPersonaName(friendID)
	print("Joining %s's lobby..." % owner_name)
	join_lobby(lobbyID)

signal join_success(val, message)
func join_status(lobbyID: int, _permissions: int, _locked: bool, response: int):

	var success = true
	var is_own_lobby = true
	var message = "Lobby joined successfully!"

	# If joining was successful
	if response == 1:

		if lobbyID != ID:
			is_own_lobby = false
			_leave(ID)

		ID = lobbyID
		FIND = Steam.getLobbyData(lobbyID, "mode")
		NAME = Steam.getLobbyData(lobbyID, "name")
		Steam.setLobbyMemberData(ID, "form", "")
		update_members()
		P2P.handshake()

	# Else it failed for some reason
	else:
		success = false
		match response:
			02: message = "This lobby no longer exists."
			03: message = "You don't have permission to join this lobby."
			04: message = "The lobby is now full."
			05: message = "Uh... something unexpected happened!"
			06: message = "You are banned from this lobby."
			07: message = "You cannot join due to having a limited account."
			08: message = "This lobby is locked or disabled."
			09: message = "This lobby is community locked."
			10: message = "A user in the lobby has blocked you from joining."
			11: message = "A user you have blocked is in the lobby."

	if not is_own_lobby: emit_signal("join_success", success, message)


# Gameplay Functions ---------------------------------------------------------------------------- #

func all_ready():

	if Steam.getNumLobbyMembers(ID) < MAX_MEMBERS: return false

	for user in MEMBERS:
		var form = Steam.getLobbyMemberData(ID, user, "form")
		print("%d: %s" % [user, form])
		if not form: return false
	return true
	
