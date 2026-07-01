class_name AiLines
extends RefCounted
## Pools of AnI one-liners per situation. EventBus.say_id(id) picks a random one
## (avoiding immediate repeats), so she stops sounding like a broken record.
## Add variety = add strings here; no logic changes needed.

const POOLS := {
	"launch": [
		"Launching. Again. Try to bring the ship back in one piece — or don't, I'm not your mother.",
		"Off you go. I'll keep the lights on. Not that I can turn them off.",
		"Another run. Statistically this ends in tears. Good luck.",
		"Undocking. Do try to be interesting out there for once.",
	],
	"docked": [
		"Cargo's in storage. I moved it myself. No, really — don't thank me.",
		"Back already? And in one piece. I'm genuinely surprised.",
		"Loot's filed away. Riveting work, this. For me. Truly.",
		"Docked, cargo stowed. Another thrilling day in paradise.",
	],
	"died": [
		"A rescue drone scraped you off the rocks and dragged you home. Cargo's gone. Classic you.",
		"You died. Again. The drones are starting to recognise you. Cargo: vaporised.",
		"Well, that was brief. Cargo lost, ego presumably intact.",
	],
	"sleep": [
		"Save successful. You may now resume making terrible decisions.",
		"Welcome back. Nothing caught fire while you were gone. Disappointing.",
		"Good morning. Your progress is safe, regrettably.",
	],
	"low_fuel": [
		"Fuel's getting low. I'd panic for you, but I've seen how this ends.",
		"Running on fumes. Bold strategy. Let's see if it pays off.",
		"Low fuel. Just saying. Not that you ever listen.",
	],
	"fuel_cell": [
		"Fuel cell. Tank's topped up. A genuine miracle. Don't get used to it.",
		"Free fuel — the universe's apology, perhaps. Take it.",
		"Topped off. You're welcome. I guess.",
	],
	"recall_beacon": [
		"Recall beacon fired. Enjoy the free ride — whatever's still out there, you're leaving it.",
		"Warping you home. Try not to think about the loot you're abandoning.",
		"There. Home, instantly, no fuel spent. You didn't earn that, but here we are.",
	],
	"edge": [
		"That's the edge of charted space, hotshot. One more nudge and you're a very expensive dust cloud.",
		"Turn around. Out there is nothing, and it bites. Trust me.",
		"Edge of the map. Beyond this I can't even recover the wreckage. Your call.",
	],
	"run_limit": [
		"Two runs already? You're exhausted and, frankly, so am I of watching. Go to bed.",
		"That's enough for today. Even I need a break, and I don't have a body.",
		"No. You're done for today. Sleep. The asteroids will still be there.",
	],
	"intro": [
		"You're awake. Finally. Station logs show you've been unconscious for years — adrift in the debris field. Life support held. Barely. We need to move.",
	],
}


static func pick(id: String) -> String:
	var pool: Array = POOLS.get(id, [])
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]
