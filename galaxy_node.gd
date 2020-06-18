extends Node2D

#class_name GalaxyNode

enum NODE_TYPE {
	ROOT,
	ARM,
	ARM_EXTENTION,
	RANDOM_PLACEMENT,
	LONER,
	SYSTEM,
	CORE,
	EXTERNAL_RING,
}

const MAX_ARM_DEPTH = 15

var depth = 0

const SCALE = 50.0

const NUMBER_OF_SYSTEM_PER_NODE = 5

export var _type = NODE_TYPE.ROOT setget set_type
var galaxy_node # todo do better

func _ready():
	if _type == NODE_TYPE.ARM:
		for i in [-1,1]:
			var node_ext = galaxy_node.instance()
			node_ext._type = NODE_TYPE.ARM_EXTENTION
			var angle_ext = PI/ 2
			node_ext.depth = depth+1
			node_ext.galaxy_node = galaxy_node
			node_ext.position = position.rotated(angle_ext*i) * (float(depth)/float(MAX_ARM_DEPTH) *1.0)
			add_child(node_ext)
		if  depth < MAX_ARM_DEPTH:
			var node = galaxy_node.instance()
			node._type = NODE_TYPE.ARM
			var random_angle =  Global.rng.randf_range(-PI/MAX_ARM_DEPTH * (4.0/8.0) ,PI/MAX_ARM_DEPTH* (4.0/8.0))
			var angle = PI/MAX_ARM_DEPTH * (7.0/8.0) + random_angle
			node.position = position.normalized().rotated(angle)* SCALE * (1.0  + 0.5 *float(depth)/float(MAX_ARM_DEPTH) )
			node.depth = depth+1
			node.galaxy_node = galaxy_node
			add_child(node)
	if _type != NODE_TYPE.SYSTEM && galaxy_node!= null:
		if _type == NODE_TYPE.ARM || _type == NODE_TYPE.ARM_EXTENTION:
			pass
		else:
			for i in range(NUMBER_OF_SYSTEM_PER_NODE):
				var node = galaxy_node.instance()
				node._type = GalaxyNode.NODE_TYPE.SYSTEM
				node.depth = depth+1
				node.galaxy_node = galaxy_node
				var angle =   Global.rng.randf_range(0.0,2.0*PI)
				node.position =  Vector2(cos(angle),sin(angle)) * Global.rng.randf_range(0,SCALE*0.6)
				add_child(node)

func set_type(new_type):
	_type = new_type
	_modulate_color()

func _modulate_color():
	match _type :
		NODE_TYPE.ROOT:
			$ColorRect.set_modulate(Color(1.0,1.0,1.0))
		NODE_TYPE.ARM:
			$ColorRect.set_modulate(Color(1.0,0,0))
		NODE_TYPE.ARM_EXTENTION:
			$ColorRect.set_modulate(Color(0,1,0))
		NODE_TYPE.RANDOM_PLACEMENT:
			$ColorRect.set_modulate(Color(0,0,1))
		NODE_TYPE.LONER:
			$ColorRect.set_modulate(Color(1.0,1.0,0))
		NODE_TYPE.SYSTEM:
			$ColorRect.set_modulate(Color(1.0,0,1.0))
	
