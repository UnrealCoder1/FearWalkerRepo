extends CharacterBody2D

const GRAVITY = 13.0

var acceleration = 10.0
var deacceleration = 15.0
var walk_speed : float = 230.0
var initial_jump_power : float = 220.0
var inc_jump_power : float = 9.0

var in_air_stamina : float = 100.0
var jumped = false
var kayote_frames : int = 0

var orig_container : Node = null
var cur_platform : StaticBody2D = null

var selected_pickup : CharacterBody2D = null
var cur_inhand : CharacterBody2D = null

@onready var platform_area = $PlatformCheckArea

func _ready():
	orig_container = get_parent()

func _physics_process(delta: float) -> void:
	##Horizontal movement and mommentum
	var move_axis : float = Input.get_axis("ui_left","ui_right")
	
	velocity.x = clamp( #acceleration
		velocity.x + move_axis*acceleration,
		-walk_speed,
		walk_speed
	)
	if move_axis == 0.0: #deacceleration
		velocity.x += clamp(0.0-velocity.x,-deacceleration,deacceleration)
	
	##Jumping
	if is_on_floor():
		kayote_frames = 7
		jumped = false
		in_air_stamina = 100.0
	else:
		kayote_frames -= 1
	if kayote_frames > 0 and Input.is_action_just_pressed("jump"):
		jumped = true
		velocity.y -= initial_jump_power + (abs(velocity.x/3)) 
		kayote_frames = 0
	else:
		if Input.is_action_pressed("jump") and in_air_stamina > 0.0 and jumped == true:
			in_air_stamina -= 3.0
			velocity.y -= inc_jump_power * (in_air_stamina/100.0)
		else:
			jumped = false
	
	##Applying gravity
	velocity.y += GRAVITY
	
	##Apply physics
	move_and_slide()
	
	##Picking up objects
	if Input.is_action_just_pressed("pickup") and selected_pickup:
		selected_pickup.find_child("PickupShape").disabled = true
		selected_pickup.grabbed = true
		cur_inhand = selected_pickup
		selected_pickup = null


##Moving platform parenting and getting pick-uppable object
func _on_platform_check_area_body_entered(body: Node2D) -> void:
	if body.find_child("PlatformShape"):
		var pos = global_position
		cur_platform = body
		orig_container.remove_child(self)
		cur_platform.add_child(self)
		global_position = pos
	
	if body.find_child("PickupShape"):
		selected_pickup = body

func _on_platform_check_area_body_exited(body: Node2D) -> void:
	if body == cur_platform:
		var pos = global_position
		cur_platform.remove_child(self)
		orig_container.add_child(self)
		cur_platform = null
		global_position = pos
	
	if body == selected_pickup:
		selected_pickup = null
