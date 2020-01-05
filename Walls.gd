extends Spatial

func _ready():
	var walls = get_tree().get_nodes_in_group("walls")
	for obj in walls:
		var material := SpatialMaterial.new()
		material.albedo_color = Color(randf(), randf(), randf())
		
		var wall := obj as MeshInstance
		wall.material_override = material