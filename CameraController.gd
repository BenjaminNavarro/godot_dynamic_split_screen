extends Spatial
class_name CameraController
"""
Handle the motion of both players' camera as well as communication with the
SplitScreen shader to achieve the dynamic split screen effet

Cameras are place on the segment joining the two players, either in the middle 
if players are close enough or at a fixed distance if they are not.
In the first case, both cameras being at the same location, only the view of 
the first one is used for the entire screen thus allowing the players to play 
on a unsplit screen.
In the second case, the screen is split in two with a line perpendicular to the
segement joining the two players.

The points of customization are:
	max_separation: the distance between players at which the view starts to split
	split_line_thickness: the thickness of the split line in pixels
	split_line_color: color of the split line
	adaptive_split_line_thickness: if true, the split line thickness will vary 
		depending on the distance between players. If false, the thickness will
		be constant and equal to split_line_thickness
	split_origin: where the split line passes trough. By default it is the 
		middle of the screen (0.5, 0.5) 
"""

export var max_separation := 20
export var split_line_thickness := 3.0;
export var split_line_color := Color(0.0, 0.0, 0.0, 1.0)
export var adaptive_split_line_thickness := true
export var split_origin := Vector2(0.5, 0.5)

onready var player1: KinematicBody = $'../Player1'
onready var player2: KinematicBody = $'../Player2'
onready var camera1: Camera = $'Viewport1/Camera1'
onready var camera2: Camera = $'Viewport2/Camera2'
onready var view: TextureRect = $'View'


func _ready() -> void:
	_on_size_changed()
	_update_splitscreen()
	
	get_viewport().connect("size_changed", self, "_on_size_changed")
	
	view.material.set_shader_param('viewport1', $Viewport1.get_texture())
	view.material.set_shader_param('viewport2', $Viewport2.get_texture())
	
	
func _process(delta) -> void:
	_move_cameras()
	_update_splitscreen()
	
	
func _move_cameras() -> void:
	var position_difference := _compute_position_difference_in_world()
	
	var distance := clamp(_compute_horizontal_length(position_difference), 0, max_separation)

	position_difference = position_difference.normalized() * distance

	camera1.translation.x = player1.translation.x + position_difference.x / 2.0
	camera1.translation.z = player1.translation.z + position_difference.z / 2.0

	camera2.translation.x = player2.translation.x - position_difference.x / 2.0
	camera2.translation.z = player2.translation.z - position_difference.z / 2.0
	
	
func _update_splitscreen() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	
	var player1_position := camera1.unproject_position(player1.translation)
	player1_position.x /= screen_size.x;
	player1_position.y /= screen_size.y;

	var player2_position := camera2.unproject_position(player2.translation)
	player2_position.x /= screen_size.x;
	player2_position.y /= screen_size.y;
	
	var thickness: float
	if adaptive_split_line_thickness:
		var position_difference := _compute_position_difference_in_world()
		var distance := _compute_horizontal_length(position_difference)
		thickness = lerp(0, split_line_thickness, (distance - max_separation) / max_separation)
		thickness = clamp(thickness, 0, split_line_thickness)
	else:
		thickness = split_line_thickness
	
	view.material.set_shader_param('split_active', _get_split_state())
	view.material.set_shader_param('split_origin', split_origin)
	view.material.set_shader_param('player1_position', player1_position)
	view.material.set_shader_param('player2_position', player2_position)
	view.material.set_shader_param('split_line_thickness', thickness)
	view.material.set_shader_param('split_line_color', split_line_color)
	
	
func _get_split_state() -> bool:
	var position_difference := _compute_position_difference_in_world()
	return _compute_horizontal_length(position_difference) > max_separation
	
	
func _on_size_changed() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	
	$Viewport1.size = screen_size
	$Viewport2.size = screen_size
	view.rect_size = screen_size
	
	view.material.set_shader_param('viewport_size', screen_size)
	
	
func _compute_position_difference_in_world() -> Vector3:
	return player2.translation - player1.translation
	
	
func _compute_horizontal_length(vec: Vector3) -> float:
	return Vector2(vec.x, vec.z).length()
