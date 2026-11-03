extends "res://entities/units/unit/unit.gd"

# FIXME, or may be devs add it
var hash_character_chef: int = Keys.generate_hash("character_chef")

func _on_BurningTimer_timeout()->void:
	# why there is _burning != null check in native _on_BurningTimer_timeout?
	if _burning == null:
		._on_BurningTimer_timeout()
		return
	
	var hp: int = current_stats.health
	var from_player = _burning_player_index
	var is_global: bool = _burning.is_global_burn
	var is_chef: bool = false
	if RunData.get_player_character(from_player).my_id_hash == hash_character_chef:
		var from = _burning.from
		if not is_global and not from:
			is_chef = true
		if Utils.get_first_scaling_stat(_burning.scaling_stats) == Keys.stat_engineering_hash:
			is_chef = false
	
	RunData.mod_advstats.burn = true
	RunData.mod_advstats.sausage = is_global
	._on_BurningTimer_timeout()
	RunData.mod_advstats.sausage = false
	RunData.mod_advstats.burn = false
	
	if is_global:
		RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"] += (hp - current_stats.health)
	elif is_chef:
		RunData.tracked_item_effects[from_player][hash_character_chef] += (hp - current_stats.health)

