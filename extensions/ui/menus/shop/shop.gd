extends "res://ui/menus/shop/shop.gd"

func on_item_discard_button_pressed(weapon_data:WeaponData)->void:
	RunData.mod_advstats.materials_source = "MATERIALS_GAINED_RECYCLING"
	.on_item_discard_button_pressed(weapon_data)
	RunData.mod_advstats.materials_source = ""


func _on_RerollButton_pressed()->void:
	RunData.mod_advstats.materials_source = "MATERIALS_SPENT_REROLL_SHOP"
	._on_RerollButton_pressed()
	RunData.mod_advstats.materials_source = ""


func on_item_combine_button_pressed(weapon_data:WeaponData, is_upgrade:bool = false)->void:
	RunData.mod_advstats.combining_weapons = true
	.on_item_combine_button_pressed(weapon_data, is_upgrade)
	RunData.mod_advstats.combining_weapons = false

func on_shop_item_bought(shop_item:ShopItem)->void:
	.on_shop_item_bought(shop_item)
	RunData.mod_advstats.on_shop_item_bought(shop_item)
