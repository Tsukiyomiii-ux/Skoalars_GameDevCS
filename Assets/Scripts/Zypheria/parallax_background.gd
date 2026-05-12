extends ParallaxBackground

@export var scroll_speed: float = 30.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # ✅ Add this

func _process(delta):
	scroll_offset.x -= scroll_speed * delta
