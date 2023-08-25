extends Node

class CharacterStats:
	var name
	var characters:Dictionary
	
	
	func update_value(char_id:String, stat:String, value):
		characters[char_id][stat] = value
	
	
	func inc_value(char_id:String, stat:String):
		var c = characters[char_id]
		if c.has(stat):
			c[stat] += 1
		else:
			c[stat] = 1
	
	
	func get_value(char_id:String, stat:String, default):
		var c = characters.get(char_id, null)
		if !c:
			return default
		return c.get(stat, default)
	
	
	func save(path:String):
		var d = Directory.new()
		if !d.dir_exists(path):
			d.make_dir_recursive(path)
		
		var file:File = File.new()
		var err = file.open(path + "/" + name, File.WRITE)
		if err != OK:
			return
		file.store_var(characters, true)
		file.close()
	
	
	func load(path:String):
		var file:File = File.new()
		if file.file_exists(path + "/" + name):
			var err = file.open(path + "/" + name, File.READ)
			if err != OK:
				return
			characters = file.get_var(true)
			file.close()


const tracked_items:Dictionary = {
	"character_bull":"DAMAGE_DONE",
	"character_glutton":"DAMAGE_DONE",
	"character_lich":"DAMAGE_DONE",
	"character_lucky":"DAMAGE_DONE",
	"item_adrenaline":"HP_HEALED",
	"item_alien_eyes":"DAMAGE_DONE",
	"item_baby_elephant":"DAMAGE_DONE",
	"item_baby_with_a_beard":"DAMAGE_DONE",
	"item_bag":"MATERIALS_GAINED",
	"item_cute_monkey":"HP_HEALED",
	"item_cyberball":"DAMAGE_DONE",
	"item_giant_belt":"DAMAGE_DONE",
	"item_hunting_trophy":"MATERIALS_GAINED",
	"item_landmines":"DAMAGE_DONE",
	"item_metal_detector":"MATERIALS_GAINED",
	"item_piggy_bank":"MATERIALS_GAINED",
	"item_pocket_factory":"DAMAGE_DONE",
	"item_recycling_machine":"MATERIALS_GAINED",
	"item_rip_and_tear":"DAMAGE_DONE",
	"item_riposte":"DAMAGE_DONE",
	"item_scared_sausage":"DAMAGE_DONE",
	"item_spicy_sauce":"DAMAGE_DONE",
	"item_tentacle":"HP_HEALED",
	"item_turret":"DAMAGE_DONE",
	"item_turret_flame":"DAMAGE_DONE",
	"item_turret_healing":"HP_HEALED",
	"item_turret_laser":"DAMAGE_DONE",
	"item_turret_rocket":"DAMAGE_DONE",
	"item_tyler":"DAMAGE_DONE",
}

onready var tooltiptracking = get_tree().get_root().get_node("ModLoader/meinfesl-TooltipTrackingFix")

var wave_stats:Dictionary
var run_stats:Dictionary
var run_stats_saved = null

var mod_state:Dictionary

var character_stats_normal = []
var character_stats_endless = []

var heal_source = ""
var materials_source = ""

var levelup:bool = false

var combining_weapons = false
var combining_weapons_damage = 0

var exploding_weapon = null

var sausage = false
var run_in_progress = false
var wave_in_progress = false
var last_time = -1

var waiting_for_damage_source = false
var damage_source = ""


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	for i in ProgressData.MAX_DIFFICULTY + 1:
		var data = CharacterStats.new()
		data.name = "normal_d" + str(i)
		character_stats_normal.push_back(data)
		
		data = CharacterStats.new()
		data.name = "endless_d" + str(i)
		character_stats_endless.push_back(data)


func _process(_delta):
	var time_now = Time.get_ticks_msec()
	var diff = time_now - last_time
	last_time = time_now
	
	waiting_for_damage_source = false
	
	if run_in_progress:
		run_stats["RUN_TIME"] += diff
		if wave_in_progress:
			wave_stats["TIME"] += diff


func reset():
	last_time = -1
	run_stats = init_stats_container()
	wave_stats = init_wave_stats_container()


func on_wave_started():
	if last_time == -1:
		last_time = Time.get_ticks_msec()
	run_in_progress = true
	wave_in_progress = true
	wave_stats = init_wave_stats_container()


func on_game_paused():
	run_in_progress = false


func on_game_unpaused():
	run_in_progress = true


