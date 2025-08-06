extends Node2D
@onready var timer = $Timer

var initialPosition

var herbas
var contador_herbas_cortadas = 0

func _get_random_wait_time():
	return randf_range(1.0, 5.0)
	
func _ready():
	initialPosition = $Herba.position
	timer = $Timer
	timer.connect("timeout", _on_timer_timeout)
	timer.wait_time = _get_random_wait_time()
	timer.start()

	herbas = []

func _on_timer_timeout():
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
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		print("Pulsado espacio")
		for herba in herbas:			
			if herba.get_node("Area2D").has_overlapping_areas() and herba.get_node("Area2D").get_overlapping_areas().has($Tixeira.get_node("Area2D")):
				print("Cortada herba")
				contador_herbas_cortadas = contador_herbas_cortadas + 1
				$Contador/ContadorHerbasCortadas.text = str(contador_herbas_cortadas)
				remove_child(herba)
				herbas.erase(herba)
				break
				
	for herba in herbas:			
		# Movemos a herba á esqueda
		herba.position.x -= _delta * 100
