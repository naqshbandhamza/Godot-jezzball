extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var replay = false
var replay1 = false

var buffer = [] 
var visited = []

var poly_points = []
var Dots = []
var prev_state = 'start'
var startedborder
var ref_c
var cdots = []
var c = 'none'

var eve = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
