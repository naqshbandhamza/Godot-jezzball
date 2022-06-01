extends Node

onready var game_control = preload("res://src/components/controls.tscn")
var gcontrols
onready var character = preload("res://src/character.tscn")
var gc
onready var Choices = preload("res://src/components/Choices.tscn")
onready var Question = preload("res://src/components/Questions.tscn")
onready var Progress = preload("res://src/components/TextureProgressBar.tscn")
onready var ScoreNode = preload("res://src/components/Score.tscn")
onready var Live = preload("res://src/components/Lives.tscn")
onready var boxoption = preload("res://src/boxoptions.tscn")
var gprogress
var gchoices
onready var reload = false
var gquestion
var glives
var gscore
var json_url
var nolives
var mylang
var gameflag
var userid
var token
var correctanswered
var score
onready var pathj = "user://data.data"
var json_data
var dataj
var timelimit
var options = []
var questions
var noqs
var current_q
var jflag
var gameovercalled
var m_over
var gover

onready var goverfor = preload("res://src/components/gameover.tscn")
onready var menuover = preload("res://src/components/menu.tscn")
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var default_json_data = {
"questions": [
{
"question": "1 + 1 = _____",
"options": [
{ "value": "2", "correct": "true" },
{ "value": "3", "correct": "false" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 10
},
{
"question": "1 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "true" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
,
{
	"question": "3 + 2",
	"options": [
	{ "value": "2", "correct": "false" },
	{ "value": "3", "correct": "false" },
	{ "value": "4", "correct": "false" },
	{ "value": "5", "correct": "true" }
	],
	"score": 20
	}
	,
{
"question": "6 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "false" },
{ "value": "8", "correct": "true" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
,
{
"question": "1 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "true" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
],
"userId": 1,
"token": "xxxyyy",
"noOfLife": 3,
"timeLimit": 120
}




func getrandom():
	var nums = [1,2,3,4,5,6,7,8,9,10] #list to choose from
	randomize()
	var N = nums[randi() % nums.size()]
	while N in global.visited:
		randomize()
		N = nums[randi() % nums.size()]
	if global.visited.size()==9:
		global.visited = []
	global.visited.push_back(N)
	return N	

func load_data():
	var file = File.new()
	if not(file.file_exists(pathj)):
		file.open(pathj,File.WRITE)
		file.store_var(default_json_data)
		file.close()
		
	if json_data!=null:
		pass
	else:
		file.open(pathj,file.READ)
		dataj = file.get_var()
		file.close()	
		
	if json_data!=null:
		nolives = json_data['noOfLife']
		timelimit = json_data['timeLimit']
		questions = json_data['questions']
		
		gprogress.get_node("ProgressBar/Timer").set_wait_time(float(json_data['timeLimit'])/100)
		gprogress.get_node("ProgressBar/Timer").start()
		noqs = questions.size()
		current_q=0
		set_info_box_value()
	else:
		
		nolives = dataj['noOfLife']
		timelimit = dataj['timeLimit']
		userid = dataj['userId']
		token = dataj['token']
		questions = dataj['questions']
		
		gprogress.get_node("ProgressBar/Timer").set_wait_time(float(dataj['timeLimit'])/100)
		gprogress.get_node("ProgressBar/Timer").start()
		noqs = questions.size()
		current_q=0
		set_info_box_value()
	if file.file_exists("user://save.data"):
		var tempdataj
		file.open("user://save.data",file.READ)
		tempdataj = file.get_var()
		current_q = tempdataj['current question']
		correctanswered = tempdataj['correct answered']
		score = tempdataj['score']
		nolives = tempdataj['nolives']
		gprogress.get_node("ProgressBar").value = int(tempdataj['current timer value'])
		set_info_box_value()
	else:
		save_final_data()
		set_info_box_value()
		
func load_data1():
	var file = File.new()
	if not(file.file_exists("user://save.data")) or global.replay==false:
		global.replay = true
		file.open("user://save.data",File.WRITE)
		file.store_var({"current question":0,"correct answered":0,
	'score':0,'nolives':3,'current file':json_url,'current file data':null,'current timer value':100})
		file.close()
	
	file.open("user://save.data",file.READ)
	dataj = file.get_var()
	file.close()
	nolives = dataj['nolives']
	if nolives<3:
		if OS.has_feature('JavaScript'):
			json_url = dataj['current file']
			json_data = dataj['current file data']

func set_info_box_value():
	
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X '+str(nolives)
	gquestion.get_node("question").text = questions[current_q]['question']
	gchoices.get_node("holder/choice1").text = 'A) '+questions[current_q]['options'][0]['value']
	gchoices.get_node("holder/choice2").text = 'B) '+questions[current_q]['options'][1]['value']
	gchoices.get_node("holder/choice3").text = 'C) '+questions[current_q]['options'][2]['value']
	gchoices.get_node("holder/choice4").text = 'D) '+questions[current_q]['options'][3]['value']
	
func reset_info_box_value():
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X 0'
	gquestion.get_node("question").text = ' '
	gchoices.get_node("holder/choice1").text = ' '
	gchoices.get_node("holder/choice2").text = ' '
	gchoices.get_node("holder/choice3").text = ' '
	gchoices.get_node("holder/choice4").text = ' '	
	
func get_range(ranges_already_gain):
	randomize()
	var my_c_i = int(rand_range(0,4))
	while ranges_already_gain[my_c_i]==true:
		randomize()
		my_c_i = int(rand_range(0,4))
	ranges_already_gain[my_c_i]=true
	return my_c_i

func check_question_validaty(txt='p'):
	var qflag = false
	
	var prev_score = score
	
	if current_q < questions.size():
		var iscorrect = ''
		if txt=='A':
			if json_data==null:
				#when not on web and on godot engine
				if dataj['questions'][current_q]['options'][0]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'A'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				#when online on web
				if json_data['questions'][current_q]['options'][0]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'A'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='B':
			if json_data==null:
				if dataj['questions'][current_q]['options'][1]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'B'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][1]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'B'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='C':
			if json_data==null:
				if dataj['questions'][current_q]['options'][2]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'C'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][2]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'C'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='D':
			if json_data==null:
				if dataj['questions'][current_q]['options'][3]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'D'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][3]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'D'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim" 
					
				
		for e in options:
			if e.get_node("Sprite/RichTextLabel").text in txt:
				if e.get_node("Sprite/RichTextLabel").text ==iscorrect:
					e.get_node("Sprite/ColorRect").color = "#919bf30e"
				else:
					e.get_node("Sprite/ColorRect").color = "#91f33e0e"
			
					
					
		if score==prev_score:
			if nolives>0:
				nolives-=1
				glives.get_node("AnimationPlayer").current_animation="liveanim"
				glives.get_node("holder/lives").text = 'X '+str(nolives)
			if nolives==0:
				qflag = true
		else:
			if  str(score).length()==2:
				gscore.get_node("Score-bg/score").text = "  "+str(score)
			elif str(score).length()==1:
				gscore.get_node("Score-bg/score").text = "   "+str(score)
			else:
				gscore.get_node("Score-bg/score").text = str(score)
		
		if current_q + 1 < questions.size():
			current_q+=1
			#set_info_box_value()
		else:
			current_q+=1
			qflag=true
			reset_info_box_value()
			
		if qflag:
			if not(gameovercalled):
				gameovercalled = true
				yield(get_tree().create_timer(2.0), "timeout")
				game_over()
				gover = goverfor.instance()
				reset_info_box_value()
				add_child(gover)
				if get_tree().paused==false:
					get_tree().paused = true

func spawn_option():
	
	for e in options:
		e.get_node("Sprite/ColorRect").color = "#00FFFFFF"
	
	if gameflag==false:
		return
		
	var ranges_already_gain = [false,false,false,false]	
	
	var q_box_x = ($"main-game-board".get_rect().size.x*0.9)/2
	var q_box_y = ($"main-game-board".get_rect().size.y*0.9)/2
	var parentpos = options[0].get_parent().rect_position
	
	var ranges = [[parentpos.x+50,parentpos.x+q_box_x-50,parentpos.y+50,parentpos.y+q_box_y-50],
	[parentpos.x+q_box_x+50,parentpos.x+q_box_x*2-50,parentpos.y+50,parentpos.y+q_box_y-50],
	[parentpos.x+50,parentpos.x+q_box_x-50,parentpos.y+q_box_y+50,parentpos.y+q_box_y*2-50],
	[parentpos.x+q_box_x+50,parentpos.x+q_box_x*2-50,parentpos.y+q_box_y+50,parentpos.y+q_box_y*2-50]]	
	
	for i in range(4):
		var c_i = get_range(ranges_already_gain)
		var fpos
		var flag = true
		randomize()
		fpos = Vector2(rand_range(ranges[c_i][0],ranges[c_i][1]),
		rand_range(ranges[c_i][2],ranges[c_i][3]))
		
		options[i].get_node("Sprite").position = fpos
		if i==0:
			options[i].get_node("Sprite/RichTextLabel").text ='A'
		elif i==1:
			options[i].get_node("Sprite/RichTextLabel").text ='B'
		elif i==2:
			options[i].get_node("Sprite/RichTextLabel").text ='C'
		elif i==3:
			options[i].get_node("Sprite/RichTextLabel").text ='D'
		options[i].get_node("Sprite").visible = true
	
func save_final_data():
	var file = File.new()
	file.open("user://save.data",File.WRITE)
	var mystoredata = {"current question":current_q,"correct answered":correctanswered,
	'score':score,'nolives':nolives,'current file':str(json_url),'current file data':json_data,
	'current timer value':gprogress.get_node("ProgressBar").value}
	file.store_var(mystoredata)
	file.close()


var frame_h
var frame_w
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	if global.replay:
		global.Dots = []
	else:
		global.replay = true
	
	$"main-game-board/KinematicBody2D".connect("clearline2d",self,"clearline2dd")
	jflag = false
	
	
	gchoices = Choices.instance()
	gquestion = Question.instance()
	gprogress = Progress.instance()
	gscore = ScoreNode.instance()
	glives = Live.instance()
	glives.get_node("AnimationPlayer").current_animation="liveanim"
	
	add_child(gprogress)
	add_child(gquestion)
	#gquestion.get_node("question").add_font_override("font_size",400)
	add_child(gscore)
	add_child(glives)
	
	for i in range(0,4):
		options.append(boxoption.instance())
		options[i].get_node("Sprite").visible = false
		$"main-game-board".add_child(options[i])
		
		
		options[i].get_node("Sprite").position.x = options[i].get_parent().rect_position.x
		options[i].get_node("Sprite").position.y = options[i].get_parent().rect_position.y
		
	
	gquestion.get_node("question").visible = false
	add_child(gchoices)
	
	gchoices.get_node("holder/choice1").visible = false
	gchoices.get_node("holder/choice2").visible = false
	gchoices.get_node("holder/choice3").visible = false
	gchoices.get_node("holder/choice4").visible = false	
	gameovercalled = false
	
	json_data= null
	json_url = null
	mylang = null
	load_data1()
	
	if OS.has_feature('JavaScript') and nolives==3:
		json_url =  JavaScript.eval(""" 
			  const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	  const id = urlParams.get("id");
	  const server = urlParams.get("server");
	  const userId = urlParams.get("userId");
	  const token = urlParams.get("token");
	  let thereturn = null;
	  const score = 100;
	  function sendResult() {
		console.log("sendResult");
		var formData = new FormData();
		formData.append("paperId", id);
		formData.append("score", score);
		formData.append("userId", userId);
		formData.append("token", token);

		var xhr = new XMLHttpRequest();
		// xhr.withCredentials=true
		xhr.open("POST", server + "/api/submitGameResult");
		xhr.send(formData);
		xhr.onreadystatechange = function () {
		  // If the request completed, close the extension popup
		  if (this.readyState == 4)
			if (this.status == 200) {
			  const response = JSON.parse(this.response);
			  console.log(response);

			  if (response.success) {
				// result submission succefully
				console.log("success");
			  } else {
				console.log("fail");
			  }
			}
		};
	  }
	  var getJSON = function (url, callback) {
		var xhr = new XMLHttpRequest();
		xhr.open("GET", url, true);
		xhr.responseType = "json";
		xhr.onload = function () {
		  var status = xhr.status;
		  if (status === 200) {
			callback(null, xhr.response);
		  } else {
			callback(status, xhr.response);
		  }
		};
		xhr.send();
	  };
	  function getRandomArbitrary(min, max) {
		
		return Math.random() * (max - min) + min;
	  }
	  let file_num = parseInt(getRandomArbitrary(1, 11));
	  
	thereturn = server + "/game/" + id + "/" + file_num.toString() + ".json";
	thereturn = server + "/game/" + id + "/";
	thereturn = "https://demo-backend.learning-canvas.com"+"/game/"+46+"/";
		""")
	#thereturn = "https://demo-backend.learning-canvas.com"+"/game/"+46+"/";
		mylang =  JavaScript.eval(""" 
			  const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	  let temp = urlParams.get("lang");
	  
	  temp; 
	   """)
	
	if json_url!=null and json_data==null:
		
		if OS.has_feature('JavaScript') and global.buffer.size()==0 and global.replay1==false:
			
			
			
			$HTTPRequest.request(json_url+str(getrandom())+".json")
			
		else:
			if global.buffer.size()==0:
				json_data = default_json_data
			else:
				json_data = global.buffer.pop_front()
			load_data()
			if OS.has_feature('JavaScript') :
				$HTTPRequest2.request(json_url+str(getrandom())+".json")
			
				
	get_tree().paused = false
	var temp_pos = Vector2(0,0)
	
	correctanswered=0
	load_data1()
	
	if json_url==null:
		load_data()
	if json_data!=null:
		load_data()
	
	
	gameflag = true
	gprogress.get_node("ProgressBar").connect("timebartimeout",self,"timebar_runout")
	
	spawn_option()
	
	if nolives==3 and global.replay1==false:
		m_over = menuover.instance()
		add_child(m_over)
		
		if mylang=='zh':
			m_over.get_node("CanvasLayer2/Start-box/ReferenceRect/RichTextLabel").text='開始遊戲'
		else:
			m_over.get_node("CanvasLayer2/Start-box/ReferenceRect/RichTextLabel").text=' START'
		m_over.get_node("CanvasLayer/Area2D/CollisionShape2D").set_z_index(9)
		if OS.has_feature('JavaScript'):
			m_over.get_node("CanvasLayer2/Start-box/start").disabled = true
	
	if global.replay1:
		get_tree().paused = false
	
	gcontrols = game_control.instance()
	add_child(gcontrols)
	gc = character.instance()
	global.ref_c = gc
	gc.connect("check_for_option",self,"check_for_option_ok")
	frame_h =  gc.get_node("Sprite").texture.get_height()/gc.get_node("Sprite").vframes*0.8
	frame_w =  gc.get_node("Sprite").texture.get_width()/gc.get_node("Sprite").hframes*0.8
	frame_h = int(frame_h)
	frame_w = int(frame_w)
	$"main-game-board".add_child(gc)
	gc.get_node("Sprite").frame = 0
	gc.position.x = $"main-game-board".rect_size.x/2
	gc.position.y = $"main-game-board".rect_size.y - frame_h+70
	randomize()
	
	
	$"main-game-board/KinematicBody2D/Sprite".position.x = rand_range(100,700);
	$"main-game-board/KinematicBody2D/Sprite".position.y = rand_range(100,700);
	$"main-game-board/KinematicBody2D/Sprite2".position = $"main-game-board/KinematicBody2D/Sprite".position
	
	
	
	gcontrols.connect("d",self,"move_down")
	gcontrols.connect("u",self,"move_up")
	gcontrols.connect("r",self,"move_right")
	gcontrols.connect("l",self,"move_left")
	gcontrols.connect("arup",self,"moverup")
	gcontrols.connect("alup",self,"movelup")
	gcontrols.connect("auup",self,"moveuup")
	gcontrols.connect("adup",self,"movedup")
	
	gameflag = true
	set_physics_process(true)


func pointInPolygon(params,dcount=-1):
	var xi
	var yi
	var xj
	var yj
	var intersect
	var x = params.x
	var  y = params.y
	if dcount==-1:
		 x = params.x+50
		 y = params.y+50
	else:
		x = params.x-50
		y = params.y-50
	var inside = false
	var i = 0
	var j = global.Dots.size()-1
	var pcount =  global.Dots.size()
	#print(global.Dots)
	while i < pcount:
		xi =  global.Dots[i].x+330
		yi = global.Dots[i].y+113
		xj = global.Dots[j].x+330
		yj = global.Dots[j].y+113
		intersect = ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
		if  intersect:
			inside = not(inside)
		j = i
		i+=1
		
	if not(inside):
		if dcount==-1:
			pointInPolygon(params,0)
		
	return inside;

func check_for_option_in_area():
	var result = ''
	for i in range (0,4):
		if(pointInPolygon(options[i].get_node("Sprite").position)):
			result=result+options[i].get_node("Sprite/RichTextLabel").text
	
	return result

func check_for_option_ok():
	var p_count = gc.get_node("Line2D").get_point_count()
	#global.poly_points.append(gc.get_node("Line2D").get_point_position(p_count-1))
	var selected_txt=""	
	#print(global.Dots)
	selected_txt = check_for_option_in_area()
	if selected_txt!="":
		$"main-game-board/KinematicBody2D".motionpause=true
		$"main-game-board/KinematicBody2D/AnimationPlayer".stop()	
		gprogress.get_node("ProgressBar/Timer").paused = true
		gc.motionpause = true
		check_question_validaty(selected_txt)
		yield(get_tree().create_timer(2.0), "timeout")
		if current_q<questions.size() and nolives>0:
			set_info_box_value()
		else:
			reset_info_box_value()
		spawn_option()
		$"main-game-board/KinematicBody2D/AnimationPlayer".play()
		$"main-game-board/KinematicBody2D".motionpause=false
		gprogress.get_node("ProgressBar/Timer").paused = false
		gc.motionpause = false
		gc.get_node("Sprite").frame = 0
		gc.position.x = $"main-game-board".rect_size.x/2
		gc.position.y = $"main-game-board".rect_size.y - frame_h+70
	
	#print(global.poly_points)
	gc.col_line = []
	global.poly_points = []
	global.Dots=[]
	gc.remove_ddots()
	gc.get_node("Line2D").clear_points()

func move_down():
	gc.moveit('d')
	
func moverup():
	gc.df="r"
	gc.get_node("Timer").start()
	
func movelup():
	gc.df="l"
	gc.get_node("Timer").start()
	
func moveuup():
	gc.df="u"
	gc.get_node("Timer").start()
	
func movedup():
	gc.df="d"
	gc.get_node("Timer").start()

func move_up():
	gc.moveit('u')

func move_left():
	gc.moveit('l')
	
func move_right():
	gc.moveit('r')


var shirukenpos
var lpos

func _physics_process(delta: float) -> void:
	if gameflag:
		if not(jflag):
			jflag = true
			gquestion.get_node("question").visible = true
			gquestion.get_node("question").rect_position.x = 600
			gquestion.get_node("question").rect_position.y = 970
			gchoices.get_node("holder/choice1").visible = true
			gchoices.get_node("holder/choice2").visible = true
			gchoices.get_node("holder/choice3").visible = true
			gchoices.get_node("holder/choice4").visible = true
			
	"""			
	var Min = 9999

	shirukenpos = 	$"main-game-board/KinematicBody2D/Sprite".position
	for i in range(0,gc.get_node("Line2D").get_point_count()):
		lpos = gc.get_node("Line2D").get_point_position(i)
		var distance = sqrt( pow(lpos.x - shirukenpos.x, 2) + pow(lpos.y - shirukenpos.y, 2))
		if(distance < Min):
			Min = distance
			
	if(Min < 28):
		$"main-game-board/KinematicBody2D".gamepause = true"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func clearline2dd():
	$"main-game-board/KinematicBody2D".motionpause=true
	$"main-game-board/KinematicBody2D/AnimationPlayer".stop()
	gc.motionpause = true
	gc.col_line = []
	global.poly_points = []
	global.Dots=[]
	yield(get_tree().create_timer(2.0), "timeout")
	gc.get_node("Line2D").clear_points()
	gc.remove_ddots()
	#nolives-=1
	gc.start=false
	gc.end = false
	global.prev_state='start'
	
	gc.get_node("Sprite").frame = 0
	gc.position.x = $"main-game-board".rect_size.x/2
	gc.position.y = $"main-game-board".rect_size.y - frame_h+70
	
	if nolives>0 and not(gameovercalled):
		nolives-=1
		glives.get_node("AnimationPlayer").current_animation="liveanim"
		set_info_box_value()
	if nolives==0 and not(gameovercalled):
		
		gameovercalled = true
		game_over()
		gover = goverfor.instance()
		reset_info_box_value()
		add_child(gover)
		if get_tree().paused==false:
			get_tree().paused = true
	
	$"main-game-board/KinematicBody2D".motionpause=false
	$"main-game-board/KinematicBody2D/AnimationPlayer".play()
	gc.motionpause = false

func set_info_box_value_answered():
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X '+str(nolives)
	gquestion.get_node("question").text = ''
	gchoices.get_node("holder/choice1").text = ''
	gchoices.get_node("holder/choice2").text = ''
	gchoices.get_node("holder/choice3").text = ''
	gchoices.get_node("holder/choice4").text = ''

func game_over():
	gameovercalled = true
	reload = true
	set_info_box_value_answered()
	glives.get_node("AnimationPlayer").current_animation="liveanim"
	var file = File.new()
	#file.open("res://gamestate.json",File.WRITE)
	if OS.has_feature('JavaScript'):
		JavaScript.eval("""
		
		String.prototype.hashCode = function() {
	var hash = 0;
	if (this.length == 0) {
		return hash;
	}
	for (var i = 0; i < this.length; i++) {
		var char = this.charCodeAt(i);
		hash = ((hash<<5)-hash)+char;
		hash = hash & hash; 
	}
	return hash;
	  }
	
		const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	const keys = urlParams.keys();
	
	  const id = urlParams.get("id");
	  const server = urlParams.get("server");
	  const userId = urlParams.get("userId");
	  const token = urlParams.get("token");

	  const score = \'%s\';
	
	  var hashed_score = id+score;
	  //console.log(hashed_score.hashCode());

	  function sendResult() {
		
		var formData = new FormData();
		
		for (const key of keys) {
			if (key==="id")
				formData.append("paperId", urlParams.get(key));
			else if(key!=="server" && key!=="lang")
				formData.append(key, urlParams.get(key));
			}
		formData.append("score", score);
		formData.append("hashcode", hashed_score.hashCode());

		var xhr = new XMLHttpRequest();
		// xhr.withCredentials=true
		xhr.open("POST", server + "/api/submitGameResult");
		xhr.send(formData);
		xhr.onreadystatechange = function () {
		  // If the request completed, close the extension popup
		  if (this.readyState == 4)
			if (this.status == 200) {
			  const response = JSON.parse(this.response);
			  //console.log(response);

			  if (response.success) {
				// result submission succefully
				//console.log("success");
			  } else {
				//console.log("fail");
			  }
			}
		};
	  }
	
	  sendResult();
	
	
		"""%score)
	file.open("user://save.data",File.WRITE)
	var mystoredata = {"current question":0,"correct answered":0,
	'score':0,'nolives':3,'current file':null,'current timer value':100}
	#print(mystoredata)
	file.store_var(mystoredata)
	file.close()
	
func timebar_runout():
	gameflag = false
	#print("in time bar runout")
	if not(gameovercalled):
		gameovercalled = true
		nolives = 0
		game_over()
		gover = goverfor.instance()
		#reset_infobox("correct answers:"+str(correctanswered)+"\ntotal questions:"+str(noqs)+"\nscore:"+str(score))
		add_child(gover)
		if get_tree().paused==false:
			get_tree().paused = true

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	var json = JSON.parse(body.get_string_from_utf8())
	
	json_data = json.result
	if response_code==200:
		pass
	else:
		json_data = default_json_data
	randomize()
	$HTTPRequest2.request(json_url+str(getrandom())+".json")
	load_data()

func _on_HTTPRequest2_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code==200:
		global.buffer.push_back(json.result)
	else:
		global.buffer.push_back(default_json_data)
	if global.replay1==false:
		m_over.get_node("CanvasLayer2/Start-box/start").disabled = false
	else:
		get_tree().paused = false
