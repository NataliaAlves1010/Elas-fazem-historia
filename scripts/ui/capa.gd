extends Control

@onready var jogar_button: Button = $Botoes/Jogar
@onready var continuar_button: Button = $Botoes/Continuar
@onready var galeria_button: Button = $Botoes/Galeria
@onready var opcoes_button: Button = $Botoes/Opcoes


func _ready() -> void:
	jogar_button.pressed.connect(_on_jogar_pressed)
	continuar_button.pressed.connect(_on_continuar_pressed)
	galeria_button.pressed.connect(_on_galeria_pressed)
	opcoes_button.pressed.connect(_on_opcoes_pressed)
	jogar_button.grab_focus()


func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_continuar_pressed() -> void:
	print("Continuar: ainda não implementado.")


func _on_galeria_pressed() -> void:
	print("Galeria: ainda não implementada.")


func _on_opcoes_pressed() -> void:
	print("Opções: ainda não implementadas.")
