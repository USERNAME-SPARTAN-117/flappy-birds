extends Node2D

@export var speed: float = 120.0
@export var despawn_x: float = -64.0

@onready var score_zone: Area2D = $ScoreZone

var _scored: bool = false

func _ready() -> void:
	score_zone.body_entered.connect(_on_score_zone_entered)

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
		
	position.x -= speed * delta
	
	if position.x < despawn_x:
		queue_free()

func _on_score_zone_entered(body: Node2D) -> void:
	if _scored:
		return
	if body is CharacterBody2D:
		_scored = true
		GameManager.add_score(1)
