## Monta o corredor e o arquivo da Sala 214 com geometria e iluminação do cenário.
extends Node3D

const GuardPatrolScript = preload("res://scripts/world/guard_patrol.gd")

const FLOOR_Y := -0.96
const WALL_COLOR := Color(0.34, 0.36, 0.31)
const TRIM_COLOR := Color(0.20, 0.21, 0.18)
const FLOOR_COLOR := Color(0.19, 0.18, 0.15)
const WOOD_COLOR := Color(0.26, 0.18, 0.12)
const PAPER_COLOR := Color(0.78, 0.72, 0.58)


func _ready() -> void:
	# Cria primeiro a iluminação e, em seguida, as áreas e personagens do cenário.
	_build_lighting()
	_build_corridor()
	_build_archive_room()
	_build_janitor()
	_build_guard()


func _material(color: Color, roughness: float = 0.9, transparent: bool = false) -> StandardMaterial3D:
	# Padroniza materiais opacos e translúcidos usados pelos objetos construídos.
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat


func _box(box_name: String, size: Vector3, at: Vector3, color: Color, solid: bool = false, parent: Node = null) -> Node3D:
	# Cria uma caixa visual e, quando necessário, adiciona colisão física.
	var owner_node: Node = self if parent == null else parent
	var holder: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.name = box_name
		owner_node.add_child(body)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		holder = body
	else:
		holder = MeshInstance3D.new()
		holder.name = box_name
		owner_node.add_child(holder)
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		holder.mesh = box_mesh
		holder.material_override = _material(color)
	holder.position = at
	if solid:
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		mesh_instance.mesh = box_mesh
		mesh_instance.material_override = _material(color)
		holder.add_child(mesh_instance)
	return holder


func _label(text_value: String, at: Vector3, color: Color = PAPER_COLOR, size: int = 30, yaw: float = 0.0, parent: Node = null) -> Label3D:
	# Insere letreiros tridimensionais com contorno para permanecerem legíveis.
	var label := Label3D.new()
	label.text = text_value
	label.font_size = size
	label.pixel_size = 0.004
	label.modulate = color
	label.outline_size = 4
	label.outline_modulate = Color(0.08, 0.07, 0.05)
	label.position = at
	label.rotation.y = yaw
	var label_parent: Node = self if parent == null else parent
	label_parent.add_child(label)
	return label


func _light(light_name: String, at: Vector3, energy: float, radius: float, tint: Color) -> void:
	# Instala uma luminária pontual e sua cúpula decorativa.
	var lamp := OmniLight3D.new()
	lamp.name = light_name
	lamp.position = at
	lamp.light_color = tint
	lamp.light_energy = energy
	lamp.omni_range = radius
	lamp.shadow_enabled = true
	add_child(lamp)
	_box(light_name + "Shade", Vector3(0.55, 0.08, 0.3), at + Vector3(0, 0.18, 0), Color(0.70, 0.56, 0.34))


func _build_lighting() -> void:
	# Define a atmosfera quente e baixa, com lâmpadas ao longo do corredor e do arquivo.
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.07, 0.075, 0.065)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.48, 0.34)
	environment.ambient_light_energy = 0.28
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.72
	world.environment = environment
	add_child(world)
	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-48, -25, 0)
	key_light.light_color = Color(1.0, 0.86, 0.66)
	key_light.light_energy = 0.35
	key_light.shadow_enabled = true
	add_child(key_light)
	_light("CorredorLampadaA", Vector3(0, 2.45, 3), 0.75, 5.8, Color(1.0, 0.78, 0.47))
	_light("CorredorLampadaB", Vector3(0, 2.45, -3.5), 0.62, 5.8, Color(1.0, 0.78, 0.47))
	_light("SalaLampada", Vector3(5.7, 2.35, -7.2), 1.05, 7.2, Color(1.0, 0.72, 0.38))


