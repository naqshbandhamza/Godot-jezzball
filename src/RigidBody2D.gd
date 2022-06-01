extends RigidBody2D

func _ready():
	pass

# Offset the points of the polygon by the center of the line
func _physics_process(delta: float) -> void:
	$trail.add_point(get_parent().global_position)
	$trail.set_point_position(1,get_parent().global_position)