func on_enemy_spawned(enemy):
	if enemy.stats.always_drop_consumables:
		if enemy.stats.value == 8:
			run_stats["SPAWNED_LOOT_ALIENS"] += 1


func on_enemy_damage_taken(damage:Array, hitbox:Hitbox):
	run_stats["DAMAGE_DONE_OVERKILL"] += damage[0]
	run_stats["DAMAGE_DONE"] += damage[1]
	
	if run_stats["MAX_DAMAGE"] < damage[0]:
		run_stats["MAX_DAMAGE"] = damage[0]
		
		if hitbox && hitbox.from:
			if is_instance_valid(hitbox.from) && hitbox.from.weapon_pos < RunData.weapons.size():
				run_stats["MAX_DAMAGE_SOURCE"] = RunData.weapons[hitbox.from.weapon_pos].my_id
		elif hitbox && hitbox.damage_tracking_key != "":
			run_stats["MAX_DAMAGE_SOURCE"] = hitbox.damage_tracking_key
		elif damage_source != "":
			run_stats["MAX_DAMAGE_SOURCE"] = damage_source
		elif tooltiptracking && tooltiptracking.damage_tracking_key != "":
			run_stats["MAX_DAMAGE_SOURCE"] = tooltiptracking.damage_tracking_key
		else:
			waiting_for_damage_source = true
			run_stats["MAX_DAMAGE_SOURCE"] = ""
		
		if RunData.current_character:
			if RunData.current_character.my_id == "character_lucky":
				if run_stats["MAX_DAMAGE_SOURCE"] == "item_baby_elephant":
					run_stats["MAX_DAMAGE_SOURCE"] = "character_lucky"
	
	damage_source = ""


func on_player_damage_taken(player, base_damage, damage_taken:Array, hitbox):
	# Damage into i-frame, wounderfull isn't it?
	if damage_taken.size() != 3:
		return
	
	if damage_taken[2]:
		run_stats["HITS_DODGED"] += 1
	else:
		run_stats["DAMAGE_TAKEN"] += damage_taken[1]
		if hitbox:
			run_stats["HITS_TAKEN"] += 1
			var after_armor = player.get_dmg_value(base_damage)
			if after_armor == damage_taken[1]:
				run_stats["DAMAGE_TAKEN_ARMOR"] += base_damage - damage_taken[1]
		else:
			run_stats["DAMAGE_TAKEN_SELF"] += damage_taken[1]


func on_weapon_damage(pos, damage):
	if sausage:
		return
		
	run_stats["DAMAGE_DONE_WEAPONS"] += damage
	# Can happen on cleanup
	if pos < run_stats["DAMAGE_BY_WEAPON"].size():
		run_stats["DAMAGE_BY_WEAPON"][pos] += damage
		if waiting_for_damage_source:
			run_stats["MAX_DAMAGE_SOURCE"] = RunData.weapons[pos].my_id
			waiting_for_damage_source = false


func on_weapon_added(_weapon):
	if combining_weapons:
		run_stats["DAMAGE_BY_WEAPON"].push_back(combining_weapons_damage)
		combining_weapons_damage = 0
	else:
		run_stats["DAMAGE_BY_WEAPON"].push_back(0)


func on_weapon_removed(weapon):
	for i in RunData.weapons.size():
		var current_weapon = RunData.weapons[i]
		if current_weapon.my_id == weapon.my_id:
			if combining_weapons:
				combining_weapons_damage += run_stats["DAMAGE_BY_WEAPON"][i]
			run_stats["DAMAGE_BY_WEAPON"].remove(i)
			break


func remove_all_weapons()->void:
	run_stats["DAMAGE_BY_WEAPON"].clear()


func on_enemy_killed(enemy):
	run_stats["KILLS_ENEMIES"] += 1
	if enemy.stats.always_drop_consumables:
		if enemy.stats.value == 8:
			run_stats["KILLS_LOOT_ALIENS"] += 1
		elif RunData.current_wave == RunData.nb_of_waves:
			wave_stats["BOSSES_KILLED"] += 1
		else:
			run_stats["KILLS_ELITES"] += 1


func on_tree_killed():
	run_stats["KILLS_TREES"] += 1


func on_player_healed(value:int):
	if levelup:
		return
		
	run_stats["HP_HEALED"] += value
	if heal_source != "":
		run_stats[heal_source] += value


func on_materials_gained(value):
	if value < 0:
		run_stats["MATERIALS_SPENT"] += abs(value)
	else:
		run_stats["MATERIALS_GAINED"] += value
		if materials_source != "":
			run_stats[materials_source] += value


