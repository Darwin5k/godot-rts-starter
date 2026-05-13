extends Node3D

var selected_unit: CharacterBody3D = null

@onready var camera: Camera3D = $CameraRig/Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb := event as InputEventMouseButton
	if not mb.pressed:
		return

	var origin: Vector3 = camera.project_ray_origin(mb.position)
	var dir: Vector3 = camera.project_ray_normal(mb.position)
	var params := PhysicsRayQueryParameters3D.create(origin, origin + dir * 1000.0)
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	if hit.is_empty():
		return

	match mb.button_index:
		MOUSE_BUTTON_LEFT:  _handle_left_click(hit)
		MOUSE_BUTTON_RIGHT: _handle_right_click(hit)

func _handle_left_click(hit: Dictionary) -> void:
	var body := hit["collider"] as Node3D
	if body is CharacterBody3D:
		if selected_unit and selected_unit != body:
			selected_unit.selected = false
		selected_unit = body as CharacterBody3D
		selected_unit.selected = true
	else:
		if selected_unit:
			selected_unit.selected = false
		selected_unit = null

func _handle_right_click(hit: Dictionary) -> void:
	if selected_unit == null:
		return
	selected_unit.set_move_target(hit["position"] as Vector3)
