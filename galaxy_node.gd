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
	ARM_INTERPOLATE, # used to interpolate two arm node
	ARM_EXTENTION_INTERPOLATE, # to interpolate between ARM and it's ARM_EXTENTION
	ARM_INTERPOLATE_EXTENTION, # used to expand ARM_INTERPOLATE
	ARM_EXTENTION_INTERPOLATE_ARM, # used to interpolate between ARM_INTERPOLATE and ARM_INTERPOLATE_EXTENTION
}



var depth = 0
var galaxy_node # todo do better
export var _type = NODE_TYPE.ROOT setget set_type
var arm_number = 0 # 0 if not in an arm

var general_angle_shift = 0

const NUMBER_OF_ARM = 5
const SCALE = 10.0 # scale for the drawing
#this is not the Node2D.scale
const NUMBER_OF_LONER_PER_ARM = 10
const NUMBER_OF_RANDOM_NODE = 10
const NUMBER_OF_SYSTEM_PER_NODE = 2
const MAX_ARM_DEPTH = 15
const ARM_EXTENTION_SCALE = 4.0 * pow(MAX_ARM_DEPTH/15.0,2.0)
const FINAL_ARM_ANGLE = 2.0 * PI
const MAX_DIST_NODE = SCALE * 4.0 # maximum distance between node in arm for interpolation
const NUMBER_OF_CORE_NODE = 30
const CORE_RANGE = 8.0 # max distance to create core node in units of SCALE 

