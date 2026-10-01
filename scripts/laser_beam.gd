extends RayCast2D

@export_range(-360, 360, 0.1, "or_greater", "or_less") var angulo_inicial: float = 0.0   ## graus, 0 = direita
@export var alcance_por_segmento: float = 2000.0
@export var max_desvios: int = 8                                ## trava de segurança contra loop infinito
@export var ligado: bool = true

@onready var raio: RayCast2D = $"."
@onready var linha: Line2D = $laser

@onready var impacto: Node2D = get_node_or_null("Impacto")

## Empurra a origem do próximo segmento pra fora do defletor,
## pra ele não se colidir consigo mesmo.
const OFFSET := 1.0


func _ready() -> void:
	# O RayCast2D é atualizado na mão (force_raycast_update), várias vezes por frame.
	raio.enabled = false
	raio.collide_with_bodies = true
	raio.collide_with_areas = true   # necessário se os defletores forem Area2D
	raio.hit_from_inside = false


func _physics_process(_delta: float) -> void:
	if not ligado:
		linha.clear_points()
		if impacto:
			impacto.visible = false
		return
	desenhar_laser()


func desenhar_laser() -> void:
	linha.clear_points()

	var origem: Vector2 = global_position
	var direcao: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(angulo_inicial)).normalized()
	var ponto_final: Vector2 = origem

	linha.add_point(linha.to_local(origem))

	for i in max_desvios + 1:
		# 1) posiciona e dispara o ray do ponto atual, na direção atual
		raio.global_position = origem
		raio.global_rotation = 0.0                       # target_position é local: zera a rotação
		raio.target_position = direcao * alcance_por_segmento
		raio.force_raycast_update()

		# 2) não bateu em nada: desenha o segmento inteiro e encerra
		if not raio.is_colliding():
			ponto_final = origem + direcao * alcance_por_segmento
			linha.add_point(linha.to_local(ponto_final))
			break

		# 3) bateu: o segmento termina no ponto de colisão
		ponto_final = raio.get_collision_point()
		linha.add_point(linha.to_local(ponto_final))

		var alvo: Object = raio.get_collider()

		# 4) é um defletor? pega a nova direção COM ELE e continua o loop
		if alvo != null and alvo.has_method("nova_direcao"):
			direcao = alvo.nova_direcao(direcao, raio.get_collision_normal()).normalized()
			origem = ponto_final + direcao * OFFSET
			if alvo.has_method("ao_ser_atingido"):
				alvo.ao_ser_atingido(ponto_final)
		else:
			# 5) parede (ou qualquer outra coisa): o laser morre aqui
			break

	if impacto:
		impacto.visible = true
		impacto.global_position = ponto_final


## Ponto onde o laser termina de fato (útil pra dano, som, partícula).
func ponto_de_impacto() -> Vector2:
	if linha.get_point_count() == 0:
		return global_position
	return linha.to_global(linha.get_point_position(linha.get_point_count() - 1))
