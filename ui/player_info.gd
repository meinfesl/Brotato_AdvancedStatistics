extends Control

onready var inventory = $MarginContainer/VBoxContainer/Characters/MarginContainer/Inventory
onready var row_proto = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/stats_row.tscn").instance()
onready var mod_state = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker").mod_state

var stats = []
var character_id
var changed = false
var last_row = null

func _ready():
	inventory.connect("element_focused", self, "element_focused")
	inventory.connect("element_pressed", self, "element_pressed")
	
	var _error = $"%ButtonD5".connect("pressed", self, "filter_button_pressed")
	_error = $"%ButtonNoEndless".connect("pressed", self, "filter_button_pressed")


func init():
	var potato = load("res://items/all/potato/potato_icon.png")
	inventory.clear_elements()
	inventory.add_special_element(potato, true)
	inventory.set_elements(ItemService.characters, false, false)
	
	$"%ButtonD5".set_pressed_no_signal(mod_state["BUTTON_D5_ONLY"])
	$"%ButtonNoEndless".set_pressed_no_signal(mod_state["BUTTON_NO_ENDLESS"])
	
	inventory.get_child(0).grab_focus()
	call_deferred("make_even")


func make_even():
	$MarginContainer/VBoxContainer/HBoxContainer.rect_min_size.x = inventory.rect_size.x


func element_focused(element:InventoryElement):
	if element.item:
		character_id = element.item.my_id
		$"%CharacterName".text = tr(character_id.to_upper())
	else:
		character_id = ""
		$"%CharacterName".text = "All Characters"
	
	$"%CharacterIcon".texture = element.icon
	
	build_statistics_for_current_element()


func filter_button_pressed():
	changed = true
	mod_state["BUTTON_D5_ONLY"] = $"%ButtonD5".pressed
	mod_state["BUTTON_NO_ENDLESS"] = $"%ButtonNoEndless".pressed
	build_statistics_for_current_element()


#Hack for controller/keyboard navigation
var mouse = false

func _input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_mask & BUTTON_MASK_LEFT:
			mouse = true


func element_pressed(_element):
	if mouse:
		mouse = false
		return
	$"%Records".get_child(0).get_node("MarginContainer/HBoxContainer").grab_focus()


func build_statistics_for_current_element():
	stats.clear()
	if $"%ButtonD5".pressed:
		stats.push_back(RunData.mod_advstats.character_stats_normal[5])
	else:
		for s in RunData.mod_advstats.character_stats_normal:
			stats.push_back(s)
	
	if !$"%ButtonNoEndless".pressed:
		if $"%ButtonD5".pressed:
			stats.push_back(RunData.mod_advstats.character_stats_endless[5])
		else:
			for s in RunData.mod_advstats.character_stats_endless:
				stats.push_back(s)
	
	build_statistics()


func build_statistics():
	var games_played = get_total("GAMES_PLAYED")
	var games_won = get_total("GAMES_WON")
	
	$"%TotalGames".text = "Total Games: %d" % games_played
	$"%Wins".text = "Wins: %d" % games_won
	$"%Losses".text = "Losses: %d" % (games_played - games_won)
	$"%WinRate".text = "Win Rate: %.2f%%" % calc_pct(games_won, games_played)
	
	build_top_items()
	
	for child in $"%Records".get_children():
		$"%Records".remove_child(child)
		child.queue_free()
	
	var fastest_run = make_time(get_lowest("RUN_TIME", pow(2,  63))) if games_won else "N/A"
	var d5_bosses = make_time(get_lowest("WAVE20_TIME", pow(2,  63))) if get_highest("D5_BOSSES_KILLED") else "N/A"
	make_row("Fastest Run", fastest_run)
	make_row("Fastest D5 Bosses", d5_bosses)
	make_row("", "")
	make_row("Highest Run Stats:", "")
	make_row("   Damge Done", "%d" % get_highest("DAMAGE_DONE"))
	make_row("   Damge Done With Overkill", "%d" % get_highest("DAMAGE_DONE_OVERKILL"))
	
	var max_dmg = get_max_damage()
	var dmg_source = get_damage_source(max_dmg[1])
	
	make_row("   Highest Hit", "%d" % max_dmg[0])
	if dmg_source:
		last_row.init_popup(null, $ItemPopup, dmg_source)
	
	make_row("   HP Helaed", "%d" % get_highest("HP_HEALED"))
	make_row("   Materials Gained", "%d" % get_highest("MATERIALS_GAINED"))
	make_row("   Enemies Killed", "%d" % get_highest("KILLS_ENEMIES"))
	make_row("   Items Owned", "%d" % get_highest("ITEMS_OWNED"))
	make_row("   Loot Boxes", "%d" % get_highest("LOOT_BOXES"))
	make_row("   Loot Boxes In One Wave", "%d" % get_highest("LOOT_BOXES_IN_A_SINGLE_WAVE"))
	
	var char_stats = [
		"STAT_MAX_HP",
		"STAT_HP_REGENERATION",
		"STAT_LIFESTEAL",
		"STAT_PERCENT_DAMAGE",
		"STAT_MELEE_DAMAGE",
		"STAT_RANGED_DAMAGE",
		"STAT_ELEMENTAL_DAMAGE",
		"STAT_ATTACK_SPEED",
		"STAT_CRIT_CHANCE",
		"STAT_ENGINEERING",
		"STAT_RANGE",
		"STAT_ARMOR",
		"STAT_DODGE",
		"STAT_SPEED",
		"STAT_LUCK",
		"STAT_HARVESTING",
	]
	
	make_row("", "")
	make_row("Highest Character Stats:", "")
	make_row("   Level", "%d" % get_highest("LEVEL"))
	for stat in char_stats:
		make_row("   " + tr(stat), "%d" % get_highest(stat))

