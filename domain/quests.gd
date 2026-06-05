class_name Quests
extends RefCounted
## Quest catalogue (pure data). Each quest: title, type ("main"/"side"),
## description (shown in the log) and an optional `activate_line` AnI says when
## it starts. Adding a quest = add an entry + wire its activate/complete trigger
## in QuestManager.

const LIST := {
	"reinforced_alloy": {
		"title": "Reinforce the Hull",
		"type": "main",
		"desc": "Dense, metal-rich asteroids have drifted in at the edges of the sector. Mine them for Reinforced Alloy — you'll need it to armor the hull and push into the next region.",
		"activate_line": "Sensors flag two unusually dense asteroids at the sector edges — packed with Reinforced Alloy. Exactly what we'd need to armor the hull for the next region. New mission logged: go mine them.",
	},
	"find_voyager": {
		"title": "Signal from Voyager 1",
		"type": "side",
		"desc": "AnI picked up a faint carrier signal tagged 'Voyager 1' — a real Earth probe launched in 1977, the most distant human-made object ever built. It should be light-decades away by now. So why is it pinging from THIS sector? Track it down and salvage it.",
		"activate_line": "Huh. I'm getting a carrier signal tagged 'Voyager 1' — a 1970s Earth probe that should be light-decades from here. It's pinging from this sector. That's... not possible. Side objective logged: find it.",
	},
}
