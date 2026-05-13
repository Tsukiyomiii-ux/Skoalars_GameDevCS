extends Node

# Currency
var diamonds: int = 5
var loading_screen_scene = preload("res://Assets/Scene/loading_screen.tscn")
var loading_instance
var target_path : String
var progress = []
var wand_used = false
var cutscene_played: bool = false
var tutorial_completed: bool = false
var completed_topics: Array = []

# 📚 STUDY SESSION PROGRESS
var study_progress = {
	"literacy": {"completed": 0, "total": 6},
	"math": {"completed": 0, "total": 4},
	"science": {"completed": 0, "total": 6},
	"geography": {"completed": 0, "total": 4},
}

# 📝 STUDY SESSION ANSWERS (Centralized)
var study_answers = {
	"plant_lesson":     {"answer1": "", "answer2": ""},
	"plant_functions":  {"answer1": "", "answer2": ""},
	"ecosystem":        {"answer1": "", "answer2": ""},
	"bio_waste":        {"answer1": "", "answer2": ""},
	"non_bio_waste":    {"answer1": "", "answer2": ""},
	"recyclable_waste": {"answer1": "", "answer2": ""},
	"addition":         {"answer1": "", "answer2": ""},
	"subtraction":      {"answer1": "", "answer2": ""},
	"multiplication":   {"answer1": "", "answer2": ""},
	"division":         {"answer1": "", "answer2": ""},
	"flags":            {"answer1": "", "answer2": ""},
	"capitals":         {"answer1": "", "answer2": ""},
	"continents":       {"answer1": "", "answer2": ""},
	"tectonic":         {"answer1": "", "answer2": ""},
	"literacy_noun":        {"answer1": "", "answer2": ""},
	"literacy_adjective":   {"answer1": "", "answer2": ""},
	"literacy_pronouns":    {"answer1": "", "answer2": ""},
	"literacy_verb":        {"answer1": "", "answer2": ""},
	"literacy_adverb":      {"answer1": "", "answer2": ""},
	"literacy_conjunction": {"answer1": "", "answer2": ""},
}

# 🎁 ISLAND REWARDS
const ISLAND_REWARDS = {
	"island_1": {"diamonds": 5, "skill_uses": {"hint": 1, "freeze_time": 0, "add_time": 0, "skip": 0}},
	"island_1.5": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 0}},
	"island_2": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 1, "add_time": 0, "skip": 0}},
	"island_2.5": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 0}},
	"island_3": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 1}},
	"island_3.5": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 0}},
	"island_4": {"diamonds": 5, "skill_uses": {"hint": 1, "freeze_time": 0, "add_time": 0, "skip": 0}},
	"island_4.5": {"diamonds": 5, "skill_uses": {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 0}},
}

# 🏝️ Island Progress
var island_progress = {
	"island_1": {"minigames_completed": 0, "total_minigames": 2},
	"island_2": {"minigames_completed": 0, "total_minigames": 2},
	"island_3": {"minigames_completed": 0, "total_minigames": 2},
	"island_4": {"minigames_completed": 0, "total_minigames": 2},
}

const SKILL_COOLDOWNS = {
	"hint": 60.0,
	"freeze_time": 60.0,
	"add_time": 60.0,
	"skip": 60.0
}
var skill_cooldowns = {
	"hint": 0.0,
	"freeze_time": 0.0,
	"add_time": 0.0,
	"skip": 0.0
}

# Skills
var skills = {
	"hint": true,
	"freeze_time": false,
	"add_time": false,
	"skip": false
}

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

var skills_equipped = {
	"hint": false,
	"freeze_time": false,
	"add_time": false,
	"skip": false
}

# 🛒 SHOP COOLDOWN (persisted so it survives scene changes)
var shop_last_bought = {
	"hint": 0,
	"freeze_time": 0,
	"add_time": 0,
	"skip": 0
}

# Island unlocks
var islands_unlocked = {
	"island_1": true,
	"island_2": false,
	"island_3": false,
	"island_4": false,
}

var next_scene_path: String = ""
var current_score: int = 0
var hint_already_used: bool = false
var allowed_skills: Array = ["hint", "freeze_time", "add_time", "skip"]

# Signals
signal diamonds_changed(new_amount)
signal skill_purchased(skill_name)
signal island_unlocked(island_name)
signal reward_received(island_name)
signal hint_requested
signal freeze_requested
signal add_time_requested
signal skip_requested
signal skill_used(skill_name)
signal skill_button_state_changed(skill_name, is_disabled)
signal settings_opened
signal settings_closed

