class_name Biome
extends Node2D
## A self-contained region of the space map. The biome's own scene holds its map
## elements (asteroids now; NPCs / bosses / structures later) placed directly in
## the editor. The space scene composes biomes side by side; space.gd discovers
## them via the "biome" group, so adding a biome needs no code changes — just
## build a scene with this as its root and drop it into the map.

## The biome's rectangle is centred on this node's position.
@export var biome_name: String = "Sector"
@export var size: Vector2 = Vector2(3600, 3600)

## If true, the player needs the Double Metal Alloy or suffers `penalty_drain`.
@export var requires_alloy: bool = false
@export var penalty_drain: float = 0.0  # fuel/sec while unshielded here

@export_multiline var enter_message: String = ""    # AnI line on entering (shielded / not required)
@export_multiline var blocked_message: String = ""  # AnI line on entering without the alloy


func _ready() -> void:
	add_to_group("biome")


func world_rect() -> Rect2:
	return Rect2(global_position - size * 0.5, size)


func contains(point: Vector2) -> bool:
	return world_rect().has_point(point)
