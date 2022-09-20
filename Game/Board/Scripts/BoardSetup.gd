extends "res://Game/Setup.gd"

var ownScript = load("res://Game/Units/Scripts/Own.gd")
var foeScript = load("res://Game/Units/Scripts/Foe.gd")



# Built-in Functions
func _ready() -> void:
	
	specs = Vector2(8, 9)
	toggleLanding(true)

	for r in range(specs.x):
		grid.append([])
		for _c in range(specs.y):
			grid[r].append(0)

	if !isHost:
		var offset = tileSize.y * 5
		$Landing.move_local_y(offset)


# Ready Functions
func setupFinished():

	toggleLanding(false)

	for unit in tiles.get_children():

		unit.setupFinished()

		var type = unit.type
		if type > 0:
			unit.set_script(ownScript)
			unit.set_type(type)
			unit._ready()

func toggleLanding(val: bool) -> void:
	$Landing.visible = val
	$Landing.disabled = !val
	tiles.collision_use_parent = !val



# Reset Functions
func reset():
	resetGrid()
	resetMap()

func resetGrid() -> void:
	for r in range(specs.x):
		for c in range(specs.y):
			grid[r][c] = null
