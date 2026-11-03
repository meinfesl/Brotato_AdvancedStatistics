extends "res://singletons/progress_data.gd"

var mod_advstats

func save()->void:
	.save()
	
	if not mod_advstats:
		mod_advstats = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker")
	mod_advstats.save()
	
func load_game_file(try_fallback: = true)->void:
	.load_game_file(try_fallback)
	
	mod_advstats = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker")
	mod_advstats.load()

func save_run_state(
		shop_items: = [], 
		reroll_count: = [], 
		paid_reroll_count: = [], 
		initial_free_rerolls: = [], 
		free_rerolls: = [], 
		item_steals: = []
	)->void:
	.save_run_state(shop_items,
		reroll_count, 
		paid_reroll_count, 
		initial_free_rerolls, 
		free_rerolls, 
		item_steals)
	
	mod_advstats.save_run_state()


func reset_run_state()->void:
	.reset_run_state()
	
	mod_advstats.reset_run_state()
