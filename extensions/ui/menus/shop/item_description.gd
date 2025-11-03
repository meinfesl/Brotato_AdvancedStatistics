extends "res://ui/menus/shop/item_description.gd"


func set_item(item_data: ItemParentData, player_index: int, item_count: = 1)->void:
	
	if item_data.my_id == "item_scared_sausage":
		RunData.tracked_item_effects[0]["item_scared_sausage"] = RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"]
	
	.set_item(item_data, player_index, item_count)

	var pct_text = RunData.mod_advstats.get_percent_text_for_item(item_data)
	if pct_text != "":
		var str_to_find = "[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(item_data.tracking_text, [Text.get_formatted_number(RunData.tracked_item_effects[0][item_data.my_id])]) + "[/color]"
		var last = get_effects().get_children().back()
		var text:String = last.text_descr.bbcode_text
		var index:int = text.find(str_to_find)
		if index != -1:
			var str_to_insert = "[color=#%s]%s[/color]" % [Utils.SECONDARY_FONT_COLOR.to_html(), pct_text]
			last.text_descr.bbcode_text = text.insert(index + str_to_find.length(), str_to_insert)
