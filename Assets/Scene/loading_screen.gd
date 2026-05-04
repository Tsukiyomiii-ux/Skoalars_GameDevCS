extends CanvasLayer

# Updated path to the new ProgressBar node
@onready var progress_bar = $Bg/Holder/Loading 

func _ready():
	if progress_bar:
		progress_bar.value = 0
		# This ensures the percentage text is visible on the bar
		progress_bar.show_percentage = true 

func update_bar(value: float):
	if progress_bar:
		# ResourceLoader gives 0.0 to 1.0, so we multiply by 100
		progress_bar.value = value * 100
