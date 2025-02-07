extends CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animtree.active = true

# Variables
var move_speed = 10.0         # Movement speed
var turn_speed = 2.0         # Turn speed (degrees per frame)
var closeup =  3	# this specifies a threshold of how close model can be
var move_towards = Vector3.ZERO

# finish is a signal to process what happens after approach
var finish = "parameters/conditions/idle"

@onready var _spring_arm = $SpringArm3D
@onready var _model = $EnergyChan
@onready var animtree = $AnimationTree

func get_target_loc(radius: float, step_count: int, target: String):
	# utilizes "fractional" ray outcast to detect target.
	# will probably be replaced with a collider later
	var hits = []
	var center = self.global_transform.origin
	print(self.global_transform.origin.y)
	var fixed_y = 4
	
	for i in range(step_count):
		var angle = i * (2 * PI / step_count) 
		var direction = Vector3(
			center.x + radius * cos(angle), 
			fixed_y, 
			center.z + radius * sin(angle)
		)
		
		var ray_direction = direction - center
		var query = PhysicsRayQueryParameters3D.create(center, ray_direction)
		query.exclude = [self]

		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result:
			if result.collider and result.collider.name == target:
				print(result)
				return [result.collider, result.position]
	
	return hits

func exec(command: String, target: String):
	reset()
	print("Command: " + command)
	print("Target: " + target)
	
	if command == "walkto":
		var targets = get_target_loc(120, 32, target)
		if targets:
			move_towards = targets[1]
		finish = "parameters/conditions/idle"
		
	if command == "siton":
		var targets = get_target_loc(120, 32, target)
		if targets:
			move_towards = targets[1]
		finish = "parameters/conditions/sit_on"
	
	if command == "kneel":
		print("KNEELING!")
		move_towards = self.global_transform.origin
		finish = "parameters/conditions/kneel_on"

func get_direction_to(target_position: Vector3) -> Vector3:
	var current_position = self.global_transform.origin
	
	var direction_vector = target_position - current_position
	
	direction_vector = direction_vector.normalized()
	direction_vector.y = current_position.y

	return direction_vector

func get_xz_distance(vec1: Vector3) -> float:
	# this function gets the distance between self -> input
	# only using the x and y coordinates.
	var vec2 = self.global_transform.origin
	var vec1_xz = Vector2(vec1.x, vec1.z)
	var vec2_xz = Vector2(vec2.x, vec2.z)
	
	return vec1_xz.distance_to(vec2_xz)
	
# Called every frame
func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if ( get_xz_distance(move_towards) > closeup ):
		direction = get_direction_to(move_towards)
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if direction.length() > 0:
		# if target enable walk to it
		var target_y_rotation = atan2(direction.x, direction.z)  # Set Y rotation to face the movement direction
		rotation.y = lerp_angle(rotation.y, target_y_rotation, 15 * delta)
	move_and_slide()

func reset():
	# reset all actions
	animtree["parameters/conditions/idle"] = true
	animtree["parameters/conditions/reset"] = true
	animtree["parameters/conditions/sit_on"] = false
	animtree["parameters/conditions/kneel_on"] = false


func update_animParams():
	if (velocity == Vector3.ZERO):
		reset()
		animtree["parameters/conditions/is_walking"] = false
		animtree[finish] = true
		animtree["parameters/conditions/reset"] = false
	else:
		animtree["parameters/conditions/is_walking"] = true
		animtree["parameters/conditions/idle"] = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_animParams()