var island_rewards_collected = {
	"island_1": false,
	"island_1.5": false,
	"island_2": false,
	"island_2.5": false,
	"island_3": false,
	"island_3.5": false,
	"island_4": false,
	"island_4.5": false,
}

func collect_island_reward(island_name: String):
	receive_island_reward(island_name)
	island_rewards_collected[island_name] = true
	save_game()
	print("🏆 Reward collected and island locked: ", island_name)

func is_island_done(island_name: String) -> bool:
	var minigames_done = is_island_complete(island_name)
	var reward_done = island_rewards_collected.get(island_name, false)
	return minigames_done and reward_done

func set_allowed_skills(skills_list: Array):
	allowed_skills = skills_list
	update_skill_button_states()

func update_skill_button_states():
	print("🔍 allowed_skills: ", allowed_skills)
	for skill_name in skill_uses:
		var not_allowed = skill_name not in allowed_skills
		var on_cooldown = is_skill_on_cooldown(skill_name)
		var should_disable = not_allowed or not is_skill_equipped(skill_name) or skill_uses[skill_name] <= 0
		print("  ", skill_name, " | not_allowed: ", not_allowed, " | should_disable: ", should_disable)
		skill_button_state_changed.emit(skill_name, should_disable)

func load_scene(path: String):
	target_path = path
	loading_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_instance)
	ResourceLoader.load_threaded_request(path)

func _process(delta):
	if target_path != "":
		var status = ResourceLoader.load_threaded_get_status(target_path, progress)
		if loading_instance:
			loading_instance.update_bar(progress[0])
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var new_scene = ResourceLoader.load_threaded_get(target_path)
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_packed(new_scene)
			loading_instance.queue_free()
			target_path = ""

	var any_changed = false
	for skill in skill_cooldowns:
		if skill_cooldowns[skill] > 0.0:
			skill_cooldowns[skill] -= delta
			if skill_cooldowns[skill] <= 0.0:
				skill_cooldowns[skill] = 0.0
				any_changed = true
	if any_changed:
		update_skill_button_states()

func is_skill_on_cooldown(skill_name: String) -> bool:
	return skill_cooldowns.get(skill_name, 0.0) > 0.0

func get_skill_cooldown_remaining(skill_name: String) -> float:
	return skill_cooldowns.get(skill_name, 0.0)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
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

func use_skill(skill_name: String) -> bool:
	if not is_skill_equipped(skill_name):
		print("❌ ", skill_name, " is not equipped!")
		return false
	if skill_uses[skill_name] <= 0:
		print("❌ ", skill_name, " has no uses left!")
		return false

	skill_uses[skill_name] -= 1
	skill_cooldowns[skill_name] = SKILL_COOLDOWNS[skill_name]
	save_game()
	print("✅ Used ", skill_name, " | Remaining: ", skill_uses[skill_name])

	match skill_name:
		"hint":
			hint_requested.emit()
		"freeze_time":
			freeze_requested.emit()
		"add_time":
			add_time_requested.emit()
		"skip":
			skip_requested.emit()

	skill_used.emit(skill_name)
	update_skill_button_states()
	return true

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

# 📚 STUDY PROGRESS FUNCTIONS
func complete_study_topic(subject: String, topic_key: String):
	if topic_key in completed_topics:
		return
	completed_topics.append(topic_key)
	if not study_progress.has(subject): return
	var s = study_progress[subject]
	if s["completed"] < s["total"]:
		s["completed"] += 1
		save_game()
		print("📚 ", subject, " - ", topic_key, " completed: ", s["completed"], "/", s["total"])

func get_study_progress(subject: String) -> float:
	if not study_progress.has(subject): return 0.0
	var s = study_progress[subject]
	return float(s["completed"]) / float(s["total"])

func save_study_answer(topic: String, field: String, value: String):
	if study_answers.has(topic):
		study_answers[topic][field] = value
		save_game()

func get_study_answer(topic: String, field: String) -> String:
	if study_answers.has(topic):
		return study_answers[topic].get(field, "")
	return ""

func reset_study_answers():
	for topic in study_answers:
		study_answers[topic]["answer1"] = ""
		study_answers[topic]["answer2"] = ""
	save_game()
	print("🗑️ Cleared all study answers")

# 📊 ISLAND PROGRESS FUNCTIONS
func complete_minigame(island_name: String):
	if not island_progress.has(island_name):
		return
	var island = island_progress[island_name]
	if island["minigames_completed"] >= island["total_minigames"]:
		return
	island["minigames_completed"] += 1
	print("✅ ", island_name, " progress: ", island["minigames_completed"], "/", island["total_minigames"])
	save_game()

