extends Node2D

@onready var bird: CharacterBody2D = $Bird
@onready var pipe_spawner: Node2D = $PipeSpawner

var _bird_start_pos: Vector2

func _ready() -> void:
	_bird_start_pos = bird.position

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		if event.is_action_pressed("flap"):
			restart_game()

func restart_game() -> void:
	pipe_spawner.clear_pipes()
	bird.reset_bird(_bird_start_pos)
	GameManager.reset_game()
