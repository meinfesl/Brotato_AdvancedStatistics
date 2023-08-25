extends "res://singletons/item_service.gd"


func get_shop_items(wave:int, number:int = NB_SHOP_ITEMS, shop_items:Array = [], locked_items:Array = [])->Array:
	RunData.mod_advstats.on_shop_items_updated(number)
	return .get_shop_items(wave, number, shop_items, locked_items)
