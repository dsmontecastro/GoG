extends Node2D

var gameScript = load("res://Game/Board/Scripts/BoardGame.gd")

onready var Board = $Board
onready var Tiles = $Board/Tiles
onready var Setup = $Sidebar/Setup

var specs = Vector2.ZERO
var grid = []


func moveUnit(from: Vector2, move: Vector2):

	if move == Vector2.ZERO: return

	print(from, " to ", move)


# Setup Functions

func _on_Setup_reset(): Board.reset()


func _on_Setup_finished():


	grid = Board.grid
	specs = Board.specs

	Board.setupFinished()
	Board.set_script(gameScript)
	Board._ready()


func dropUnit(unit: Area2D, move: Vector2):
	
	var fromTile = unit.get_parent()
	var fromArea = fromTile.get_parent()
	var fromPos = fromTile.to_local(unit.origin)

	var currArea = unit.currArea
	var currTile = currArea.get_node("Tiles")
	var currPos = currTile.to_local(move)

	var from = fromTile.world_to_map(fromPos)
	move = currTile.world_to_map(currPos)
	move.x = clamp(move.x, 0, currArea.specs.x)
	move.y = clamp(move.y, 0, currArea.specs.y)

	if not currArea.isEmpty(move.y, move.x):
		unit.position = fromPos
		return

	if currArea != fromArea:
		fromTile.remove_child(unit)
		currTile.add_child(unit)

	fromArea.grid[from.y][from.x] = 0
	currArea.grid[move.y][move.x] = unit.type
	unit.positionByIndex(move)
