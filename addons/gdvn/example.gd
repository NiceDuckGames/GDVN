extends Node


var data: Dictionary = {
	"bool": false,
	"int": 123,
	"float": 4.56,
	"plane": Plane(Vector3(1.5, .25, .1)),
	"dict": {
		"quat": Quaternion(1.1, 2.22, 3.333, 4.4444)
	},
	"arr": [
		Rect2i(0, 0, 0, 9),
		Vector2(0.0,0.0)
	]
}

var import_data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	import()
	save()
	
	print(import_data)


func save():
	
	var fa = FileAccess.open("res://addons/gdvn/example.json", FileAccess.WRITE)
	
	var data_as_str = GDVN.stringify(data)
	
	fa.store_string(data_as_str)
	
	fa.close()


func import():
	
	var fa = FileAccess.open("res://addons/gdvn/example.json", FileAccess.READ)
	
	var text = fa.get_as_text()
	
	import_data = GDVN.parse_string(text)
	
	fa.close()
	
	
