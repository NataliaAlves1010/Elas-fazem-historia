## Move o guarda secundário continuamente entre os pontos de ronda definidos.
extends Node3D

@export var patrol_route: PackedVector3Array
@export var patrol_speed: float = 0.65

var _next_point := 0


func _process(delta: float) -> void:
	# Avança para o próximo ponto, orientando o guarda na direção do percurso.
	if patrol_route.is_empty():
		return
	var destination := patrol_route[_next_point]
	var direction := destination - position
	if direction.length_squared() > 0.0001:
		var facing := direction.normalized()
		rotation.y = atan2(-facing.x, -facing.z)
	position = position.move_toward(destination, patrol_speed * delta)
	if position.distance_to(destination) < 0.06:
		_next_point = (_next_point + 1) % patrol_route.size()
