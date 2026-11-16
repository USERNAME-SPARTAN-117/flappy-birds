extends Node2D

@onready var bird: CharacterBody2D = $Bird
@onready var pipe_spawner: Node2D = $PipeSpawner

var _bird_start_pos: Vector2
var _can_restart: bool = false

func _ready() -> void:
	_bird_start_pos = bird.position
	GameManager.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.GAME_OVER:
		_can_restart = false
		await get_tree().create_timer(1.0).timeout
		_can_restart = true

func _input(event: InputEvent) -> void:
	if GameManager.current_state == GameManager.GameState.GAME_OVER and _can_restart:
		if event.is_action_pressed("flap"):
			restart_game()

func restart_game() -> void:
	_can_restart = false
	pipe_spawner.clear_pipes()
	bird.reset_bird(_bird_start_pos)
	GameManager.reset_game()
