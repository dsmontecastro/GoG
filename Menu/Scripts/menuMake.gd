extends MarginContainer

const Game = "res://Game/Game.tscn"
const MODE = LOBBY.MODE.MANUAL
const DIST = LOBBY.DIST.GLOBAL

onready var Lobbies = $Panel/HBox/VBox/Joining/Panel/Scroll/Lobbies
var LobbyButton = preload("res://Menu/Scenes/Components/LobbyButton.tscn")

onready var HostType = $"%HostType"
onready var HostName = $"%HostName"
onready var FindName = $"%FindName"


# Basic Funtions -------------------------------------------------------------------------------- #

func _ready(): HostType.select(LOBBY.TYPE.PUBLIC)

func _start():
	LOBBY.connect("host_success", self, "room_hosted")
	LOBBY.connect("join_success", self, "room_joined")
	LOBBY.connect("get_lobbies", self, "list_rooms")
	find_rooms()

func _reset():
	LOBBY.disconnect("host_success", self, "room_hosted")
	LOBBY.disconnect("join_success", self, "room_joined")
	LOBBY.disconnect("get_lobbies", self, "list_rooms")


# Custom Functions ------------------------------------------------------------------------------ #

func start_game(msg: String = ""):
	print(msg)
	print(LOBBY._debug(LOBBY.ID))

func host_room():
	if HostName.text:
		var lobbyName = HostName.text
		var lobbyType = HostType.get_selected_id()
		LOBBY.host_lobby(MODE, lobbyType, lobbyName)

func find_rooms():
	var NAME = FindName.text.strip_edges()
	LOBBY.request_lobbies(MODE, DIST, NAME)


# Signals & Connections ------------------------------------------------------------------------- #

signal warning(message)

func room_hosted(success: bool, msg: String):
	if success: start_game(msg)
	else: emit_signal("warning", msg)


func room_joined(success: bool, msg: String):
	if success: start_game()
	else: emit_signal("warning", msg)


func list_rooms(lobbies: Array):

	for child in Lobbies.get_children(): child.queue_free()

	for id in lobbies:

		var button = LobbyButton.instance()
		Lobbies.add_child(button)

		button.set_name(Steam.getLobbyData(id, "name"))
		button.set_host(Steam.getLobbyData(id, "host"))
		button.set_id(id)
