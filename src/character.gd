extends KinematicBody2D
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export (NodePath) var targetPath

var df = 'd'
var point
var start = false
var end = false
onready var CRect = preload("res://src/Label.tscn")
onready var segments = preload("res://src/line2Darea.tscn")

var seg
var col_line = []

signal check_for_option

var a2d
var cshape2d
var shape
var scolor
var motionpause = false
var turn = "none"
onready var time = 0
onready var timeDirection = 1
onready var moveDuration = 1

var yp = Vector2(0,0)

func moveitright():
	$AnimationPlayer.current_animation = "walk_right"
	if position.x<841:
		position.x+=1
		df = ""
		point = global_position
		if position.x <= 850 and position.x >= 0 and position.y >= -50 and position.y <= 775:
			global.Dots.append(Vector2(position.x,position.y+57))
			#$Line2D.add_point(point)
			if global.eve==0 or global.eve==6:
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.cdots[-1].rect_position = Vector2(point.x,point.y+30)
			if global.eve==6:
				global.eve=0
			else:
				global.eve+=1
			if start==false:
				if position.x > 0:
					global.startedborder = "left"
					start = true
		if start==true and end==false:
			if position.x > 840:
				end = true
	
func moveitleft():
	$AnimationPlayer.current_animation = "walk_left"
	if position.x>-1:	
		position.x-=1
		df = ""
		point = global_position
		if position.x <= 850 and position.x >= 0 and position.y >= -50 and position.y <= 775:
			global.Dots.append(Vector2(position.x,position.y+57))
			
			#$Line2D.add_point(point)
			if global.eve==0 or global.eve==6:
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.cdots[-1].rect_position = Vector2(point.x,point.y+30)
			if global.eve==6:
				global.eve=0
			else:
				global.eve+=1
				
			if start==false:
				if position.x < 850:
					global.startedborder = "right"
					start = true
		if start==true and end==false:
			if position.x <0:
				end = true
	
func moveitup():
	$AnimationPlayer.current_animation = "walk_up"
	if position.y>-60:
		var bpoint = global_position
		position.y-=1
		df = ""
		point = global_position
		if position.x <= 840 and position.x >= 10 and position.y >= -60 and position.y <= 785:
			if global.prev_state == 'start':
				global.eve = 0
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.cdots[-1].rect_position = Vector2(bpoint.x,bpoint.y+30)
				global.eve+=1
				#$Line2D.add_point(bpoint)
				pass
			if global.eve==0 or global.eve==6:
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.cdots[-1].rect_position = Vector2(point.x,point.y+30)
			if global.eve==6:
				global.eve=0
			else:
				global.eve+=1
			#$Line2D.add_point(point)
			global.Dots.append(Vector2(position.x,position.y+57))
			if start==false:
				if position.y < 850:
					global.startedborder = "bottom"
					start = true
		if start==true and end==false:
			if not(position.y > -60):
				end = true
	
func moveitdown():
	$AnimationPlayer.current_animation = "walk_down"
	if position.y<785:
		var bpoint = global_position
		position.y+=1
		df = ""
		point = global_position
		if position.x <= 840 and position.x >= 10 and position.y >= -60 and position.y <= 785:
			if global.prev_state == 'start':
				global.eve = 0
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.eve+=1
				#$Line2D.add_point(bpoint)
			#$Line2D.add_point(point)
			
			if global.eve==0 or global.eve==6:
				global.cdots.append(CRect.instance())
				get_parent().add_child(global.cdots[-1])
				global.cdots[-1].rect_position = Vector2(point.x,point.y+30)
			if global.eve==6:
				global.eve=0
			else:
				global.eve+=1
			
			global.Dots.append(Vector2(position.x,position.y+57))
				
			if start==false:
				if position.y > 0:
					global.startedborder = "top"
					start = true
		if start==true and end==false:
			if not(position.y<785):
				end = true

func moveit(c):
	if motionpause:
		return
	if c=='r':
		df = 'r'
		$Timer.start()
		turn="right"
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='r'):
			ls = 20
		else:
			ls = 10
		global.prev_state='r'
		while count < ls:
			moveitright()
			count+=1
			
	elif  c=='l':
		df = 'l'
		$Timer.start()
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='l'):
			ls = 20
		else:
			ls = 10
		global.prev_state='l'
		while count < ls:
			moveitleft()
			count+=1
			
	elif c=='u':
		df = 'u'
		$Timer.start()
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='u'):
			ls = 20
		else:
			ls = 10
		global.prev_state='u'
		while count < ls:
			moveitup()
			count+=1
			
	elif c=='d':
		df = 'd'
		$Timer.start()
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='d'):
			ls = 20
		else:
			ls = 10
		global.prev_state='d'
		while count < ls:
			moveitdown()
			count+=1
					
	if start==true and end==true:
		start = false
		end = false
		global.prev_state = 'start'
		emit_signal("check_for_option")
		
