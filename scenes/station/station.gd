extends Node2D
## Station-domain root scene (BASE). Wires the props to meta-domain actions.
## Holds NO run logic. Props, player, camera, HUD and panels are composed in
## station.tscn.

const WORKBENCH_FLAG := "weapon_workbench"

@onready var _bed: Interactable = $Props/Bed
@onready var _terminal: Interactable = $Props/Terminal
@onready var _door: Interactable = $Props/Door
@onready var _storage: Interactable = $Props/Storage
@onready var _workbench: Interactable = $Props/Workbench
@onready var _upgrade_panel: CanvasLayer = $UpgradePanel
@onready var _weapon_panel: CanvasLayer = $WeaponPanel
@onready var _storage_panel: CanvasLayer = $StoragePanel


func _ready() -> void:
	_bed.triggered.connect(_on_bed)
	_terminal.triggered.connect(_on_terminal)
	_door.triggered.connect(_on_door)
	_storage.triggered.connect(_on_storage)
	_workbench.triggered.connect(_on_workbench)
	EventBus.progress_unlocked.connect(func(_flag): _update_workbench())
	_update_workbench()


# Workbench only exists once its blueprint has been collected.
func _update_workbench() -> void:
	var unlocked := ProgressManager.has(WORKBENCH_FLAG)
	_workbench.visible = unlocked
	_workbench.monitorable = unlocked
	_workbench.set_deferred("monitoring", unlocked)


func _on_bed() -> void:
	GameManager.sleep_and_save()


func _on_terminal() -> void:
	_upgrade_panel.open()


func _on_door() -> void:
	GameManager.start_run()


func _on_storage() -> void:
	_storage_panel.open()


func _on_workbench() -> void:
	_weapon_panel.open()
