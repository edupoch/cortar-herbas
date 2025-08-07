extends Node2D

@onready var timer = $Timer
@onready var timerAlta = $TimerAlta
@onready var segundos = $Segundos

var maxDensidade = 4
var minTamanoHerba = 10
var maxTamanoHerba = 40
var maxHerbasACortar = 9
var maxTicksEnAlta = 20

var herbaModelo
var herbaAltaModelo
var barra
var barraAlta
var tixeira

var herbas
var herbasAltas

var tixeiraEnBarraAlta = false

var game_over = false

var contador_herbas_cortadas = 0
var contador_tempo = 0
var contador_ticks_alta = 0

var limite_tempo
var tamano_barra
var velocidade
var densidade

var analizando_corte = false

func _get_random_wait_time():
	return randf_range(densidade / 2, 3 * densidade / 2)
	
func _get_random_wait_time_altas():
	return randf_range(densidade / 2, 3 * densidade / 2) * 2  

func _init_game():
	velocidade = int(randf_range(100.0, 400.0))
	tamano_barra = int(randf_range(100.0, 1000.0))
	limite_tempo = int(randf_range(60.0, 120.0))
	densidade = randf_range(1.0, maxDensidade)

	contador_tempo = limite_tempo
	
	print(str("Velocidade: ", velocidade))
	print(str("Tamaño de barra: ", tamano_barra))
	print(str("Limite de tempo: ", limite_tempo))
	print(str("Densidade: ", densidade))
	
	$Parametros/Velocidade.text = str(velocidade)
	$Parametros/Tamano.text = str(tamano_barra)
	$Parametros/Densidade.text = str(int(maxDensidade + 1 - densidade))
	_actualiza_contador_tempo()
	barra.custom_minimum_size.x = tamano_barra
	barraAlta.custom_minimum_size.x = tamano_barra
	$Contador/ContadorEspazo.text = str(maxHerbasACortar)
	
func _ready():
	herbaModelo = $VBoxContainer/HBoxContainer/Barra/HerbaColorRect
	herbaAltaModelo = $VBoxContainer/HBoxContainer2/BarraAlta/HerbaColorRect
	barra = $VBoxContainer/HBoxContainer/Barra
	barraAlta = $VBoxContainer/HBoxContainer2/BarraAlta
	tixeira = $VBoxContainer/HBoxContainer/Barra/Tixeira

	_init_game()
	
	timer = $Timer
	timer.connect("timeout", _on_timer_timeout)
	timer.wait_time = _get_random_wait_time()
	timer.start()
	
	timerAlta = $TimerAlta
	timerAlta.connect("timeout", _on_timerAlta_timeout)
	timerAlta.wait_time = _get_random_wait_time()
	timerAlta.start()
	
	segundos = $Segundos
	segundos.connect("timeout", _on_segundos_timeout)	
	segundos.start()
	
	herbas = []
	herbasAltas = []

	$NovaPartida.connect("pressed", _on_nova_partida_button_pressed)
	
	tixeira.global_position.x = barra.global_position.x

func _on_nova_partida_button_pressed():
	contador_herbas_cortadas = 0
	
	for herba in herbas:
		barra.remove_child(herba)
	herbas.clear()
	
	$GameOverText.visible = false
	_actualiza_contador_herbas()
	$Contador/TextoFallaches.visible = false
	$Contador/TextoOk.visible = false
	
	_init_game()
	_baixa_tixeira()

	game_over = false

	#Quitámoslle o focus ao botón
	$NovaPartida.release_focus()

func _on_timer_timeout():
	if !game_over:
		# Borramos as herbas que saen da pantalla
		for herba in herbas:
			if herba.position.x < 0:
				barra.remove_child(herba)
				herbas.erase(herba)

		var herba = herbaModelo.duplicate()
		herba.position.x = barra.position.x + barra.custom_minimum_size.x
		
		var tamano = randf_range(minTamanoHerba, maxTamanoHerba)
		
		herba.size.x = tamano
		herba.get_node("Area2D").get_node("CollisionShape2D").shape.size.x = tamano
		herba.get_node("Area2D").get_node("CollisionShape2D").position.x = tamano / 2
		
		if (tamano < minTamanoHerba + maxTamanoHerba / 3):
			herba.color = '#ff3400'
		else:
			if (tamano < minTamanoHerba + 2 * maxTamanoHerba / 3):
				herba.color = '#ffff80'
			else:
				herba.color = '#3ba75b'
		
		# Hacemos que a herba sexa visible
		herba.visible = true
		barra.add_child(herba)
		herbas.append(herba)
		
		timer.wait_time = _get_random_wait_time()
		