func _build_corridor() -> void:
	# Constrói o corredor de entrada, as portas e a sinalização da Sala 214.
	_box("PisoCorredor", Vector3(3.8, 0.2, 24), Vector3(0, FLOOR_Y - 0.1, 0), FLOOR_COLOR, true)
	_box("TetoCorredor", Vector3(3.8, 0.2, 24), Vector3(0, 3.35, 0), Color(0.26, 0.27, 0.24))
	_box("ParedeEsquerda", Vector3(0.18, 4.3, 24), Vector3(-1.9, 1.18, 0), WALL_COLOR, true)
	# Interrompe a parede direita para abrir a entrada do arquivo.
	_box("ParedeDireitaTrechoNorte", Vector3(0.18, 4.3, 18.7), Vector3(1.9, 1.18, 2.65), WALL_COLOR, true)
	_box("ParedeDireitaTrechoSul", Vector3(0.18, 4.3, 3.3), Vector3(1.9, 1.18, -10.35), WALL_COLOR, true)
	_box("RodapeEsquerdo", Vector3(0.07, 0.18, 23.8), Vector3(-1.79, -0.79, 0), TRIM_COLOR)
	_box("RodapeDireitoA", Vector3(0.07, 0.18, 18.5), Vector3(1.79, -0.79, 2.65), TRIM_COLOR)
	_box("RodapeDireitoB", Vector3(0.07, 0.18, 3.1), Vector3(1.79, -0.79, -10.35), TRIM_COLOR)
	_box("MolduraPorta214A", Vector3(0.22, 2.55, 0.18), Vector3(1.82, 0.34, -6.95), Color(0.24, 0.17, 0.11), true)
	_box("MolduraPorta214B", Vector3(0.22, 2.55, 0.18), Vector3(1.82, 0.34, -8.55), Color(0.24, 0.17, 0.11), true)
	_box("MolduraPorta214Topo", Vector3(0.22, 0.18, 1.75), Vector3(1.82, 1.62, -7.75), Color(0.24, 0.17, 0.11), true)
	_box("PlacaSala214", Vector3(0.035, 0.45, 1.3), Vector3(1.77, 2.25, -7.75), Color(0.16, 0.16, 0.13))
	_label("SALA 214", Vector3(1.74, 2.23, -7.75), Color(0.91, 0.78, 0.52), 31, PI / 2.0)
	_box("QuadroAviso", Vector3(0.06, 0.85, 1.3), Vector3(-1.78, 1.75, 1.6), Color(0.28, 0.25, 0.18))
	_label("COMUNICADO\nCAPITAL SEGURA", Vector3(-1.73, 1.95, 2.15), Color(0.83, 0.79, 0.65), 18, -PI / 2.0)
	_label("ARQUIVO CENTRAL", Vector3(-1.72, 2.45, -2.6), Color(0.76, 0.68, 0.48), 19, -PI / 2.0)
	_box("PortaFechada", Vector3(0.08, 2.25, 1.15), Vector3(-1.78, 0.15, -5.1), Color(0.22, 0.19, 0.14), true)
	_box("VisorPorta", Vector3(0.04, 0.44, 0.42), Vector3(-1.72, 1.48, -5.1), Color(0.35, 0.38, 0.34))
	_box("PlacaPortaFechada", Vector3(0.035, 0.35, 0.86), Vector3(-1.71, 1.85, -5.1), Color(0.14, 0.15, 0.13))
	_label("214", Vector3(-1.68, 1.83, -5.1), Color(0.89, 0.79, 0.56), 26, -PI / 2.0)


