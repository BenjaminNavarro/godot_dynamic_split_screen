extends Spatial

onready var player1: KinematicBody = $'../Player1'
onready var player2: KinematicBody = $'../Player2'
onready var camera1: Camera = $'Viewport1/Camera1'
onready var camera2: Camera = $'Viewport2/Camera2'
onready var view: TextureRect = $'View'

export var MAX_SEPARATION := 20
export var SPLIT_BORDER_RADIUS := 3.0;
export var SPLIT_BORDER_COLOR := Color(0.0, 0.0, 0.0, 1.0)
export var ADAPTIVE_BORDER_THICKNESS := true
var split_state := false
var split_origin: Vector2

func _ready():
	_handle_resize()
	_update_splitscreen()
	
	get_viewport().connect("size_changed", self, "_handle_resize")
	
	view.material.set_shader_param('viewport1', $Viewport1.get_texture())
	view.material.set_shader_param('viewport2', $Viewport2.get_texture())
	view.material.set_shader_param('border_width', SPLIT_BORDER_RADIUS)
	view.material.set_shader_param('border_color', SPLIT_BORDER_COLOR)
	
# warning-ignore:unused_argument
func _process(delta):
	_update_split_state()
	_move_cameras()
	_update_splitscreen()
	
func _update_split_state():
	var dx := _compute_dx_world()
	split_state = Vector2(dx.x, dx.z).length() > MAX_SEPARATION

func _handle_resize():
	var screen_size := get_viewport().get_visible_rect().size
	$Viewport1.size = screen_size
	$Viewport2.size = screen_size
	view.rect_size = screen_size
	
	view.material.set_shader_param('viewport_size', screen_size)
	
func _move_cameras():
	var dx: Vector3 = player2.translation - player1.translation
	
	var distance := clamp(Vector2(dx.x, dx.z).length(), 0, MAX_SEPARATION)

	dx = dx.normalized() * distance

	camera1.translation.x = player1.translation.x + dx.x / 2.0
	camera1.translation.z = player1.translation.z + dx.z / 2.0

	camera2.translation.x = player2.translation.x - dx.x / 2.0
	camera2.translation.z = player2.translation.z - dx.z / 2.0
	
func _update_splitscreen():
	var screen_size := get_viewport().get_visible_rect().size
	
	split_origin = Vector2(0.5, 0.5)
	
	var player1_position := camera1.unproject_position(player1.translation)
	player1_position.x /= screen_size.x;
	player1_position.y /= screen_size.y;

	var player2_position := camera2.unproject_position(player2.translation)
	player2_position.x /= screen_size.x;
	player2_position.y /= screen_size.y;
	
	if ADAPTIVE_BORDER_THICKNESS:
		var dx := _compute_dx_world()
		var distance := Vector2(dx.x, dx.z).length()
		var split_line_thickness = lerp(0, SPLIT_BORDER_RADIUS, (distance - MAX_SEPARATION) / MAX_SEPARATION)
		split_line_thickness = clamp(split_line_thickness, 0, SPLIT_BORDER_RADIUS)
		view.material.set_shader_param('border_width', split_line_thickness)
	
	view.material.set_shader_param('split_active', split_state)
	view.material.set_shader_param('split_origin', split_origin)
	view.material.set_shader_param('player1', player1_position)
	view.material.set_shader_param('player2', player2_position)
	
func _compute_dx_world() -> Vector3:
	return player2.translation - player1.translation
	
func _compute_dx_screen() -> Vector2:
	camera1.unproject_position(player2.translation)
	return camera1.unproject_position(player2.translation) - camera1.unproject_position(player1.translation)