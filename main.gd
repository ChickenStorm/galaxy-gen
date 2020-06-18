extends Node2D



const NUMBER_OF_ARM = 3
var galaxy_node = preload("res://galaxy_node.tscn")
const SCALE = 50.0
const NUMBER_OF_LONER_PER_ARM = 4

const NUMBER_OF_RANDOM_NODE = 10

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
	var general_angle_shift = Global.rng.randf_range(0.0,2.0*PI)
	for i in range(NUMBER_OF_ARM):
		var node = galaxy_node.instance()
		node.name = i as String
		node._type = GalaxyNode.NODE_TYPE.ARM
		node.depth = 1
		node.galaxy_node = galaxy_node
		var angle =  i * 2 * PI / NUMBER_OF_ARM + general_angle_shift
		node.position = SCALE* Vector2(cos(angle),sin(angle))
		rootNode.add_child(node)
		for j in range(NUMBER_OF_LONER_PER_ARM):
			var node_loner = galaxy_node.instance()
			node_loner._type = GalaxyNode.NODE_TYPE.LONER
			node_loner.depth = 1
			node_loner.galaxy_node = galaxy_node
			var angle_random = Global.rng.randf_range(-PI / float(NUMBER_OF_ARM)*0.5,PI / float(NUMBER_OF_ARM)*0.5)
			var angle_loner =  (i+0.8) * 2.0 * PI / NUMBER_OF_ARM + general_angle_shift + angle_random
			node_loner.position =  Vector2(cos(angle_loner),sin(angle_loner)) * Global.rng.randf_range(SCALE*2.0,SCALE*node_loner.MAX_ARM_DEPTH/1.5)
			rootNode.add_child(node_loner)
	for i in range(NUMBER_OF_RANDOM_NODE):
		var node = galaxy_node.instance()
		node._type = GalaxyNode.NODE_TYPE.RANDOM_PLACEMENT
		node.depth = 1
		node.galaxy_node = galaxy_node
		var angle =   Global.rng.randf_range(0.0,2.0*PI)
		node.position =  Vector2(cos(angle),sin(angle)) * Global.rng.randf_range(SCALE*2.0,SCALE*node.MAX_ARM_DEPTH/1.1)
		rootNode.add_child(node)
