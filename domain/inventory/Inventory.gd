class_name Inventory
extends RefCounted
## Inventory-domain aggregate. Fixed number of slots; each slot holds a single
## stackable item type with an unbounded count. Same-type items merge into one
## slot, so the slot limit caps item *variety*, not quantity. Pure logic.

## Number of distinct stacks this inventory can hold. The run carry-bag is small
## (a roguelite constraint); station storage is effectively unlimited.
var max_slots := 5

## `max_slots` entries. Each is either `null` or { "type": int, "count": int }.
var slots: Array = []


func _init(p_max_slots: int = 5) -> void:
	max_slots = p_max_slots
	slots.resize(max_slots)
	for i in max_slots:
		slots[i] = null


## Adds `amount` of `item_type`. Returns the amount that could NOT fit.
func add(item_type: int, amount: int) -> int:
	if amount <= 0:
		return 0
	for slot in slots:
		if slot != null and slot.type == item_type:
			slot.count += amount
			return 0
	for i in slots.size():
		if slots[i] == null:
			slots[i] = {"type": item_type, "count": amount}
			return 0
	return amount


func remove(item_type: int, amount: int) -> bool:
	for i in slots.size():
		var slot = slots[i]
		if slot != null and slot.type == item_type and slot.count >= amount:
			slot.count -= amount
			if slot.count <= 0:
				slots[i] = null
			return true
	return false


func count(item_type: int) -> int:
	for slot in slots:
		if slot != null and slot.type == item_type:
			return slot.count
	return 0


func is_empty() -> bool:
	for slot in slots:
		if slot != null:
			return false
	return true


func clear() -> void:
	for i in slots.size():
		slots[i] = null


## Moves every stack into `target`, then empties self.
func transfer_into(target: Inventory) -> void:
	for slot in slots:
		if slot != null:
			target.add(slot.type, slot.count)
	clear()


func to_dict() -> Dictionary:
	var out: Array = []
	for slot in slots:
		out.append(slot)
	return {"slots": out}


func from_dict(data: Dictionary) -> void:
	clear()
	var arr: Array = data.get("slots", [])
	for i in min(arr.size(), max_slots):
		var slot = arr[i]
		if slot != null:
			slots[i] = {"type": int(slot.get("type", 0)), "count": int(slot.get("count", 0))}
