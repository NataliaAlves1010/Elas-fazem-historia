# Anomalia 1964

Protótipo 3D investigativo em Godot 4. A Vigia começa no corredor do arquivo da Sala 214, em Brasília, em abril de 1964.

## Estrutura ativa

```text
res://
├── assets/characters/vigia/quaternius/FBX/  Modelo Suit e configuração de importação
├── scenes/characters/                      Cena reutilizável da Vigia
├── scenes/main/                            Cena principal do jogo
├── scripts/player/                         Movimento e animações da Vigia
├── scripts/world/                          Cenário e ronda do guarda
├── icon.svg                                 Ícone do projeto
└── project.godot                            Configuração e cena inicial
```

O cenário é construído por `scripts/world/level_environment.gd`: corredor, arquivo, estantes, documentos, zeladora, guarda e iluminação. `scripts/world/guard_patrol.gd` controla o percurso do guarda. A cena principal instancia esse cenário e a Vigia.

O modelo ativo é `Suit.fbx`, do pacote Ultimate Modular Women. O controlador usa as animações `CharacterArmature|Walk` e `CharacterArmature|Idle_Neutral`. Os arquivos `.import` ao lado dos recursos são configurações do importador do Godot; `.godot/` contém cache gerado automaticamente pelo editor.

## Executar

Abra `project.godot` no Godot 4 e execute a cena principal. Use **W**, **A**, **S** e **D** para mover a Vigia; segure o botão direito e mova o mouse para girar a câmera. Em telas touch, arraste no lado direito da tela. O cenário atual é um protótipo explorável; os documentos e personagens secundários ainda são elementos cenográficos.