func _ready():
	if galaxy_node == null:
		return
	if _type == NODE_TYPE.ROOT:
		general_angle_shift = Global.rng.randf_range(0.0,2.0*PI)
		# Connect arm to the root
		for i in range(NUMBER_OF_ARM):
			var node = galaxy_node.instance()
			node.name = i as String
			node._type = GalaxyNode.NODE_TYPE.ARM
			node.general_angle_shift = general_angle_shift
			node.arm_number = i+1
			node.depth = 1
			node.galaxy_node = galaxy_node
			var angle =  i * 2 * PI / NUMBER_OF_ARM + general_angle_shift
			node.position = SCALE* Vector2(cos(angle),sin(angle))
			add_child(node)
			# Gen or Loner
			for j in range(NUMBER_OF_LONER_PER_ARM):
				var node_loner = galaxy_node.instance()
				node_loner._type = GalaxyNode.NODE_TYPE.LONER
				node_loner.depth = 1
				node_loner.galaxy_node = galaxy_node
				var angle_random = Global.rng.randf_range(-PI / float(NUMBER_OF_ARM)*0.5,PI / float(NUMBER_OF_ARM)*0.5)
				var angle_loner =  (i+0.4) * 2.0 * PI / NUMBER_OF_ARM + general_angle_shift + angle_random
				node_loner.position =  Vector2(cos(angle_loner),sin(angle_loner)) * Global.rng.randf_range(SCALE*pow(PI/2,3.0),SCALE*pow(PI,3.0))
				# the scale is given by the eliptique equation 
				# we choose a region where there is few system
				add_child(node_loner)
		#Random node gen
		for i in range(NUMBER_OF_RANDOM_NODE):
			var node = galaxy_node.instance()
			node._type = GalaxyNode.NODE_TYPE.RANDOM_PLACEMENT
			node.depth = 1
			node.galaxy_node = galaxy_node
			var angle =   Global.rng.randf_range(0.0,2.0*PI)
			node.position =  Vector2(cos(angle),sin(angle)) * Global.rng.randf_range(SCALE*2.0,SCALE*pow(FINAL_ARM_ANGLE/1.5,3.0))
			# note the density goes like 1/r^2 because of the way we generate the position
			add_child(node)
		# core
		for i in range (NUMBER_OF_CORE_NODE):
			var node = galaxy_node.instance()
			node._type = GalaxyNode.NODE_TYPE.CORE
			node.depth = 1
			node.galaxy_node = galaxy_node
			var angle =   Global.rng.randf_range(0.0,2.0*PI)
			node.position =  Vector2(cos(angle),sin(angle)) * Global.rng.randf_range(SCALE*2.0,SCALE*CORE_RANGE)
			# note the density goes like 1/r^2 because of the way we generate the position
			add_child(node)
	# Generation of the arm extention
	if _type == NODE_TYPE.ARM || _type == NODE_TYPE.ARM_INTERPOLATE:
		for i in [-1,1]:
			var node_ext = galaxy_node.instance()
			if _type == NODE_TYPE.ARM:
				node_ext._type = NODE_TYPE.ARM_EXTENTION
			else:
				node_ext._type = NODE_TYPE.ARM_INTERPOLATE_EXTENTION
			var angle_ext = PI/ 2
			node_ext.depth = depth+1
			node_ext.galaxy_node = galaxy_node
			node_ext.position = ARM_EXTENTION_SCALE*SCALE*float(depth)/float(MAX_ARM_DEPTH) *position.normalized().rotated(angle_ext*i)
			node_ext.arm_number =  arm_number
			add_child(node_ext)
	# we extend the arms
	if _type == NODE_TYPE.ARM:
		if  depth < MAX_ARM_DEPTH:
			var node = galaxy_node.instance()
			node._type = NODE_TYPE.ARM
			var random_angle =  Global.rng.randf_range(-PI/MAX_ARM_DEPTH * (2.0/8.0) ,PI/MAX_ARM_DEPTH* (2.0/8.0))
			var angle = FINAL_ARM_ANGLE/MAX_ARM_DEPTH + random_angle
			node.position = position.normalized().rotated(angle)* SCALE * pow(1.0  + 2.0* float(depth)/float(MAX_ARM_DEPTH),3.0)
			# only the angle is random and not the length
			node.depth = depth+1
			node.galaxy_node = galaxy_node
			node.general_angle_shift = general_angle_shift
			node.arm_number =  arm_number
			add_child(node)
	# interpolation of node to keep omogenous density inside the arms
	if _type == NODE_TYPE.ARM || _type == NODE_TYPE.ARM_EXTENTION || _type == NODE_TYPE.ARM_INTERPOLATE_EXTENTION:
		if position.length() > MAX_DIST_NODE:
			var number_of_interpolate_node = floor(position.length() / MAX_DIST_NODE) as int
			for i in range(number_of_interpolate_node ):
				var node = galaxy_node.instance()
				if _type == NODE_TYPE.ARM:
					node._type = GalaxyNode.NODE_TYPE.ARM_INTERPOLATE
				elif _type == NODE_TYPE.ARM_EXTENTION:
					node._type = GalaxyNode.NODE_TYPE.ARM_EXTENTION_INTERPOLATE
				elif _type == NODE_TYPE.ARM_INTERPOLATE_EXTENTION:
					node._type = GalaxyNode.NODE_TYPE.ARM_EXTENTION_INTERPOLATE_ARM
				node.depth = depth+1
				node.galaxy_node = galaxy_node
				node.position =  - position * float(i) / float(number_of_interpolate_node)
				add_child(node)
	# systeme generation
	if _type != NODE_TYPE.SYSTEM:
		var number_of_system
		if _type == NODE_TYPE.ARM || _type == NODE_TYPE.ARM_EXTENTION:
			number_of_system = NUMBER_OF_SYSTEM_PER_NODE # * float(depth)/float(MAX_ARM_DEPTH) as int
		else:
			number_of_system = NUMBER_OF_SYSTEM_PER_NODE
		for i in range(NUMBER_OF_SYSTEM_PER_NODE):
			var node = galaxy_node.instance()
			node._type = GalaxyNode.NODE_TYPE.SYSTEM
			node.depth = depth+1
			node.galaxy_node = galaxy_node
			node.position =  Vector2(Global.rng.randf_range(-MAX_DIST_NODE,MAX_DIST_NODE),Global.rng.randf_range(-MAX_DIST_NODE,MAX_DIST_NODE)) 
			add_child(node)

func set_type(new_type):
	_type = new_type
	_modulate_color()

func _modulate_color():
	match _type :
		NODE_TYPE.ROOT, NODE_TYPE.CORE:
			$ColorRect.set_modulate(Color(1.0,0.0,1.0))
		NODE_TYPE.ARM, NODE_TYPE.ARM_INTERPOLATE:
			$ColorRect.set_modulate(Color(1.0,0,0))
		NODE_TYPE.ARM_EXTENTION, NODE_TYPE.ARM_EXTENTION_INTERPOLATE,NODE_TYPE.ARM_EXTENTION_INTERPOLATE_ARM,NODE_TYPE.ARM_INTERPOLATE_EXTENTION:
			$ColorRect.set_modulate(Color(0,1,0))
		NODE_TYPE.RANDOM_PLACEMENT:
			$ColorRect.set_modulate(Color(0,0,1))
		NODE_TYPE.LONER:
			$ColorRect.set_modulate(Color(1.0,1.0,0))
		NODE_TYPE.SYSTEM:
			$ColorRect.set_modulate(Color(1.0,1.0,1.0))
	