func _build_archive_room() -> void:
	# Monta as estantes, pastas, mesa de catalogação e documentos investigativos.
	_box("PisoSala214", Vector3(8.0, 0.2, 7.0), Vector3(5.8, FLOOR_Y - 0.1, -7.5), FLOOR_COLOR, true)
	_box("TetoSala214", Vector3(8.0, 0.2, 7.0), Vector3(5.8, 3.35, -7.5), Color(0.25, 0.26, 0.22))
	_box("ParedeFundoSala", Vector3(8.0, 4.3, 0.18), Vector3(5.8, 1.18, -11.0), WALL_COLOR, true)
	_box("ParedeLateralSala", Vector3(0.18, 4.3, 7.0), Vector3(9.8, 1.18, -7.5), WALL_COLOR, true)
	_box("ParedeSalaFrente", Vector3(8.0, 4.3, 0.18), Vector3(5.8, 1.18, -4.0), WALL_COLOR, true)
	_box("PrateleiraArquivoA", Vector3(2.3, 2.25, 0.52), Vector3(4.25, 0.16, -10.55), WOOD_COLOR, true)
	_box("PrateleiraArquivoB", Vector3(2.3, 2.25, 0.52), Vector3(7.25, 0.16, -10.55), WOOD_COLOR, true)
	for shelf_y in [ -0.35, 0.28, 0.91 ]:
		_box("Prateleira", Vector3(2.42, 0.08, 0.58), Vector3(4.25, shelf_y, -10.25), Color(0.34, 0.23, 0.14))
		_box("Prateleira", Vector3(2.42, 0.08, 0.58), Vector3(7.25, shelf_y, -10.25), Color(0.34, 0.23, 0.14))
	for i in range(8):
		var x := 3.28 + float(i % 4) * 0.54
		var y := -0.06 + float(floori(float(i) / 4.0)) * 0.63
		_box("PastaArquivo", Vector3(0.38, 0.48, 0.42), Vector3(x, y, -10.15), Color(0.39 + float(i % 3) * 0.05, 0.29, 0.17))
		_box("PastaArquivo", Vector3(0.38, 0.48, 0.42), Vector3(x + 3.0, y, -10.15), Color(0.35, 0.36 + float(i % 3) * 0.04, 0.26))
	_box("MesaCatalogacao", Vector3(2.75, 0.12, 1.35), Vector3(6.1, -0.02, -6.45), WOOD_COLOR, true)
	_box("GaveteiroMesa", Vector3(0.55, 0.82, 1.1), Vector3(7.05, -0.49, -6.45), Color(0.22, 0.17, 0.12), true)
	_box("PernaMesaA", Vector3(0.11, 0.82, 0.11), Vector3(5.0, -0.49, -6.95), WOOD_COLOR, true)
	_box("PernaMesaB", Vector3(0.11, 0.82, 0.11), Vector3(5.0, -0.49, -5.95), WOOD_COLOR, true)
	_box("MaquinaDeEscrever", Vector3(0.75, 0.28, 0.48), Vector3(5.5, 0.18, -6.25), Color(0.12, 0.13, 0.12))
	_box("RoloMaquina", Vector3(0.72, 0.07, 0.08), Vector3(5.5, 0.34, -6.13), Color(0.28, 0.27, 0.23))
	for i in range(9):
		var row := floori(float(i) / 3.0)
		var col := i % 3
		var card_at := Vector3(6.05 + float(col) * 0.57, 0.075, -6.05 - float(row) * 0.25)
		_box("Documento%02d" % (i + 1), Vector3(0.43, 0.025, 0.20), card_at, PAPER_COLOR)
		_label("FICHA %02d" % (i + 1), card_at + Vector3(-0.18, 0.025, 0.01), Color(0.23, 0.20, 0.15), 12)
	_box("Cadeira", Vector3(0.7, 0.15, 0.65), Vector3(6.1, -0.18, -5.25), Color(0.20, 0.15, 0.11), true)
	_box("EncostoCadeira", Vector3(0.65, 0.72, 0.12), Vector3(6.1, 0.22, -4.97), Color(0.20, 0.15, 0.11), true)
	_box("LuminariaAbajurBase", Vector3(0.28, 0.07, 0.28), Vector3(7.0, 0.08, -6.2), Color(0.18, 0.16, 0.12))
	_box("LuminariaAbajurHaste", Vector3(0.05, 0.44, 0.05), Vector3(7.0, 0.32, -6.2), Color(0.18, 0.16, 0.12))
	_box("LuminariaAbajurCupula", Vector3(0.42, 0.16, 0.38), Vector3(7.0, 0.58, -6.2), Color(0.66, 0.48, 0.23))
	_label("MUDANÇA DE CIDADE  /  VIAGEM  /  ABANDONO DE LAR", Vector3(5.7, 2.75, -10.86), Color(0.80, 0.72, 0.54), 17)
	_label("CARIMBO: SETOR 04", Vector3(5.8, 2.42, -10.86), Color(0.78, 0.29, 0.20), 18)


