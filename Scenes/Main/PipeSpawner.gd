extends Node2D

@export var pipe_scene: PackedScene
@export var spawn_interval: float = 1.6
@export var spawn_x: float = 320.0      # Just outside the right edge of your viewport
@export var min_gap_y: float = 110.0    # Highest possible gap center
@export var max_gap_y: float = 340.0    # Lowest possible gap center

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_pipe)
	GameManager.state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.PLAYING:
		spawn_timer.start()
	else:
		spawn_timer.stop()

func _spawn_pipe() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or pipe_scene == null:
		return
	var pipe := pipe_scene.instantiate()
	pipe.position = Vector2(spawn_x, randf_range(min_gap_y, max_gap_y))
	add_child(pipe)


func clear_pipes() -> void:
	for child in get_children():
		if child is not Timer:
			child.queue_free()