func get_island_progress(island_name: String) -> float:
	if not island_progress.has(island_name):
		return 0.0
	var island = island_progress[island_name]
	return float(island["minigames_completed"]) / float(island["total_minigames"])

func is_island_complete(island_name: String) -> bool:
	if not island_progress.has(island_name):
		return false
	var island = island_progress[island_name]
	return island["minigames_completed"] >= island["total_minigames"]

# 🎁 REWARD FUNCTIONS
func receive_island_reward(island_name: String):
	if not ISLAND_REWARDS.has(island_name):
		return
	var rewards = ISLAND_REWARDS[island_name]
	add_diamonds(rewards["diamonds"])
	print("💎 +", rewards["diamonds"], " diamonds!")
	for skill in rewards["skill_uses"]:
		var amount = rewards["skill_uses"][skill]
		if amount > 0:
			skill_uses[skill] += amount
			skills[skill] = true
			print("🎁 +", amount, " ", skill, " uses!")
	reward_received.emit(island_name)
	save_game()

var persistent_cleanup_nodes: Array = []

func register_cleanup_node(node: Node):
	persistent_cleanup_nodes.append(node)

func cleanup_persistent_nodes():
	for node in persistent_cleanup_nodes:
		if is_instance_valid(node):
			node.queue_free()
	persistent_cleanup_nodes.clear()

# 💾 SAVE/LOAD
func save_game():
	var save_data = {
		"diamonds": diamonds,
		"skills": skills,
		"skill_uses": skill_uses,
		"skills_equipped": skills_equipped,
		"islands_unlocked": islands_unlocked,
		"island_progress": island_progress,
		"study_progress": study_progress,
		"study_answers": study_answers,
		"cutscene_played": cutscene_played,
		"tutorial_completed": tutorial_completed,
		"island_rewards_collected": island_rewards_collected,
		"completed_topics": completed_topics,
		"shop_last_bought": shop_last_bought,
	}
	var file = FileAccess.open("user://game_save.json", FileAccess.WRITE)
	if file == null:
		print("❌ SAVE FAILED! Error: ", FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("💾 Saved to: ", ProjectSettings.globalize_path("user://game_save.json"))

func load_game():
	if not FileAccess.file_exists("user://game_save.json"):
		print("❌ NO SAVE FILE FOUND — starting fresh")
		return
	print("✅ Save file found, loading...")
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
		island_progress = data.get("island_progress", island_progress)
		tutorial_completed = data.get("tutorial_completed", false)
		study_progress = data.get("study_progress", study_progress)
		island_rewards_collected = data.get("island_rewards_collected", island_rewards_collected)
		completed_topics = data.get("completed_topics", [])
		shop_last_bought = data.get("shop_last_bought", shop_last_bought)
		var loaded_answers = data.get("study_answers", {})
		for key in loaded_answers:
			if study_answers.has(key):
				study_answers[key] = loaded_answers[key]
		cutscene_played = data.get("cutscene_played", false)
		diamonds_changed.emit(diamonds)
		print("💾 Loaded: ", diamonds, " diamonds, uses: ", skill_uses)

func reset_game():
	completed_topics = []
	diamonds = 5
	skills = {"hint": true, "freeze_time": false, "add_time": false, "skip": false}
	skill_uses = {"hint": 1, "freeze_time": 0, "add_time": 0, "skip": 0}
	skills_equipped = {"hint": false, "freeze_time": false, "add_time": false, "skip": false}
	islands_unlocked = {"island_1": true, "island_2": false, "island_3": false, "island_4": false}
	island_progress = {
		"island_1": {"minigames_completed": 0, "total_minigames": 2},
		"island_2": {"minigames_completed": 0, "total_minigames": 2},
		"island_3": {"minigames_completed": 0, "total_minigames": 2},
		"island_4": {"minigames_completed": 0, "total_minigames": 2},
	}
	island_rewards_collected = {
		"island_1": false, "island_1.5": false,
		"island_2": false, "island_2.5": false,
		"island_3": false, "island_3.5": false,
		"island_4": false, "island_4.5": false,
	}
	shop_last_bought = {"hint": 0, "freeze_time": 0, "add_time": 0, "skip": 0}  # ← reset shop cooldown
	study_progress = {
		"literacy": {"completed": 0, "total": 6},
		"math": {"completed": 0, "total": 4},
		"science": {"completed": 0, "total": 6},
		"geography": {"completed": 0, "total": 5},
	}
	current_island = "island_1"
	wand_used = false
	cutscene_played = false
	tutorial_completed = false
	reset_study_answers()
	diamonds_changed.emit(diamonds)
	save_game()
