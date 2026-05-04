extends ParallaxBackground

# This controls how fast the background moves
@export var scroll_speed: float = 30.0

func _process(delta):
	# This line creates the continuous movement
	scroll_offset.x -= scroll_speed * delta
