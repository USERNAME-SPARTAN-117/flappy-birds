extends Node

@export var bgm_stream: AudioStream
@export var flap_sfx: AudioStream
@export var score_sfx: AudioStream
@export var hit_sfx: AudioStream

const POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_player_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -10.0
	add_child(_bgm_player)
	
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)
	
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.state_changed.connect(_on_state_changed)
	
	if bgm_stream:
		_bgm_player.stream = bgm_stream
		# Wait one idle frame so the OS audio driver is fully ready
		await get_tree().process_frame
		_bgm_player.play()

func play_sfx(stream: AudioStream, pitch_variance: float = 0.0) -> void:
	if stream == null:
		return
	
	# Pick the next player in round-robin order so sounds never stall
	var player := _sfx_players[_next_player_idx]
	_next_player_idx = (_next_player_idx + 1) % POOL_SIZE
	
	player.stop()
	player.stream = stream
	player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	player.play()

func play_flap() -> void:
	# Slight pitch variation makes repetitive flapping sound organic
	play_sfx(flap_sfx, 0.08)

func _on_score_updated(new_score: int) -> void:
	if new_score > 0:
		play_sfx(score_sfx)

func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.GAME_OVER:
		play_sfx(hit_sfx)
		_bgm_player.volume_db = -18.0  # Duck music slightly on Game Over
	elif new_state == GameManager.GameState.PLAYING:
		_bgm_player.volume_db = -10.0
