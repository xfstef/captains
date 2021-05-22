extends Node2D

var width
var height
var ground_tm

func _ready():
	ground_tm = get_node("TM-Ground")
	ground_tm.initEmpty(width, height)
	

