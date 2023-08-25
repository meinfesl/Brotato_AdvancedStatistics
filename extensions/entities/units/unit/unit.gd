extends "res://entities/units/unit/unit.gd"


func _on_BurningTimer_timeout()->void:
	var sausage = false
	
	if _burning && _burning.type != BurningType.ENGINEERING:
		sausage = true
		if _burning.from && is_instance_valid(_burning.from):
			for effect in _burning.from.effects:
				if effect.key == "effect_burning":
					sausage = false
					break
	
	var hp = current_stats.health
	
	RunData.mod_advstats.sausage = sausage
	._on_BurningTimer_timeout()
	RunData.mod_advstats.sausage = false
	
	if sausage:
		RunData.mod_advstats.run_stats["DAMAGE_SAUSAGE"] += (hp - current_stats.health)

