extends "res://singletons/item_service.gd"


func get_player_shop_items(wave: int, player_index: int, args: ItemServiceGetShopItemsArgs)->Array:
	RunData.mod_advstats.on_shop_items_updated(args.count)
	return .get_player_shop_items(wave, player_index, args)
