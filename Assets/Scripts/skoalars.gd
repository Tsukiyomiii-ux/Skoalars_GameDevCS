extends CharacterBody2D

@export var walk_speed = 100.0

@onready var sprite = $AnimatedSprite2D

var last_direction = "down"

func _physics_process(delta):
	var direction: Vector2 = Vector2.ZERO
	
	# INPUT
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# PREVENT DIAGONAL SPEED BOOST
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# MOVEMENT
	velocity = direction * walk_speed
	move_and_slide()
	
	# ANIMATION
	update_animation(direction)

func update_animation(direction):
	if direction == Vector2.ZERO:
		sprite.play("idle_" + last_direction)
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.play("walk_right")
			last_direction = "right"
		else:
			sprite.play("walk_left")
			last_direction = "left"
	else:
		if direction.y > 0:
			sprite.play("walk_down")
			last_direction = "down"
		else:
			sprite.play("walk_up")
			last_direction = "up"
