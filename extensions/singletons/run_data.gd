extends "res://singletons/run_data.gd"

var mod_advstats


func reset(restart:bool = false)->void:
	# Do it before base reset because of adding starting weapons
	mod_advstats = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker")
	mod_advstats.reset()
	
	.reset(restart)


func add_weapon_dmg_dealt(pos: int, dmg_dealt: int, player_index: int)->void:
	.add_weapon_dmg_dealt(pos, dmg_dealt, player_index)
	mod_advstats.on_weapon_damage(pos, dmg_dealt)


func add_gold(value:int, player_index: int)->void:
	.add_gold(value, player_index)
	mod_advstats.on_materials_gained(value)


func remove_gold(value:int, player_index: int)->void:
	.remove_gold(value, player_index)
	mod_advstats.on_materials_spent(value)


func remove_currency(value:int, player_index: int)->void:
	mod_advstats.run_stats["SHOP_ITEMS_BOUGHT"] += 1
	mod_advstats.materials_source = "MATERIALS_SPENT_SHOP"
	.remove_currency(value, player_index)
	mod_advstats.materials_source = ""


func resume_from_state(state:Dictionary)->void:
	.resume_from_state(state)
	mod_advstats.resum_from_state()


func add_weapon(weapon: WeaponData, player_index: int, is_selection: bool = false)->WeaponData:
	var added_weapon = .add_weapon(weapon, player_index, is_selection)
	mod_advstats.on_weapon_added(weapon)
	return added_weapon


func remove_weapon(weapon:WeaponData, player_index: int)->int:
	mod_advstats.on_weapon_removed(weapon)
	return .remove_weapon(weapon, player_index)


func remove_all_weapons(player_index: int)->void:
	.remove_all_weapons(player_index)
	mod_advstats.remove_all_weapons()


# Why here? because it's in _ready of main.gd
func reset_cache()->void:
	.reset_cache()
	#var val:int = tracked_item_effects[0]["item_piggy_bank"]
	#tracked_item_effects[0]["item_piggy_bank"] = val
