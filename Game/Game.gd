extends Node2D

onready var Board = $Board
onready var Tiles = $Board/Tiles
onready var Setup = $Sidebar/Setup


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	SIGNALS.connect("drop", self, "drop_unit")
	SIGNALS.connect("game_play", self, "game_play")
	SIGNALS.connect("game_over", self, "game_over")
	SIGNALS.connect("setup_reset", self, "setup_reset")
	SIGNALS.connect("setup_ready", self, "setup_ready")
	LOBBY.connect("lobby_update", self, "lobby_change")


# In-game Functions ----------------------------------------------------------------------------- #

func game_play():
	USER.IN_GAME = true
	Setup.game_play()
	Board.game_play()
	Board._play()

func game_over(win: bool):

	if win: pass
	else: pass

func lobby_change(state: int, _msg: String):

	# Player Left/Kicked/Banned
	if state > 1:

		USER.IN_GAME = false
		SIGNALS.emit_signal("setup_reset")


# Setup Functions ------------------------------------------------------------------------------- #

func setup_reset():
	USER.READIED = false
	Setup.setup_reset()
	Board.setup_reset()

func setup_ready(val: bool):

	P2P._start()
	USER.READIED = val
	Setup.setup_ready(val)
	Board.setup_ready(val)

	if val and LOBBY.all_ready():
		P2P.send(P2P.MSSG.PLAY_GAME)
		SIGNALS.emit_signal("game_play")


# P2P Parsing  ---------------------------------------------------------------------------------- #

func _process(_d):
	var data = P2P.read()
	if not data.empty(): _parse(data)

func _parse(data: Dictionary):

	print("Received: ", data)

	var msg = data["msg"]
	var val = data["val"]

	match msg:
		P2P.MSSG.PLAY_GAME:
			P2P._start()
			game_play()
		P2P.MSSG.GAME_OVER: game_over(val)
		P2P.MSSG.KILL_UNIT: Board.kill(val)
		P2P.MSSG.MOVE_UNIT: Board.move(val[0], val[1])


# Drag-&-Drop ----------------------------------------------------------------------------------- #

func drop_unit(unit: Area2D, move: Vector2):
	
	var fromTile = unit.get_parent()
	var fromArea = fromTile.get_parent()
	var fromPos = fromTile.to_local(unit.ORIGIN)

	var currArea = unit.currArea
	var currTile = currArea.Tiles
	var currPos = currTile.to_local(move)

	var from = fromTile.world_to_map(fromPos)
	move = currTile.world_to_map(currPos)
	move.x = clamp(move.x, 0, currArea.SPECS.y - 1)
	move.y = clamp(move.y, 0, currArea.SPECS.x - 1)

	if currArea.is_empty(move.x, move.y):

		if currArea != fromArea:
			fromTile.remove_child(unit)
			currTile.add_child(unit)

		fromArea.ARRAY[from.y][from.x] = null
		currArea.ARRAY[move.y][move.x] = unit
		unit.drop_unit(move)

	else: unit._reset()
