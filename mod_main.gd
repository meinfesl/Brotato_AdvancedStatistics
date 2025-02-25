extends Node


const MOD_NAME = "meinfesl-AdvancedStatistics"

const MOD_PATH = "res://mods-unpacked/meinfesl-AdvancedStatistics/"
const EXT_PATH = MOD_PATH + "extensions/"


func _init():
	ModLoaderMod.install_script_extension(EXT_PATH + "entities/units/enemies/enemy.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "entities/units/neutral/neutral.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "entities/units/player/player.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "entities/units/unit/unit.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "singletons/item_service.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "singletons/run_data.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "singletons/progress_data.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "singletons/weapon_service.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/ingame/ingame_main_menu.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/ingame/pause_menu.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/ingame/upgrades_ui_player_container.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/shop/item_description.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/run/end_run.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "ui/menus/title_screen/title_screen.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "weapons/weapon.gd")
	ModLoaderMod.install_script_extension(EXT_PATH + "main.gd")

	var tracker = load(MOD_PATH + "stats_tracker.gd").new()
	tracker.name = "StatsTracker"
	add_child(tracker)

	ModLoaderLog.info("Init.", MOD_NAME)


func _ready():
	var loader = ModLoaderMod.new()
	loader.call_deferred("install_script_extension", EXT_PATH + "ui/menus/shop/shop.gd")

	var m = get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker")
	# Wait for dlc to load
	m.call_deferred("load_tracked_items")
	ModLoaderLog.info("Ready.", MOD_NAME)