func update():
	if motionpause:
		return
		
	if Input.is_key_pressed(KEY_RIGHT) or global.c=='r':
		turn="right"
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='r'):
			ls = 4
		else:
			ls = 4
		global.prev_state='r'
		while count < ls:
			moveitright()
			count+=1
			
	elif  Input.is_key_pressed(KEY_LEFT) or global.c=='l':
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='l'):
			ls = 4
		else:
			ls = 4
		global.prev_state='l'
		while count < ls:
			moveitleft()
			count+=1
			
	elif  Input.is_key_pressed(KEY_UP) or global.c=='u':
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='u'):
			ls = 4
		else:
			ls = 4
		global.prev_state='u'
		while count < ls:
			moveitup()
			count+=1
		
			
	elif  Input.is_key_pressed(KEY_DOWN) or global.c=='d':
		var count = 0
		var ls = 0
		if global.prev_state=='start' or not(global.prev_state=='d'):
			ls = 4
		else:
			ls = 4
		global.prev_state='d'
		while count < ls:
			moveitdown()
			count+=1
		
					
	if start==true and end==true:
		thecheck()
		start = false
		end = false
		global.prev_state = 'start'
		#remove_ddots()
		emit_signal("check_for_option")
		
func thecheck():
	
	
	if global.startedborder == "left":
		if position.y > 785:
			global.Dots.append(Vector2(0,850))
		elif position.y < 0:
			global.Dots.append(Vector2(0,0))
		if position.x > 840:
			if(position.y < 785 / 2):
				global.Dots.append(Vector2(850,0))
				global.Dots.append(Vector2(0,0))
			else:
				global.Dots.append(Vector2(850,850))
				global.Dots.append(Vector2(0,850))
	elif global.startedborder == "right":
		if position.y > 785:
			global.Dots.append(Vector2(850,850))
		elif position.y <= 0:
			global.Dots.append(Vector2(850,0))
		if position.x < 10:
			if position.y < 785 / 2:
				global.Dots.append(Vector2(0,0))
				global.Dots.append(Vector2(850,0))
			else:
				global.Dots.append(Vector2(0,850))
				global.Dots.append(Vector2(850,850))
	elif global.startedborder == "top":
		if position.x > 840:
			global.Dots.append(Vector2(850,0))
		elif position.x < 10:
			global.Dots.append(Vector2(0,0))
		if position.y > 785:
			if position.x < 840 / 2:
				global.Dots.append(Vector2(0,850))
				global.Dots.append(Vector2(0,0))
			else:
				global.Dots.append(Vector2(850,850))
				global.Dots.append(Vector2(850,0))
	elif global.startedborder == "bottom":
		if position.x > 840:
			global.Dots.append(Vector2(850,850))
		elif position.x < 10:
			global.Dots.append(Vector2(0,850))
		if position.y <= 0:
			if position.x < 840 / 2:
				global.Dots.append(Vector2(0,0))
				global.Dots.append(Vector2(0,850))
			else:
				global.Dots.append(Vector2(850,0))
				global.Dots.append(Vector2(850,850))
		
func remove_ddots():
	for i in range(0,global.cdots.size()):
		get_parent().remove_child(global.cdots[i])
	global.cdots=[]

func _ready() -> void:
	set_physics_process(true)
	$Timer.set_wait_time(0.2)

func _physics_process(delta: float) -> void:
	update()
	
	if Input.is_action_just_released("ui_down"):
		if not(motionpause):
			df = 'd'
			$Timer.start()
		
	if Input.is_action_just_released("ui_up"):
		if not(motionpause):
			df = 'u'
			$Timer.start()
		
	if Input.is_action_just_released("ui_right"):
		turn="none"
		if not(motionpause):
			df = 'r'
			$Timer.start()
		
	if Input.is_action_just_released("ui_left"):
		if not(motionpause):
			df = 'l'
			$Timer.start()
				

func _on_Timer_timeout() -> void:
	$Timer.stop()
	if df=='d':
		$Sprite.frame = 0
	elif df=='u':
		$Sprite.frame = 1
	elif df=='r':
		$Sprite.frame = 2
	elif df=='l':
		$Sprite.frame = 3
	
