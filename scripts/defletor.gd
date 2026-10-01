extends Area2D

class_name Defletor
 
enum Modo {
	ABSOLUTO,   ## o raio sai sempre nesse ângulo, ignorando de onde veio
	RELATIVO,   ## o raio gira X graus em relação à direção de entrada
	ESPELHO,    ## reflexo físico real (ângulo de incidência = ângulo de reflexão)
}

@export var modo: Modo = Modo.ABSOLUTO
@export_range(-180, 180, 0.1) var angulo_graus: float = 90.0
## Se ligado, o ângulo ABSOLUTO acompanha a rotação do próprio objeto na cena.
@export var acompanha_rotacao: bool = false

func nova_direcao(direcao_entrada: Vector2, normal: Vector2) -> Vector2:
	match modo:
		Modo.ABSOLUTO:
			var a: float = angulo_graus
			if acompanha_rotacao:
				a += global_rotation_degrees
			return Vector2.RIGHT.rotated(deg_to_rad(a))
		Modo.RELATIVO:
			return direcao_entrada.rotated(deg_to_rad(angulo_graus))
		Modo.ESPELHO:
			return direcao_entrada.bounce(normal)
	return direcao_entrada
