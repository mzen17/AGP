extends CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animtree.active = true



# Variables
var move_speed = 10.0         # Movement speed
var turn_speed = 2.0         # Turn speed (degrees per frame)

var _velocity = Vector3.ZERO

@onready var _spring_arm = $SpringArm3D
@onready var _model = $EnergyChan
@onready var animtree = $AnimationTree

# Called every frame
func _physics_process(delta):
	var direction = Vector3.ZERO
	
	direction.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	direction.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	if direction.length() > 0:
		direction = direction.normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if direction.length() > 0:
		var target_rotation = direction.angle_to(Vector3.FORWARD)  # Get angle to forward direction
		var target_y_rotation = atan2(direction.x, direction.z)  # Set Y rotation to face the movement direction
		rotation.y = lerp_angle(rotation.y, target_y_rotation, 15 * delta)
	move_and_slide()


func update_animParams():
	if (velocity == Vector3.ZERO):
		animtree["parameters/conditions/is_walking"] = false
		animtree["parameters/conditions/idle"] = true
	else:
		animtree["parameters/conditions/is_walking"] = true
		animtree["parameters/conditions/idle"] = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_animParams()
	print(animtree.animation_player_changed)