func _make_person(name_value: String, at: Vector3, coat: Color, head_color: Color) -> Node3D:
	# Cria uma figura simples para os personagens secundários do protótipo.
	var person := Node3D.new()
	person.name = name_value
	person.position = at
	add_child(person)
	var torso := CapsuleMesh.new()
	torso.radius = 0.22
	torso.height = 0.92
	var torso_mesh := MeshInstance3D.new()
	torso_mesh.mesh = torso
	torso_mesh.material_override = _material(coat)
	torso_mesh.position.y = -0.08
	person.add_child(torso_mesh)
	var head := SphereMesh.new()
	head.radius = 0.16
	head.height = 0.32
	var head_mesh := MeshInstance3D.new()
	head_mesh.mesh = head
	head_mesh.material_override = _material(head_color)
	head_mesh.position.y = 0.62
	person.add_child(head_mesh)
	for side in [-1.0, 1.0]:
		var leg := CapsuleMesh.new()
		leg.radius = 0.09
		leg.height = 0.62
		var leg_mesh := MeshInstance3D.new()
		leg_mesh.mesh = leg
		leg_mesh.material_override = _material(Color(0.19, 0.18, 0.16))
		leg_mesh.position = Vector3(side * 0.12, -0.58, 0)
		person.add_child(leg_mesh)
	return person


func _build_janitor() -> void:
	# Coloca a zeladora perto da porta e acrescenta vassoura e fala de ambientação.
	var janitor := _make_person("Zeladora", Vector3(3.0, 0, -7.15), Color(0.35, 0.39, 0.33), Color(0.52, 0.39, 0.29))
	var apron := MeshInstance3D.new()
	var apron_mesh := BoxMesh.new()
	apron_mesh.size = Vector3(0.43, 0.68, 0.06)
	apron.mesh = apron_mesh
	apron.material_override = _material(Color(0.20, 0.25, 0.21))
	apron.position = Vector3(0, -0.15, -0.22)
	janitor.add_child(apron)
	var broom := MeshInstance3D.new()
	var broom_mesh := CylinderMesh.new()
	broom_mesh.top_radius = 0.018
	broom_mesh.bottom_radius = 0.018
	broom_mesh.height = 1.25
	broom.mesh = broom_mesh
	broom.material_override = _material(Color(0.30, 0.22, 0.13))
	broom.position = Vector3(0.43, -0.18, 0)
	broom.rotation.z = -0.15
	janitor.add_child(broom)
	_label("SALA 214. SÓ VAI DE MADRUGADA.", Vector3(3.0, 1.22, -6.65), Color(0.87, 0.78, 0.56), 15)


func _build_guard() -> void:
	# Cria a ronda, define seu percurso e mostra o alcance visual de forma ilustrativa.
	var guard := _make_person("GuardaRonda", Vector3(-0.45, 0, 0), Color(0.24, 0.29, 0.31), Color(0.56, 0.43, 0.32))
	guard.set_script(GuardPatrolScript)
	guard.set("patrol_route", PackedVector3Array([Vector3(-0.45, 0, 4.2), Vector3(-0.45, 0, -2.4), Vector3(-0.45, 0, -6.0), Vector3(-0.45, 0, 4.2)]))
	guard.set("patrol_speed", 0.65)
	var vision := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.bottom_radius = 1.15
	cone.top_radius = 0.02
	cone.height = 4.1
	vision.mesh = cone
	vision.material_override = _material(Color(0.91, 0.62, 0.27, 0.15), 1.0, true)
	vision.position = Vector3(0, 0.18, -1.95)
	vision.rotation.x = -PI / 2.0
	guard.add_child(vision)
	_label("RONDA", Vector3(-0.45, 1.05, 0.2), Color(0.79, 0.54, 0.32), 15)
