extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mapPath = "res://Maps/test1.json"

var mapGroundMatrix = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	loadMapData();
	
func loadMapData():
	var file = File.new()
	
	if not file.file_exists(mapPath):
		return
		
	file.open(mapPath, File.READ)
	
	var payload = parse_json(file.get_as_text())
	print(payload.width)
	
	file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
