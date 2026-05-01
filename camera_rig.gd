extends Node3D

@export var pan_speed: float = 15.0
@export var rotate_speed: float = 90.0
@export var smooth_speed: float = 8.0

@export var zoom_min: float = 3.0
@export var zoom_max: float = 40.0

@export var character_view_zoom: float = 8.0
@export var town_view_zoom: float = 30.0
@export var character_view_pitch: float = -45.0
@export var town_view_pitch: float = -70.0

var target_position: Vector3 = Vector3.ZERO
var target_zoom: float = 8.0
var target_y_rotation: float = 0.0
var in_town_view: bool = false

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	target_position = global_position
	target_zoom = character_view_zoom
	_apply_camera_transform(1.0)

func _process(delta: float) -> void:
	_handle_pan(delta)
	_handle_rotation(delta)
	_smooth_camera(delta)

func _handle_pan(delta: float) -> void:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input.y += 1
	if Input.is_key_pressed(KEY_S): input.y -= 1
	if Input.is_key_pressed(KEY_A): input.x -= 1
	if Input.is_key_pressed(KEY_D): input.x += 1

	if input == Vector2.ZERO:
		return

	var rig_basis := Basis(Vector3.UP, deg_to_rad(target_y_rotation))
	var forward := -rig_basis.z
	var right := rig_basis.x
	target_position += (right * input.x + forward * input.y) * pan_speed * delta

func _handle_rotation(delta: float) -> void:
	if Input.is_key_pressed(KEY_Q): target_y_rotation += rotate_speed * delta
	if Input.is_key_pressed(KEY_E): target_y_rotation -= rotate_speed * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom - 1.5, zoom_min, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom + 1.5, zoom_min, zoom_max)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_V:
			_toggle_view_mode()

func _toggle_view_mode() -> void:
	in_town_view = !in_town_view
	target_zoom = town_view_zoom if in_town_view else character_view_zoom

func _smooth_camera(delta: float) -> void:
	global_position = global_position.lerp(target_position, smooth_speed * delta)
	rotation_degrees.y = lerp(rotation_degrees.y, target_y_rotation, smooth_speed * delta)
	_apply_camera_transform(smooth_speed * delta)

func _apply_camera_transform(t: float) -> void:
	var target_pitch := town_view_pitch if in_town_view else character_view_pitch
	var target_cam_y := sin(deg_to_rad(abs(target_pitch))) * target_zoom
	var target_cam_z := cos(deg_to_rad(abs(target_pitch))) * target_zoom
	camera.position.y = lerp(camera.position.y, target_cam_y, t)
	camera.position.z = lerp(camera.position.z, target_cam_z, t)
	camera.rotation_degrees.x = lerp(camera.rotation_degrees.x, target_pitch, t)
