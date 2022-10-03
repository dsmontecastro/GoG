extends Node

func quit():
	LOBBY.leave()
	get_tree().quit()



func matrix(rows: int, cols: int, filler = null) -> Array:

	var matrix = []
	for _i in range(rows):
		var row = []
		row.resize(cols)
		if filler != null:
			row.fill(filler)
		matrix.append(row)

	return matrix
