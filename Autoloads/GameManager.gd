extends Node

signal state_changed(new_state: GameState)
signal score_updated(new_score: int)
signal high_score_updated(new_high_score: int)

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

const SAVE_PATH := "user://GodotSaves/FlappyBird/save.cfg"

var current_state: GameState = GameState.MENU
var score: int = 0
var high_score: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()


func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	
	# Handle engine pause cleanly when switching to/from PAUSED
	get_tree().paused = (current_state == GameState.PAUSED)
	state_changed.emit(current_state)

func reset_game() -> void:
	score = 0
	score_updated.emit(score)
	change_state(GameState.MENU)

func add_score(amount: int = 1) -> void:
	if current_state != GameState.PLAYING:
		return
	score += amount
	score_updated.emit(score)
	
	if score > high_score:
		high_score = score
		high_score_updated.emit(high_score)
		save_high_score()

func save_high_score() -> void:
	# Create the nested directories if they don't exist yet
	DirAccess.make_dir_recursive_absolute(SAVE_PATH.get_base_dir())
	
	var config := ConfigFile.new()
	config.set_value("progress", "high_score", high_score)
	config.save(SAVE_PATH)


func load_high_score() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		high_score = config.get_value("progress", "high_score", 0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == GameState.PLAYING:
			change_state(GameState.PAUSED)
		elif current_state == GameState.PAUSED:
			change_state(GameState.PLAYING)
