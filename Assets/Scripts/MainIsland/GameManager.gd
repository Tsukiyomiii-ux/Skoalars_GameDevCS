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

var skill_uses = {
	"hint": 1,
	"freeze_time": 0,
	"add_time": 0,
	"skip": 0
}

# Skills equipped
var skills_equipped = {
	"hint": false,
	"freeze_time": false,
	"add_time": false,
	"skip": false
}

# Island unlocks
var islands_unlocked = {
	"island_1": true,
	"island_2": false,
	"island_3": false,
	"island_4": false,
}

# Signals
signal diamonds_changed(new_amount)
signal skill_purchased(skill_name)
signal island_unlocked(island_name)

func _ready():
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
		skill_uses[skill_name] += 1
		skill_purchased.emit(skill_name)
		print("✅ ", skill_name, " uses: ", skill_uses[skill_name])
		return true
	return false

func has_skill(skill_name: String) -> bool:
	return skills.get(skill_name, false)

func get_skill_status(skill_name: String) -> String:
	return "Owned" if has_skill(skill_name) else str(SKILL_COSTS.get(skill_name, 0))

func get_skill_uses(skill_name: String) -> int:
	return skill_uses.get(skill_name, 0)

func get_skill_cost(skill_name: String) -> int:
	return SKILL_COSTS.get(skill_name, 0)

# 🎒 EQUIP FUNCTIONS
func equip_skill(skill_name: String):
	if has_skill(skill_name):
		skills_equipped[skill_name] = not skills_equipped[skill_name]
		save_game()
		print("🎒 ", skill_name, " equipped: ", skills_equipped[skill_name])

func is_skill_equipped(skill_name: String) -> bool:
	return skills_equipped.get(skill_name, false)

# 🏝️ ISLAND FUNCTIONS
func unlock_island(island_name: String):
	if islands_unlocked.has(island_name):
		islands_unlocked[island_name] = true
		island_unlocked.emit(island_name)
		save_game()
		print("🏝️ Unlocked: ", island_name)

func is_island_unlocked(island_name: String) -> bool:
	return islands_unlocked.get(island_name, false)

var current_island: String = "island_1"

func set_current_island(island_name: String):
	current_island = island_name

func get_current_island() -> String:
	return current_island

# 💾 SAVE/LOAD
func save_game():
	var save_data = {
		"diamonds": diamonds,
		"skills": skills,
		"skill_uses": skill_uses,
		"skills_equipped": skills_equipped,
		"islands_unlocked": islands_unlocked
	}
	var file = FileAccess.open("user://game_save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("💾 Saved!")

func load_game():
	if FileAccess.file_exists("user://game_save.json"):
		var file = FileAccess.open("user://game_save.json", FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			diamonds = data.get("diamonds", 5)
			skills = data.get("skills", skills)
			skill_uses = data.get("skill_uses", skill_uses)
			skills_equipped = data.get("skills_equipped", skills_equipped)
			islands_unlocked = data.get("islands_unlocked", islands_unlocked)
			diamonds_changed.emit(diamonds)
			print("💾 Loaded: ", diamonds, " diamonds, uses: ", skill_uses)

func reset_game():
	diamonds = 5
	skills = {"hint": false, "freeze_time": false, "add_time": false, "skip": false}
	skill_uses = {"hint": 1, "freeze_time": 0, "add_time": 0, "skip": 0}
	skills_equipped = {"hint": false, "freeze_time": false, "add_time": false, "skip": false}
	islands_unlocked = {"island_1": true, "island_2": false, "island_3": false, "island_4": false}
	save_game()
