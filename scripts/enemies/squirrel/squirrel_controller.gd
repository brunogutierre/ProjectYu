extends CharacterBody2D
## IA do esquilo: patrulha, persegue comida, foge pro esconderijo e fica
## assustado quando a cachorrinha late perto o suficiente.
##
## FSM simples via enum + match (nao precisa de FSM baseada em nos pra so 4
## estados) - migrar pra isso so se a complexidade crescer bastante.

enum State { PATROL, CHASE_ITEM, FLEE_TO_HIDEOUT, SCARED }

@export var move_speed: float = 55.0
@export var flee_speed: float = 105.0
@export var patrol_distance: float = 90.0
@export var scared_duration: float = 1.6
@export var gravity: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var pickup_area: Area2D = $PickupArea

var _state: State = State.PATROL
var _patrol_origin: Vector2
var _patrol_dir: int = 1
var _target_item: FoodItem
var _held_item: FoodItem
var _target_hideout: Node2D
var _scared_timer: float = 0.0
var _flee_dir_x: float = 1.0


func _ready() -> void:
	add_to_group("squirrels")
	_patrol_origin = global_position
	detection_area.area_entered.connect(_on_detection_area_entered)
	pickup_area.area_entered.connect(_on_pickup_area_entered)
	EventBus.player_barked.connect(_on_player_barked)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match _state:
		State.PATROL:
			_process_patrol()
		State.CHASE_ITEM:
			_process_chase()
		State.FLEE_TO_HIDEOUT:
			_process_flee_to_hideout()
		State.SCARED:
			_process_scared(delta)

	move_and_slide()
	_update_animation()


func _process_patrol() -> void:
	var target_x := _patrol_origin.x + patrol_distance * 0.5 * _patrol_dir
	if abs(target_x - global_position.x) < 4.0:
		_patrol_dir *= -1
	velocity.x = move_speed * _patrol_dir


func _process_chase() -> void:
	if _target_item == null or not is_instance_valid(_target_item) or _target_item.is_held:
		_state = State.PATROL
		_target_item = null
		return
	velocity.x = move_speed * signf(_target_item.global_position.x - global_position.x)


func _process_flee_to_hideout() -> void:
	if _target_hideout == null or not is_instance_valid(_target_hideout):
		_stash_and_return_to_patrol()
		return
	var to_hideout := _target_hideout.global_position.x - global_position.x
	velocity.x = flee_speed * signf(to_hideout)
	if absf(to_hideout) < 10.0:
		_stash_and_return_to_patrol()


func _process_scared(delta: float) -> void:
	_scared_timer -= delta
	velocity.x = flee_speed * _flee_dir_x
	if _scared_timer <= 0.0:
		_state = State.PATROL
		_patrol_origin = global_position


func _on_detection_area_entered(area: Area2D) -> void:
	if _state != State.PATROL:
		return
	if area is FoodItem and not area.is_held:
		_target_item = area
		_state = State.CHASE_ITEM


func _on_pickup_area_entered(area: Area2D) -> void:
	if _state != State.CHASE_ITEM:
		return
	if area == _target_item and not area.is_held:
		_pick_up_item(area)


func _pick_up_item(item: FoodItem) -> void:
	_held_item = item
	_target_item = null
	item.pick_up()
	item.reparent(self, true)
	item.position = Vector2(0, -18)

	var hideout := _find_nearest_hideout()
	if hideout:
		_target_hideout = hideout
		_state = State.FLEE_TO_HIDEOUT
	else:
		_state = State.PATROL


func _find_nearest_hideout() -> Node2D:
	var hideouts := get_tree().get_nodes_in_group("hideouts")
	var nearest: Node2D = null
	var nearest_dist := INF
	for h in hideouts:
		var d: float = global_position.distance_to(h.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = h
	return nearest


func _stash_and_return_to_patrol() -> void:
	if _held_item and is_instance_valid(_held_item):
		var drop_pos := global_position
		if _target_hideout and is_instance_valid(_target_hideout):
			drop_pos = _target_hideout.global_position
		_release_held_item(drop_pos)
	_target_hideout = null
	_state = State.PATROL
	_patrol_origin = global_position


func _release_held_item(at_pos: Vector2) -> void:
	var item := _held_item
	_held_item = null
	item.reparent(get_tree().current_scene, true)
	item.drop_at(at_pos)


func _on_player_barked(bark_pos: Vector2, radius: float) -> void:
	if _state == State.SCARED:
		return
	if global_position.distance_to(bark_pos) > radius:
		return

	if _held_item and is_instance_valid(_held_item):
		_release_held_item(global_position)

	_target_item = null
	_target_hideout = null
	_flee_dir_x = signf(global_position.x - bark_pos.x)
	if _flee_dir_x == 0.0:
		_flee_dir_x = 1.0
	_scared_timer = scared_duration
	_state = State.SCARED


func _update_animation() -> void:
	if _state == State.SCARED:
		sprite.play(&"scared")
		return
	if absf(velocity.x) > 1.0:
		sprite.play(&"walk")
		sprite.flip_h = velocity.x < 0.0
	else:
		sprite.play(&"idle")