func get_weapon(name):
	var weapon:WeaponData = null
	for it in ItemService.weapons:
		if it.name == name:
			if !weapon:
				weapon = it
			elif it.tier < weapon.tier:
				weapon = it
	return weapon


func get_item(id):
	for it in ItemService.items:
		if it.my_id == id:
			return it
	return null


func build_top_items():
	var weapons = get_items("WEAPONS_USAGE")
	var array = []
	for it in weapons:
		var weapon = get_weapon(it)
		if weapon:
			array.push_back([weapon, weapons[it]])
	
	array.sort_custom(self, "comparator")
	
	$"%WeaponTop1".hide()
	$"%WeaponTop2".hide()
	$"%WeaponTop3".hide()
	$"%WeaponTop4".hide()
	$"%WeaponTop5".hide()
	
	if array.size() == 0:
		$"%WeaponsNA".show()
	else:
		$"%WeaponsNA".hide()
		for i in 5:
			if array.size() <= i:
				break
			var hbox = $"%MostUsedWeapons".get_child(1 + i)
			hbox.show()
			hbox.get_child(1).texture = array[i][0].icon
			hbox.get_child(2).text = tr(array[i][0].name)
	
	var items = get_items("ITEMS_USAGE")
	array.clear()
	for it in items:
		var item = get_item(it)
		if item:
			array.push_back([item, items[it]])
	
	array.sort_custom(self, "comparator")
	
	$"%ItemTop1".hide()
	$"%ItemTop2".hide()
	$"%ItemTop3".hide()
	$"%ItemTop4".hide()
	$"%ItemTop5".hide()
	
	if array.size() == 0:
		$"%ItemsNA".show()
	else:
		$"%ItemsNA".hide()
		for i in 5:
			if array.size() <= i:
				break
			var hbox = $"%MostUsedItems".get_child(1 + i)
			hbox.show()
			hbox.get_child(1).texture = array[i][0].icon
			hbox.get_child(2).text = tr(array[i][0].my_id.to_upper())


func comparator(a, b):
	return b[1] < a[1]


func get_items(stat)->Dictionary:
	var dict:Dictionary = {}
	if character_id == "":
		for child in inventory.get_children():
			if !child.item:
				continue
			character_id = child.item.my_id
			var items = get_items(stat)
			for item in items:
				if dict.has(item):
					dict[item] += items[item]
				else:
					dict[item] = items[item]
			character_id = ""
	else:
		for it in stats:
			var items = it.get_value(character_id, stat, null)
			if items:
				for item in items:
					if dict.has(item):
						dict[item] += items[item]
					else:
						dict[item] = items[item]
	return dict


func make_row(name:String, value:String):
	var row = row_proto.duplicate()
	var hbox = row.get_node("MarginContainer/HBoxContainer")
	hbox.get_node("Name").text = name
	hbox.get_node("Value").text = value
	if name == "":
		row.get_node("Back").hide()
		hbox.focus_mode = FOCUS_NONE
	$"%Records".add_child(row)
	last_row = row


func get_damage_source(dmg_source):
	if dmg_source == "":
		return null
	
	for item in ItemService.items:
		if item.my_id == dmg_source:
			return item
	
	for weapon in ItemService.weapons:
		if weapon.my_id == dmg_source:
			return weapon
	
	for character in ItemService.characters:
		if character.my_id == dmg_source:
			return character
	
	return null


func get_max_damage():
	var value = 0
	var source = ""
	#All characters
	if character_id == "":
		for child in inventory.get_children():
			if !child.item:
				continue
			
			character_id = child.item.my_id
			var new_value = get_max_damage()
			if new_value[0] > value:
				value = new_value[0]
				source = new_value[1]
			character_id = ""
	else:
		for it in stats:
			var new_value = it.get_value(character_id, "MAX_DAMAGE", 0)
			if new_value > value:
				value = new_value
				source = it.get_value(character_id, "MAX_DAMAGE_SOURCE", "")
	return [value, source]


func get_total(key):
	var value = 0
	#All characters
	if character_id == "":
		for child in inventory.get_children():
			if !child.item:
				continue
			
			character_id = child.item.my_id
			value += get_total(key)
			character_id = ""
	else:
		for it in stats:
			value += it.get_value(character_id, key, 0)
	return value


func get_highest(key):
	var value = 0
	#All characters
	if character_id == "":
		for child in inventory.get_children():
			if !child.item:
				continue
			
			character_id = child.item.my_id
			var new_value = get_highest(key)
			if new_value > value:
				value = new_value
			character_id = "" 
	else:
		for it in stats:
			var new_value = it.get_value(character_id, key, 0)
			if new_value > value:
				value = new_value
	return value


func get_lowest(key, default):
	var value = default
	#All character
	if character_id == "":
		for child in inventory.get_children():
			if !child.item:
				continue
				
			character_id = child.item.my_id
			var new_value = get_lowest(key, default)
			if new_value < value:
				value = new_value
			character_id = "" 
	else:
		value = stats[0].get_value(character_id, key, default)
		for it in stats:
			var new_value = it.get_value(character_id, key, default)
			if new_value < value:
				value = new_value
	return value


func calc_pct(value, base):
	var pct = 0.0
	if base:
		pct = value * 100.0 / base
	return pct


func make_time(time_in_ms):
	var seconds:float = fmod(time_in_ms, 60 * 1000) / 1000
	var minutes:int   =  int(time_in_ms / (60 * 1000))
	return "%02d:%05.2f" % [minutes, seconds]
