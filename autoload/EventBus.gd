extends Node
## Global signal hub (autoload). The ONLY channel for cross-domain / cross-scene
## communication, so domains never hold direct references to each other.

# --- RUN DOMAIN ---
signal asteroid_destroyed(world_position: Vector2)
signal loot_collected(item_type: int, amount: int)
signal run_started
signal run_ended(success: bool)
## run_time/max_distance are this run's final stats, reported by the RUN
## domain so the META domain (GameManager) can compare against records
## without holding a direct reference into the run scene.
signal player_docked(run_time: float, max_distance: float)
signal player_died(run_time: float, max_distance: float)
## Fired once GameManager has compared this run's stats against the saved
## records — the run-summary UI (still in the space scene) listens for this
## and shows the recap before the station transition happens.
signal run_summary_ready(stats: Dictionary)
signal fuel_changed(current: float, maximum: float)
## Visual danger from leaving charted space. 0 = safe, 1 = about to die.
signal edge_danger(level: float)

# --- META DOMAIN ---
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal game_saved
signal inventory_changed

# --- PROGRESSION ---
## A quest/unlock flag was just set (e.g. a blueprint collected).
signal progress_unlocked(flag: String)
## A quest was activated or completed (the log should refresh).
signal quest_updated

# --- STATION UI ---
## Any station overlay (storage/upgrade/quest/research) opened or closed.
signal overlay_opened
signal overlay_closed

# --- RESEARCH ---
signal research_completed(research_id: String)

# --- AI ASSISTANT (AnI) ---
## Emitted whenever AnI should speak. `level` is "info" or "warning". `sticky`
## messages don't auto-hide — the player must dismiss them (a "Understood"
## button), for text that's important enough to not risk missing (e.g. quest
## updates).
signal ai_message(text: String, level: String, sticky: bool)

## Last message, kept so an AnI HUD created right after a scene change (e.g.
## arriving at the station) can still pick up a message emitted moments earlier.
var pending_message: Dictionary = {}

var _last_line := ""

func say(text: String, level: String = "info", sticky: bool = false) -> void:
	pending_message = {"text": text, "level": level, "sticky": sticky}
	ai_message.emit(text, level, sticky)


## Say a random line from an AiLines pool, avoiding an immediate repeat.
func say_id(id: String, level: String = "info", sticky: bool = false) -> void:
	var pool: Array = AiLines.POOLS.get(id, [])
	if pool.is_empty():
		return
	var line: String = pool[randi() % pool.size()]
	var tries := 0
	while pool.size() > 1 and line == _last_line and tries < 5:
		line = pool[randi() % pool.size()]
		tries += 1
	_last_line = line
	say(line, level, sticky)