func on_materials_spent(value):
	run_stats["MATERIALS_SPENT"] += value
	if materials_source != "":
		run_stats[materials_source] += value


func on_materials_gained_from_weapon_crit():
	run_stats["MATERIALS_GAINED_WEAPON_CRIT"] += 1


func on_shop_items_updated(item_count:int):
	run_stats["SHOP_ITEMS_BROWSED"] += item_count


func on_item_box_picked_up():
	run_stats["LOOT_BOXES"] += 1
	wave_stats["LOOT_BOXES"] += 1

func on_loot_box_taken():
	run_stats["LOOT_BOXES_TAKEN"] += 1


func on_loot_box_discarded():
	run_stats["LOOT_BOXES_DISCARDED"] += 1


func get_percent_text_for_item(item)->String:
	if !tracked_items.has(item.my_id):
		return ""
		
	if !RunData.tracked_item_effects.has(item.my_id):
		return ""
		
	var total = run_stats[tracked_items[item.my_id]]
	var value = RunData.tracked_item_effects[item.my_id]
	var pct = 0.0
	if total:
		pct = value * 100.0 / total
	return " (%.2f%%)" % pct


func update_loot_box_count():
	var char_id = RunData.current_character.my_id
	var stats
	if RunData.is_endless_run:
		stats = character_stats_endless[RunData.get_current_difficulty()]
	else:
		stats = character_stats_normal[RunData.get_current_difficulty()]
	
	if stats.get_value(char_id, "LOOT_BOXES_IN_A_SINGLE_WAVE", 0) < wave_stats["LOOT_BOXES"]:
		stats.update_value(char_id, "LOOT_BOXES_IN_A_SINGLE_WAVE", wave_stats["LOOT_BOXES"])


func on_room_clean_up(is_run_lost:bool, is_run_won:bool):
	wave_in_progress = false
	var stats
	if RunData.is_endless_run:
		stats = character_stats_endless[RunData.get_current_difficulty()]
	else:
		stats = character_stats_normal[RunData.get_current_difficulty()]
	
	update_character_stats(stats, is_run_lost, is_run_won)


func update_character_stats(stats:CharacterStats, is_run_lost:bool, is_run_won:bool):
	var char_id = RunData.current_character.my_id
	
	if !stats.characters.has(char_id):
		stats.characters[char_id] = init_character_stats()
	
	if stats.get_value(char_id, "MAX_DAMAGE", 0) < run_stats["MAX_DAMAGE"]:
		stats.update_value(char_id, "MAX_DAMAGE", run_stats["MAX_DAMAGE"])
		stats.update_value(char_id, "MAX_DAMAGE_SOURCE", run_stats["MAX_DAMAGE_SOURCE"])
	
	var stats_to_cmp = ["DAMAGE_DONE", "DAMAGE_DONE_OVERKILL", "HP_HEALED",
		"MATERIALS_GAINED", "KILLS_ENEMIES", "LOOT_BOXES"]
	
	for stat in stats_to_cmp:
		if stats.get_value(char_id, stat, 0) < run_stats[stat]:
			stats.update_value(char_id, stat, run_stats[stat])
	
	var char_stats = [
		"stat_max_hp",
		"stat_hp_regeneration",
		"stat_lifesteal",
		"stat_percent_damage",
		"stat_melee_damage",
		"stat_ranged_damage",
		"stat_elemental_damage",
		"stat_attack_speed",
		"stat_crit_chance",
		"stat_engineering",
		"stat_range",
		"stat_armor",
		"stat_dodge",
		"stat_speed",
		"stat_luck",
		"stat_harvesting",
	]
	
	for stat in char_stats:
		if stats.get_value(char_id, stat.to_upper(), 0) < Utils.get_stat(stat):
			stats.update_value(char_id, stat.to_upper(), Utils.get_stat(stat))
	
	if stats.get_value(char_id, "LEVEL", 0) < RunData.current_level:
		stats.update_value(char_id, "LEVEL", RunData.current_level)
	
	if stats.get_value(char_id, "ITEMS_OWNED", 0) < RunData.items.size():
		stats.update_value(char_id, "ITEMS_OWNED", RunData.items.size())
	
	if is_run_lost || is_run_won:
		run_in_progress = false
		if wave_stats["BOSSES_KILLED"] == 2:
			stats.update_value(char_id, "D5_BOSSES_KILLED", 1)
		stats.inc_value(char_id, "GAMES_PLAYED")
		if is_run_won:
			stats.inc_value(char_id, "GAMES_WON")
		
		if is_run_won:
			var time = stats.get_value(char_id, "RUN_TIME", 0.0)
			if time == 0.0 || time > run_stats["RUN_TIME"]:
				stats.update_value(char_id, "RUN_TIME", run_stats["RUN_TIME"])
			time = stats.get_value(char_id, "WAVE20_TIME", 0.0)
			if time == 0.0 || time > wave_stats["TIME"]:
				stats.update_value(char_id, "WAVE20_TIME", wave_stats["TIME"])
		
		#Save finished runs
		var path = "user://" + ProgressData.get_user_id() + "/mod_advstats/character_data"
		stats.save(path)
		stats.save(path)


