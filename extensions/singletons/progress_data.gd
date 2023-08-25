extends "res://singletons/progress_data.gd"

var mod_advstats

func save(path:String = SAVE_PATH)->void:
	.save(path)

	mod_advstats.save()
	
func load_game_file(path:String = SAVE_PATH)->void:
	.load_game_file(path)
	
	mod_advstats = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker")
	mod_advstats.load()

func save_run_state(
		shop_items:Array = [], 
		reroll_price:int = 0, 
		last_reroll_price:int = 0, 
		initial_free_rerolls:int = 0, 
		free_rerolls:int = 0
	)->void:
	.save_run_state(shop_items, reroll_price, last_reroll_price, initial_free_rerolls, free_rerolls)
	
	mod_advstats.save_run_state()


func reset_run_state()->void:
	.reset_run_state()
	
	mod_advstats.reset_run_state()
