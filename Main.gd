extends Node

func _ready():
	$CanvasLayer/GUI/stamina_bar.min_value = 0
	$CanvasLayer/GUI/stamina_bar.max_value = $Player.MAX_STAMINA

func _on_stamina_changed(stmn):
	 $CanvasLayer/GUI/stamina_bar.value = stmn
