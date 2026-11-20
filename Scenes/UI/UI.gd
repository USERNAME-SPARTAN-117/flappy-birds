extends Control

@export var pause_texture: Texture2D
@export var play_texture: Texture2D

@onready var score_label: Label = $ScoreLabel
@onready var pause_button: TextureButton = $PauseButton
@onready var menu_overlay: Control = $MenuOverlay
@onready var game_over_panel: Control = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/MarginContainer/VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $GameOverPanel/MarginContainer/VBoxContainer/HighScoreLabel
@onready var flash_rect: ColorRect = $FlashRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.score_updated.connect(_on_score_updated)
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	_on_score_updated(GameManager.score)
	_on_state_changed(GameManager.current_state)

func trigger_flash() -> void:
	flash_rect.color.a = 0.85
	var tween := create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)

func _on_score_updated(new_score: int) -> void:
	score_label.text = str(new_score)

func _on_state_changed(new_state: GameManager.GameState) -> void:
	menu_overlay.visible = (new_state == GameManager.GameState.MENU)
	game_over_panel.visible = (new_state == GameManager.GameState.GAME_OVER)
	
	# Only show the pause button while actively playing or paused
	pause_button.visible = (
		new_state == GameManager.GameState.PLAYING or
		new_state == GameManager.GameState.PAUSED
	)

	# Swap the button icon between pause and play
	if new_state == GameManager.GameState.PAUSED and play_texture:
		pause_button.texture_normal = play_texture
	elif pause_texture:
		pause_button.texture_normal = pause_texture

	if new_state == GameManager.GameState.GAME_OVER:
		trigger_flash()
		final_score_label.text = "SCORE: %d" % GameManager.score
		high_score_label.text = "BEST: %d" % GameManager.high_score
		
		# Fade in the whole GameOverPanel (NinePatchRect + labels together)
		game_over_panel.modulate.a = 0.0
		game_over_panel.visible = true
		var tween := create_tween()
		tween.tween_property(game_over_panel, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	else:
		game_over_panel.visible = false


func _on_pause_button_pressed() -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		GameManager.change_state(GameManager.GameState.PAUSED)
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.change_state(GameManager.GameState.PLAYING)
