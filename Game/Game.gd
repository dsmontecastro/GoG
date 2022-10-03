extends Node2D

var gameScript = load("res://Game/Board/Scripts/Game.gd")

onready var Board = $Board
onready var Tiles = $Board/Tiles
onready var Setup = $Sidebar/Setup


# Basic Functions ------------------------------------------------------------------------------- #

func _ready():
	SIGNALS.connect("drop", self, "drop_unit")
	SIGNALS.connect("setup_reset", self, "_reset")
	SIGNALS.connect("setup_finished", self, "_start")

func _start():
	Board._start()
	Board.set_script(gameScript)
	Board._ready()

func _reset(): Board._reset()


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

		fromArea.ARRAY[from.y][from.x] = 0
		currArea.ARRAY[move.y][move.x] = unit.TYPE
		unit.drop_unit(move)

	else: unit.position = fromPos
