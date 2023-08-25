extends "res://ui/menus/shop/item_description.gd"


func set_item(item_data:ItemParentData)->void:
	
	if item_data.my_id == "item_scared_sausage":
		RunData.tracked_item_effects["item_scared_sausage"] = RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"]
	
	.set_item(item_data)
	
	var pct_text = RunData.mod_advstats.get_percent_text_for_item(item_data)
	if pct_text != "":
		var str_to_find = "[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(item_data.tracking_text, [str(RunData.tracked_item_effects[item_data.my_id])]) + "[/color]"
		var text:String = get_effects().bbcode_text
		var index:int = text.find(str_to_find)
		if index != -1:
			var str_to_insert = "[color=#%s]%s[/color]" % [Utils.SECONDARY_FONT_COLOR.to_html(), pct_text]
			get_effects().bbcode_text = text.insert(index + str_to_find.length(), str_to_insert)
