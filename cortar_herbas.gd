extends Node2D
@onready var timer = $Timer
@onready var segundos = $Segundos

var initialPosition

var game_over = false

var herbas
var limite_tempo = 120

var contador_herbas_cortadas = 0
var contador_tempo = 0

func _get_random_wait_time():
	return randf_range(1.0, 5.0)
	
func _ready():
	initialPosition = $Herba.position
	timer = $Timer
	timer.connect("timeout", _on_timer_timeout)
	timer.wait_time = _get_random_wait_time()
	timer.start()
	
	segundos = $Segundos
	segundos.connect("timeout", _on_segundos_timeout)	
	segundos.start()

	herbas = []
	contador_tempo = limite_tempo
	
	_actualiza_contador_tempo()

func _on_timer_timeout():
	if !game_over:
		# Borramos as herbas que saen da pantalla
		for herba in herbas:
			if herba.position.x < 0:
				remove_child(herba)
				herbas.erase(herba)

		var herba = $Herba.duplicate()
		herba.position = initialPosition
		# Hacemos la herbe sea visible
		herba.visible = true
		add_child(herba)
		herbas.append(herba)
		
		timer.wait_time = _get_random_wait_time()
	
func _on_segundos_timeout():
	if !game_over:
		contador_tempo = contador_tempo - 1;
		$Contador/TextoFallaches.visible = false
		$Contador/TextoOk.visible = false
		_actualiza_contador_tempo()	

func _actualiza_contador_tempo():
	$Contador/ContadorTempo.text = str(contador_tempo)
	
func _process(_delta):
	if !game_over:
		if Input.is_action_just_pressed("ui_accept"):
			print("Pulsado espacio")
			var huboCorte = false
			
			for herba in herbas:			
				if herba.get_node("Area2D").has_overlapping_areas() and herba.get_node("Area2D").get_overlapping_areas().has($Tixeira.get_node("Area2D")):
					print("Cortada herba")
					contador_herbas_cortadas = contador_herbas_cortadas + 1
					$Contador/ContadorHerbasCortadas.text = str(contador_herbas_cortadas)
					remove_child(herba)
					herbas.erase(herba)
					huboCorte = true
					$Contador/TextoOk.visible = true
					break
					
			if !huboCorte:
				$Contador/TextoFallaches.visible = true
				contador_tempo = max(contador_tempo - 10, 0)
				_actualiza_contador_tempo()
					
		for herba in herbas:			
			# Movemos a herba á esqueda
			herba.position.x -= _delta * 200
			
		if contador_tempo <= 0:
			game_over = true
			$GameOverText.visible = true
