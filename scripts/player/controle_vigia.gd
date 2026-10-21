extends CharacterBody3D

## Controla o movimento da personagem e alterna entre repouso e caminhada.

# Define a velocidade de movimento e os ajustes físicos da personagem.
const VELOCIDADE: float = 1.75
const ACELERACAO: float = 18.0
const DESACELERACAO: float = 18.0
const GRAVIDADE: float = 20.0
const VELOCIDADE_ROTACAO: float = 10.0
const SENSIBILIDADE_CAMERA: float = 0.003
const INCLINACAO_MINIMA_CAMERA: float = -1.05
const INCLINACAO_MAXIMA_CAMERA: float = 0.25
const NOME_WALK: StringName = &"CharacterArmature|Walk"
const NOME_IDLE: StringName = &"CharacterArmature|Idle_Neutral"
const LIMIAR_PARADO: float = 0.08

# Guarda o modelo visual e encontra o AnimationPlayer importado do FBX.
@onready var visual: Node3D = $Visual
@onready var personagem: Node3D = $Visual/Modelo/Personagem
@onready var camera_pivot: Node3D = $CameraPivot

# Guarda a referência das animações e o estado atual da caminhada.
var animation_player: AnimationPlayer
var caminhada_ativa: bool = false
var animacoes_validas: bool = false


func _ready() -> void:
	# Localiza as animações originais que acompanham o modelo Suit.
	animation_player = _encontrar_animation_player(personagem)
	if animation_player == null:
		push_error("A personagem Suit precisa ter um AnimationPlayer.")
		return

	# Confere os dois clips do pacote antes de iniciar a pose de repouso.
	if not animation_player.has_animation(NOME_WALK):
		push_error("A animação Walk não foi encontrada no modelo Suit.")
		return
	if not animation_player.has_animation(NOME_IDLE):
		push_error("A animação Idle_Neutral não foi encontrada no modelo Suit.")
		return

	# Mantém as duas animações em loop e inicia a personagem em repouso.
	animation_player.get_animation(NOME_WALK).loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation(NOME_IDLE).loop_mode = Animation.LOOP_LINEAR
	animacoes_validas = true
	animation_player.play(NOME_IDLE)


func _input(event: InputEvent) -> void:
	# No computador, gira a câmera somente enquanto o botão direito está pressionado.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_rotacionar_camera((event as InputEventMouseMotion).relative)
	elif event is InputEventScreenDrag:
		# Em telas touch, só usa arrastes que começam no lado direito da tela.
		var largura_tela := get_viewport().get_visible_rect().size.x
		if (event as InputEventScreenDrag).position.x >= largura_tela * 0.5:
			_rotacionar_camera((event as InputEventScreenDrag).relative)


func _rotacionar_camera(deslocamento: Vector2) -> void:
	# Aplica o arraste à órbita horizontal e vertical, limitando a inclinação.
	camera_pivot.rotation.y += deslocamento.x * SENSIBILIDADE_CAMERA
	camera_pivot.rotation.x = clampf(
		camera_pivot.rotation.x - deslocamento.y * SENSIBILIDADE_CAMERA,
		INCLINACAO_MINIMA_CAMERA,
		INCLINACAO_MAXIMA_CAMERA
	)


func _physics_process(delta: float) -> void:
	# Lê WASD e normaliza a diagonal para manter a mesma velocidade em todas as direções.
	var entrada := Vector2.ZERO
	entrada.x = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
	entrada.y = float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
	if entrada.length_squared() > 1.0:
		entrada = entrada.normalized()

	# Move no plano XZ e aplica gravidade apenas enquanto a personagem está no ar.
	var direcao := Vector3(entrada.x, 0.0, entrada.y)
	if not is_on_floor():
		velocity.y -= GRAVIDADE * delta
	else:
		velocity.y = 0.0

	# Acelera ao começar e desacelera ao soltar as teclas.
	var taxa := ACELERACAO if direcao != Vector3.ZERO else DESACELERACAO
	velocity.x = move_toward(velocity.x, direcao.x * VELOCIDADE, taxa * delta)
	velocity.z = move_toward(velocity.z, direcao.z * VELOCIDADE, taxa * delta)

	# Gira apenas o modelo para que a frente acompanhe a direção do deslocamento.
	if direcao != Vector3.ZERO:
		var angulo_alvo := atan2(direcao.x, direcao.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, angulo_alvo, 1.0 - exp(-VELOCIDADE_ROTACAO * delta))

	# Resolve colisões antes de sincronizar a animação com o deslocamento.
	move_and_slide()
	_atualizar_caminhada()


func _atualizar_caminhada() -> void:
	# Alterna entre caminhada e repouso sem reiniciar o clip a cada quadro.
	if animation_player == null or not animacoes_validas:
		return
	var velocidade_horizontal := Vector2(velocity.x, velocity.z).length()
	var deve_caminhar := velocidade_horizontal > LIMIAR_PARADO

	# Ajusta a cadência da caminhada à velocidade horizontal da personagem.
	if deve_caminhar:
		animation_player.speed_scale = clampf(velocidade_horizontal / VELOCIDADE, 0.35, 1.0)
	if deve_caminhar == caminhada_ativa:
		return

	# Toca a animação correspondente quando o estado de movimento muda.
	if deve_caminhar:
		animation_player.play(NOME_WALK, 0.12)
	else:
		animation_player.play(NOME_IDLE, 0.12)
		animation_player.speed_scale = 1.0
	caminhada_ativa = deve_caminhar


func _encontrar_animation_player(no: Node) -> AnimationPlayer:
	# Procura recursivamente o AnimationPlayer importado junto com o modelo.
	if no is AnimationPlayer:
		return no as AnimationPlayer
	for filho in no.get_children():
		var encontrado := _encontrar_animation_player(filho)
		if encontrado != null:
			return encontrado
	return null
