extends CharacterBody2D
## Controle da cachorrinha: andar, pular (com coyote time e jump buffer) e latir.
##
## O latido nao referencia esquilos diretamente - so emite um sinal global com
## posicao e raio. Quem quiser reagir (esquilos) escuta o EventBus.

enum State { IDLE, RUN, JUMP, FALL, BARK }

@export var move_speed: float = 110.0
@export var acceleration: float = 900.0
@export var friction: float = 1000.0
@export var jump_velocity: float = -260.0
@export var gravity: float = 900.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var bark_radius: float = 90.0
@export var bark_duration: float = 0.35
@export var bark_cooldown: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _state: State = State.IDLE
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _bark_timer: float = 0.0
var _bark_cooldown_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_timers(delta)
	_handle_movement_input(delta)
	_handle_jump_input()
	_handle_bark_input(delta)
	move_and_slide()
	_update_state()
	_update_visuals()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		_coyote_timer = coyote_time


func _update_timers(delta: float) -> void:
	if not is_on_floor():
		_coyote_timer -= delta
	_jump_buffer_timer -= delta
	if _bark_timer > 0.0:
		_bark_timer -= delta
	if _bark_cooldown_timer > 0.0:
		_bark_cooldown_timer -= delta


func _handle_movement_input(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0.0:
		velocity.x = move_toward(velocity.x, input_dir * move_speed, acceleration * delta)
		sprite.flip_h = input_dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _handle_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0


func _handle_bark_input(_delta: float) -> void:
	if Input.is_action_just_pressed("bark") and _bark_cooldown_timer <= 0.0:
		_bark_timer = bark_duration
		_bark_cooldown_timer = bark_cooldown
		EventBus.player_barked.emit(global_position, bark_radius)


func _update_state() -> void:
	if _bark_timer > 0.0:
		_state = State.BARK
	elif not is_on_floor():
		_state = State.JUMP if velocity.y < 0.0 else State.FALL
	elif abs(velocity.x) > 4.0:
		_state = State.RUN
	else:
		_state = State.IDLE


func _update_visuals() -> void:
	match _state:
		State.IDLE:
			sprite.play(&"idle")
		State.RUN:
			sprite.play(&"run")
		State.JUMP, State.FALL:
			sprite.play(&"jump")
		State.BARK:
			sprite.play(&"bark")