func save():
	var path = "user://" + ProgressData.get_user_id() + "/mod_advstats"
	
	var d = Directory.new()
	if !d.dir_exists(path):
		d.make_dir_recursive(path)
	
	var save_file:File = File.new()
	
	var error = save_file.open(path + "/save", File.WRITE)
	if error != OK:
		#report may be
		return
	
	var dict = { "mod_state":mod_state, "run_stats":run_stats }
	
	save_file.store_var(dict)
	save_file.close()


func load():
	var mod_dir = "user://" + ProgressData.get_user_id() + "/mod_advstats"
	var path = mod_dir + "/save"
	
	var file = File.new()
	
	if file.file_exists(path):
		file.open(path, File.READ)
		var read_val = file.get_var(true)
		if read_val:
			mod_state = read_val.get("mod_state", init_mod_state())
			run_stats_saved = read_val.get("run_stats", null)
		file.close()
	else:
		mod_state = init_mod_state()
	
	for it in character_stats_normal:
		it.load(mod_dir + "/character_data")
	for it in character_stats_endless:
		it.load(mod_dir + "/character_data")


func save_run_state():
	run_stats_saved = run_stats


func reset_run_state():
	run_stats_saved = null


func resum_from_state():
	if run_stats_saved != null:
		run_stats = run_stats_saved


func init_wave_stats_container()->Dictionary:
	return {
		"TIME":0,
		"LOOT_BOXES":0,
		"BOSSES_KILLED":0,
	}


func init_stats_container()->Dictionary:
	return {
		"DAMAGE_DONE":0,
		"DAMAGE_DONE_OVERKILL":0,
		"DAMAGE_DONE_WEAPONS":0,
		"DAMAGE_BY_WEAPON":[],
		"MAX_DAMAGE":0,
		"MAX_DAMAGE_SOURCE":"",
		"KILLS_ENEMIES":0,
		"KILLS_ELITES":0,
		"KILLS_LOOT_ALIENS":0,
		"KILLS_TREES":0,
		"SPAWNED_LOOT_ALIENS":0,
		"DAMAGE_TAKEN":0,
		"DAMAGE_TAKEN_SELF":0,
		"DAMAGE_TAKEN_ARMOR":0,
		"HITS_TAKEN":0,
		"HITS_DODGED":0,
		"HP_HEALED":0,
		"HP_HEALED_FRUIT":0,
		"HP_HEALED_REGEN":0,
		"HP_HEALED_LIFESTEAL":0,
		"MATERIALS_GAINED":0,
		"MATERIALS_GAINED_PICKED_UP":0,
		"MATERIALS_GAINED_HARVESTING":0,
		"MATERIALS_GAINED_RECYCLING":0,
		"MATERIALS_GAINED_WEAPON_CRIT":0,
		"MATERIALS_SPENT":0,
		"MATERIALS_SPENT_SHOP":0,
		"MATERIALS_SPENT_REROLL_SHOP":0,
		"MATERIALS_SPENT_REROLL_LEVEL_UP":0,
		"LOOT_BOXES":0,
		"LOOT_BOXES_TAKEN":0,
		"LOOT_BOXES_DISCARDED":0,
		"SHOP_ITEMS_BOUGHT":0,
		"SHOP_ITEMS_BROWSED":0,
		"DAMAGE_SAUSAGE":0,
		"RUN_TIME":0,
	}


func init_character_stats()->Dictionary:
	return {
		"GAMES_PLAYED":0,
		"GAMES_WON":0,
	}


func init_mod_state()->Dictionary:
	return {
		"BUTTON_D5_ONLY":0,
		"BUTTON_NO_ENDLESS":0,
	}
