extends Node

# This variable will store the path to the next level (e.g., Level 1, Level 2, or Level 3)
var next_scene_path: String = ""

# Optional: If you want to carry the player's score between islands
var current_score: int = 0

# Optional: If you want to track if the hint has already been used in previous levels
var hint_already_used: bool = false
