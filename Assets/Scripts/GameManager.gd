extends Node

# Currency
var diamonds: int = 5

# Skills (false = not owned)
var skills = {
	"hint": false,
	"freeze_time": false,
	"add_time": false,
	"skip": false
}

# Skill costs
const SKILL_COSTS = {
	"hint": 10,
	"freeze_time": 18,
	"add_time": 15,
	"skip": 25
}

# Add this dictionary
var skill_uses = {
	"hint": 1,
	"freeze_time": 0,
	"add_time": 0,
	"skip": 0
}

signal diamonds_changed(new_amount)
signal skill_purchased(skill_name)

func _ready():
	#this line resets the diamond into 5 only
	#print("FORCE RESET!")
	#GameManager.diamonds = 5
	#var dir = DirAccess.open("user://")
	#if dir.file_exists("game_save.json"):
		#dir.remove("game_save.json")
		#print("🗑️ Save deleted!")
	#GameManager.save_game()
	#print("💎 FORCED to 5!")
	load_game()

# 💎 DIAMOND FUNCTIONS
func add_diamonds(amount: int):
	diamonds += amount
	diamonds_changed.emit(diamonds)
	save_game()
	print("💎 +", amount, " Diamonds: ", diamonds)

func spend_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
		diamonds_changed.emit(diamonds)
		save_game()
		return true
	return false

func get_diamonds() -> int:
	return diamonds

# 🛒 SKILL FUNCTIONS
func buy_skill(skill_name: String) -> bool:
	if not SKILL_COSTS.has(skill_name):
		return false
	
	var cost = SKILL_COSTS[skill_name]
	if spend_diamonds(cost):
		skills[skill_name] = true
		skill_uses[skill_name] += 1  # ← INCREASES EVERY BUY!
		skill_purchased.emit(skill_name)
		print("✅ ", skill_name, " uses: ", skill_uses[skill_name])
		return true
	return false

func has_skill(skill_name: String) -> bool:
	return skills.get(skill_name, false)

func get_skill_status(skill_name: String) -> String:
	return "Owned" if has_skill(skill_name) else str(SKILL_COSTS.get(skill_name, 0))
# Add these TWO functions to your GameManager (end of file):

func get_skill_uses(skill_name: String) -> int:
	return skill_uses.get(skill_name, 0)  # Now shows actual count!

func get_skill_cost(skill_name: String) -> int:
	return SKILL_COSTS.get(skill_name, 0)



# 💾 SAVE/LOAD
func save_game():
	var save_data = {
		"diamonds": diamonds,
		"skills": skills,
		"skill_uses": skill_uses  # Save uses!
	}
	# ... rest unchanged

func load_game():
	if FileAccess.file_exists("user://game_save.json"):
		var file = FileAccess.open("user://game_save.json", FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data  # ← DECLARE 'data' here!
			diamonds = data.get("diamonds", 100)
			skills = data.get("skills", skills)
			skill_uses = data.get("skill_uses", skill_uses)  # Load uses!
			diamonds_changed.emit(diamonds)
			print("💾 Loaded: ", diamonds, " diamonds, uses: ", skill_uses)

func reset_game():
	diamonds = 100
	skills = {"hint": false, "freeze_time": false, "add_time": false, "skip": false}
	save_game()
