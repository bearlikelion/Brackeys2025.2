class_name ui_3d
extends Panel
@onready var base_selector: BaseSelector = $BaseSelector
@onready var toppings_selector: ToppingsSelector = $ToppingsSelector

var pos_base_selector : Vector2
var pos_toppings_selector : Vector2
var start_postion : Vector2

func _ready() -> void:
	start_postion = position
	modulate.a = 0.0
	var tween2 := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween2.tween_property(self,"position",start_postion,2).from(start_postion - get_parent().size/2)
	
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self,"modulate:a",1.0,2).from(0.0)
	
	var tweenro := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tweenro.tween_property(self,"rotation_degrees",0,2).from(-90)
	
	pos_base_selector = base_selector.position
	pos_toppings_selector = toppings_selector.position

func _animate_base_out(speed:float)->bool:
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",0.0,speed*1.1).from(1.0)
	var tween2 := base_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(base_selector,"position:y",get_parent().size.y-base_selector.size.y,speed*1.1).from(pos_base_selector.y)
	await tween.finished
	return true

func _animate_base_in(speed:float)->bool:
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",1.0,speed*1.1)
	var tween2 := base_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(base_selector,"position:y",pos_base_selector.y,speed*1.1).from(get_parent().size.y-base_selector.size.y)
	await tween2.finished
	return true

func _animate_toping_in(speed:float)->bool:
	#await get_tree().create_timer(1).timeout
	toppings_selector.show()
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",1.0,speed*1.1).from(0.0)
	toppings_selector.show()
	var tween2 := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(toppings_selector,"position:y",pos_toppings_selector.y,speed*1.1).from(get_parent().size.y)
	#var tweensize3 := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tweensize3.tween_property(toppings_selector,"size:y",450,speed*1.1).from(800)
	var tweenaa := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenaa.tween_property(toppings_selector,"modulate:a",1.0,speed*1.1).from(0.0)
	await tween2.finished
	return true


func _animate_toping_out(speed:float)->bool:
	#await get_tree().create_timer(1).timeout
	var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",0.0,speed*1.1).from(1.0)
	var tween2 := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(toppings_selector,"position:y",get_parent().size.y,speed*1.1).from(pos_toppings_selector.y)
	#var tweensize3 := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tweensize3.tween_property(toppings_selector,"size:y",450,speed*1.1).from(800)
	var tweenaa := toppings_selector.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenaa.tween_property(toppings_selector,"modulate:a",0.0,speed*1.1).from(1.0)
	await tween2.finished
	return true
