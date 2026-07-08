class_name Items
extends RefCounted
## Inventory-domain value object: the item catalogue. Pure data + helpers.
## Adding a material = add an enum value (at the END, to keep saved ints stable)
## + its cases below (name, colour, drop weight). Drops/storage/UI adapt.

enum Type {
	METAL,
	CRYSTAL,
	DATACHIP,
	ICE,
	PLASMA,
	REINFORCED_ALLOY,
}

const ALL: Array[Type] = [Type.METAL, Type.CRYSTAL, Type.DATACHIP, Type.ICE, Type.PLASMA, Type.REINFORCED_ALLOY]


static func display_name(item_type: int) -> String:
	match item_type:
		Type.METAL: return "Metal"
		Type.CRYSTAL: return "Crystal"
		Type.DATACHIP: return "Data Fragment"
		Type.ICE: return "Ice"
		Type.PLASMA: return "Plasma"
		Type.REINFORCED_ALLOY: return "Reinforced Alloy"
	return "Unknown"


static func color(item_type: int) -> Color:
	match item_type:
		Type.METAL: return Color(0.72, 0.74, 0.80)
		Type.CRYSTAL: return Color(0.30, 0.85, 1.0)
		Type.DATACHIP: return Color(1.0, 0.45, 0.95)
		Type.ICE: return Color(0.75, 0.95, 1.0)
		Type.PLASMA: return Color(0.70, 0.35, 1.0)
		Type.REINFORCED_ALLOY: return Color(1.0, 0.6, 0.25)
	return Color.WHITE


## Icons are white silhouettes from the game-icons.net library (CC BY 3.0),
## tinted at render time with color() above. New material = pick a slug from
## https://game-icons.net, drop the SVG into lib/images/icons/, add a case here.
static func texture_path(item_type: int) -> String:
	match item_type:
		Type.METAL: return "res://lib/images/icons/metal.svg"
		Type.CRYSTAL: return "res://lib/images/icons/crystal.svg"
		Type.DATACHIP: return "res://lib/images/icons/datachip.svg"
		Type.ICE: return "res://lib/images/icons/ice.svg"
		Type.PLASMA: return "res://lib/images/icons/plasma.svg"
		Type.REINFORCED_ALLOY: return "res://lib/images/icons/reinforced_alloy.svg"
	return ""
