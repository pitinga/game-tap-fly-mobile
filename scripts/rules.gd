extends "res://scripts/rules_base.gd"

var bird_y := 0.47
var bird_speed := 0.0
var obstacle_x := 1.15
var gap_y := 0.48
var passed := false
var clock := 0.0


func _init() -> void:
	title = "Tap Fly"
	subtitle = "Toque para voar entre as torres"


func reset() -> void:
	super.reset()
	bird_y = 0.47
	bird_speed = 0.0
	obstacle_x = 1.15
	gap_y = 0.48
	passed = false
	clock = 0.0


func flap() -> void:
	if not ended:
		bird_speed = -0.68


func tap(_p: Vector2) -> void:
	flap()


func hold(_p: Vector2) -> void:
	flap()


func tick(delta: float) -> void:
	var n := maxi(1, int(ceil(delta / 0.012)))
	for i in range(n):
		_advance(delta / float(n))
		if ended:
			break


func _advance(dt: float) -> void:
	clock += dt
	bird_speed += 1.7 * dt
	bird_y += bird_speed * dt
	obstacle_x -= (0.32 + minf(0.17, score * 0.007)) * dt
	if not passed and obstacle_x + 0.095 < 0.27:
		passed = true
		score += 1
	if obstacle_x < -0.2:
		obstacle_x = 1.10
		gap_y = randf_range(0.31, 0.70)
		passed = false
	if bird_y < 0.028 or bird_y > 0.96:
		ended = true
		message = "Bateu no chão!"
	if absf(0.27 - obstacle_x) < 0.12 and absf(bird_y - gap_y) > 0.16:
		ended = true
		message = "Tente novamente!"


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	canvas.draw_rect(area, Color("dff6fc"))
	for x in range(5):
		canvas.draw_circle(area.position + Vector2(80 + x * 145, 120 + (x % 2) * 80), 33.0, Color("ffffff"))
	var ox := area.position.x + obstacle_x * area.size.x
	var top := maxf(0, gap_y - 0.16)
	var bottom := minf(1, gap_y + 0.16)
	canvas.draw_rect(Rect2(ox, area.position.y, area.size.x * 0.19, top * area.size.y), Color("2da484"))
	canvas.draw_rect(Rect2(ox, area.position.y + bottom * area.size.y, area.size.x * 0.19, (1.0 - bottom) * area.size.y), Color("2da484"))
	var pos := area.position + Vector2(0.27 * area.size.x, bird_y * area.size.y)
	canvas.draw_circle(pos, 21, Color("f7ba44"))
	canvas.draw_circle(pos + Vector2(7, -8), 5, INK)
	canvas.draw_colored_polygon(PackedVector2Array([pos + Vector2(16, 0), pos + Vector2(34, 8), pos + Vector2(16, 13)]), Color("ec7d43"))
