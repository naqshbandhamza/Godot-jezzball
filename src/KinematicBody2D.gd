extends KinematicBody2D

var vel = Vector2(2,1)
var boardsize
var pos
var extents
var gamepause = false
var once_emitted = false
var motionpause = false
var lastmoved='down'


signal clearline2d
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boardsize = get_parent().rect_size
	pos = Vector2(274,163)
	extents = $Sprite.texture.get_size()*0.4/2
	
	set_physics_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	
	var temp_pos = $Sprite.position
	
	for i in range(0,global.Dots.size()):
		if (global.Dots[i].x >= $Sprite.position.x-30 and  global.Dots[i].x  <= $Sprite.position.x+30
		and global.Dots[i].y  >= $Sprite.position.y-30 and  global.Dots[i].y  <= $Sprite.position.y+30):
			emit_signal("clearline2d")
			#global.ref_c.get_node("Line2D").clear_points()
			break
	
	"""if $Sprite.position.x >= boardsize.x or $Sprite.position.x <= 0:
		vel.x*=-1
	if $Sprite.position.y >=boardsize.y or $Sprite.position.y <= 0:
		vel.y*=-1"""
		
	if $Sprite.position.x >= boardsize.x-extents.x:
		lastmoved = 'right'
		$Sprite.position.x = boardsize.x - extents.x
		vel.x*=-1
	if $Sprite.position.x <= extents.x:
		lastmoved = 'left'
		$Sprite.position.x = extents.x
		vel.x*=-1
		
	if $Sprite.position.y >= boardsize.y-extents.y:
		lastmoved = 'down'
		$Sprite.position.y = boardsize.y - extents.y
		vel.y*=-1
	if $Sprite.position.y <= extents.y:
		lastmoved = 'up'
		$Sprite.position.y = extents.y
		vel.y*=-1
	
	if not(gamepause or motionpause):
		$Sprite.position = $Sprite.position+vel
		$Sprite2.position = $Sprite.position+vel
	else:
		if motionpause==false:
			$AnimationPlayer.stop()
			for i in range(0,global.poly_cols.size()):
				get_parent().remove_child(global.poly_cols[i])
			global.poly_cols = []
			$AnimationPlayer.play()
			global.poly_points = []
			gamepause=false
			emit_signal("clearline2d")

		#yield(get_tree().create_timer(2.0), "timeout")
		
	













func _on_Timer_timeout() -> void:
	print("timer out")
	for i in range(0,global.poly_cols.size()):
		get_parent().remove_child(global.poly_cols[i])
	global.poly_cols = []
	$AnimationPlayer.play()
	global.poly_points = []
	gamepause=false
	emit_signal("clearline2d")



func _on_star_area_entered(area: Area2D) -> void:
	pass
