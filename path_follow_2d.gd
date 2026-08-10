extends PathFollow2D

@export var speed = 50

func _physics_process(delta: float) -> void:
	progress += speed*delta
