extends CharacterBody2D

@export var walk_speed = 100.0

func _physics_process(delta):
	var direction: Vector2 = Vector2.ZERO
	
	#Input controls
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#prevent diagonal speeding
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	#apply the movement 
	velocity = direction * walk_speed
	move_and_slide()
