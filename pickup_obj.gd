extends CharacterBody2D

@export var type : int = 0
@export var og_parent = null
@export var grabbed = false

func _ready():
	og_parent = get_parent()

func _physics_process(delta: float) -> void:
	if grabbed == false:
		velocity.y += 13.0
		move_and_slide()