func _on_timerAlta_timeout():
	if !game_over:
		# Borramos as herbas que saen da pantalla
		for herba in herbasAltas:
			if herba.position.x < 0:
				barraAlta.remove_child(herba)
				herbasAltas.erase(herba)

		var herba = herbaAltaModelo.duplicate()
		herba.position.x = barraAlta.position.x + barraAlta.custom_minimum_size.x
		
		var tamano = randf_range(minTamanoHerba, maxTamanoHerba)
		
		herba.size.x = tamano
		herba.get_node("Area2D").get_node("CollisionShape2D").shape.size.x = tamano
		herba.get_node("Area2D").get_node("CollisionShape2D").position.x = tamano / 2
		
		if (tamano < minTamanoHerba + maxTamanoHerba / 3):
			herba.color = '#ff3400'
		else:
			if (tamano < minTamanoHerba + 2 * maxTamanoHerba / 3):
				herba.color = '#ffff80'
			else:
				herba.color = '#3ba75b'
		
		# Hacemos que a herba sexa visible
		herba.visible = true
		barraAlta.add_child(herba)
		herbasAltas.append(herba)
		
		timerAlta.wait_time = _get_random_wait_time_altas()

func _on_segundos_timeout():
	if !game_over:
		contador_tempo = contador_tempo - 1;
		$Contador/TextoFallaches.visible = false
		$Contador/TextoOk.visible = false
		_actualiza_contador_tempo()

	
func _actualiza_contador_tempo():
	$Contador/ContadorTempo.text = str(contador_tempo)

func _actualiza_contador_herbas():
	$Contador/ContadorHerbasCortadas.text = str(contador_herbas_cortadas)

func _baixa_tixeira():
	barraAlta.remove_child(tixeira)
	barra.add_child(tixeira)
	tixeiraEnBarraAlta = false
	contador_ticks_alta = 0

func _process(_delta):
	if !game_over:
		if (tixeiraEnBarraAlta):
			contador_ticks_alta = contador_ticks_alta + 1
		
		if (contador_ticks_alta >= maxTicksEnAlta):
			_baixa_tixeira()		
		
		if Input.is_action_just_pressed("ui_up") and !analizando_corte:
			tixeiraEnBarraAlta = true
			barra.remove_child(tixeira)
			barraAlta.add_child(tixeira)
		
		if Input.is_action_just_pressed("ui_down") and !analizando_corte:
			_baixa_tixeira()
			
		if Input.is_action_just_pressed("ui_accept") and !analizando_corte:
			analizando_corte = true
			print("Pulsado espacio")
			var huboCorte = false
			
			for herba in herbas:
				if herba.get_node("Area2D").has_overlapping_areas() and herba.get_node("Area2D").get_overlapping_areas().has(tixeira.get_node("Area2D")):
					print("Cortada herba")
					contador_herbas_cortadas = contador_herbas_cortadas + 1
					_actualiza_contador_herbas()
					barra.remove_child(herba)
					herbas.erase(herba)
					huboCorte = true
					$Contador/TextoOk.visible = true
					$Contador/ContadorEspazo.text = str(maxHerbasACortar - contador_herbas_cortadas)
					break
					
			for herba in herbasAltas:
				if herba.get_node("Area2D").has_overlapping_areas() and herba.get_node("Area2D").get_overlapping_areas().has(tixeira.get_node("Area2D")):
					print("Cortada herba alta")
					contador_herbas_cortadas = contador_herbas_cortadas + 1
					_actualiza_contador_herbas()
					barraAlta.remove_child(herba)
					herbasAltas.erase(herba)
					huboCorte = true
					$Contador/TextoOk.visible = true
					$Contador/ContadorEspazo.text = str(maxHerbasACortar - contador_herbas_cortadas)
					break
					
			if !huboCorte:
				$Contador/TextoFallaches.visible = true
				contador_tempo = max(contador_tempo - 10, 0)
				_actualiza_contador_tempo()
				
			analizando_corte = false 
					
		for herba in herbas:			
			# Movemos a herba á esqueda
			herba.position.x -= _delta * velocidade
			
		for herba in herbasAltas:			
			# Movemos a herba á esqueda
			herba.position.x -= _delta * velocidade
			
		if contador_tempo <= 0 or contador_herbas_cortadas >= maxHerbasACortar:
			game_over = true
			$GameOverText.visible = true
