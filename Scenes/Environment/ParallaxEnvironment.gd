extends Node2D

@onready var layers: Array[Parallax2D] = [
	$CloudLayer,
	$CityFarLayer,
	$CityNearLayer,
	$BushFarLayer,
	$BushNearLayer,
	$Ground
]

var _base_speeds: Array[float] = []

func _ready() -> void:
	for layer in layers:
		_base_speeds.append(layer.autoscroll.x)
	GameManager.state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	var should_scroll := (
		new_state == GameManager.GameState.MENU or
		new_state == GameManager.GameState.PLAYING
	)
	for i in layers.size():
		layers[i].autoscroll.x = _base_speeds[i] if should_scroll else 0.0
