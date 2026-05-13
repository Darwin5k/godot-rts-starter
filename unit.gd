extends CharacterBody3D

var selected: bool = false

func set_move_target(pos: Vector3) -> void:
	print("Move target: ", pos)
