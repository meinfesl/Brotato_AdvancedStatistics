extends "res://entities/units/unit/unit.gd"


func _on_BurningTimer_timeout()->void:
	# why there is _burning != null check in native _on_BurningTimer_timeout?
	if _burning == null:
		._on_BurningTimer_timeout()
		return
	
	var hp = current_stats.health
	var is_global = _burning.is_global_burn
	RunData.mod_advstats.burn = true
	RunData.mod_advstats.sausage = _burning.is_global_burn
	._on_BurningTimer_timeout()
	RunData.mod_advstats.sausage = false
	RunData.mod_advstats.burn = false
	
	if is_global:
		RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"] += (hp - current_stats.health)

