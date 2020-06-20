extends Node2D




var galaxy_node = preload("res://galaxy_node.tscn")


func _ready():
	Global.rng.randomize()
	generate_galaxy()
	pass # Replace with function body.


func generate_galaxy():
	var rootNode = galaxy_node.instance()
	rootNode.galaxy_node = galaxy_node
	rootNode.name = "root"
	rootNode._type = GalaxyNode.NODE_TYPE.ROOT
	rootNode.depth = 0
	add_child(rootNode)
	
