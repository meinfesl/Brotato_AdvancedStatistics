extends "res://entities/units/unit/unit.gd"


func _on_BurningTimer_timeout()->void:
	var hp = current_stats.health
	
	RunData.mod_advstats.burn = true
	RunData.mod_advstats.sausage = _burning.is_global_burn
	._on_BurningTimer_timeout()
	RunData.mod_advstats.sausage = false
	RunData.mod_advstats.burn = false
	
	if _burning.is_global_burn:
		RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"] += (hp - current_stats.health)

