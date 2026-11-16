extends CharacterBody2D

signal died

@export var gravity: float = 980.0
@export var flap_velocity: float = -320.0
@export var max_fall_speed: float = 450.0
@export var hover_amplitude: float = 6.0
@export var hover_speed: float = 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var _start_y: float = 0.0
var _time: float = 0.0
var _is_dead: bool = false

func _ready() -> void:
	_start_y = position.y
	GameManager.state_changed.connect(_on_game_state_changed)
	hurtbox.body_entered.connect(_on_hazard_hit)
	hurtbox.area_entered.connect(_on_hazard_hit)
	_on_game_state_changed(GameManager.current_state)

func _physics_process(delta: float) -> void:
	match GameManager.current_state:
		GameManager.GameState.MENU:
			_process_hover(delta)
			if Input.is_action_just_pressed("flap"):
				GameManager.change_state(GameManager.GameState.PLAYING)
				flap()
				
		GameManager.GameState.PLAYING:
			if Input.is_action_just_pressed("flap"):
				flap()
			_apply_gravity(delta)
			move_and_slide()
			_update_rotation(delta)
			
		GameManager.GameState.GAME_OVER:
			# Let the bird fall to the ground after hitting a pipe
			if not is_on_floor():
				_apply_gravity(delta)
				move_and_slide()
				_update_rotation(delta)

func _process_hover(delta: float) -> void:
	_time += delta * hover_speed
	position.y = _start_y + sin(_time) * hover_amplitude
	rotation = 0.0

func flap() -> void:
	velocity.y = flap_velocity
	sprite.play("flap")
	AudioManager.play_flap()


func _apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

func _update_rotation(delta: float) -> void:
	# Tilt nose up (-25 deg) when rising, nose down (+70 deg) when falling
	var target_angle := deg_to_rad(-25.0) if velocity.y < 0.0 else deg_to_rad(70.0)
	var tilt_speed := 12.0 if velocity.y < 0.0 else 4.0
	rotation = lerp_angle(rotation, target_angle, tilt_speed * delta)

func reset_bird(spawn_pos: Vector2) -> void:
	_is_dead = false
	position = spawn_pos
	_start_y = spawn_pos.y
	velocity = Vector2.ZERO
	rotation = 0.0
	sprite.play("flap")

func _on_hazard_hit(_other: Node) -> void:
	if _is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_is_dead = true
	velocity.x = -10
	velocity.y = -250
	sprite.stop()
	died.emit()
	GameManager.change_state(GameManager.GameState.GAME_OVER)

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.MENU:
		sprite.play("flap")
