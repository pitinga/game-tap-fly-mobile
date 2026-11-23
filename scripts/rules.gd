extends "res://scripts/rules_base.gd"

const BIRD_X := 0.27
const BIRD_RADIUS_X := 0.035
const TOWER_WIDTH := 0.19
const GAP_HALF := 0.16
const BIRD_RADIUS_Y := 0.028

var started := false
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
	started = false
	bird_y = 0.47
	bird_speed = 0.0
	obstacle_x = 1.15
	gap_y = 0.48
	passed = false
	clock = 0.0


func flap() -> void:
	if not ended:
		started = true
		bird_speed = -0.68


func tap(_p: Vector2) -> void:
	flap()


func hold(_p: Vector2) -> void:
	# Release after a long press must not apply a second impulse.
	pass


func tick(delta: float) -> void:
	if not started or ended:
		return
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
	if not passed and obstacle_x + TOWER_WIDTH < BIRD_X - BIRD_RADIUS_X:
		passed = true
		score += 1
	if obstacle_x < -0.2:
		obstacle_x = 1.10
		gap_y = randf_range(0.31, 0.70)
		passed = false
	if bird_y < BIRD_RADIUS_Y or bird_y > 1.0 - BIRD_RADIUS_Y:
		ended = true
		message = "Bateu no teto!" if bird_y < BIRD_RADIUS_Y else "Bateu no chão!"
	if BIRD_X + BIRD_RADIUS_X > obstacle_x and BIRD_X - BIRD_RADIUS_X < obstacle_x + TOWER_WIDTH and absf(bird_y - gap_y) > GAP_HALF - BIRD_RADIUS_Y:
		ended = true
		message = "Tente novamente!"


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	canvas.draw_rect(area, Color("dff6fc"))
	for x in range(5):
		var cloud := Vector2(80 + x * 145, 120 + (x % 2) * 80)
		if cloud.x + 33.0 <= area.size.x:
			canvas.draw_circle(area.position + cloud, 33.0, Color("ffffff"))
	var ox := area.position.x + obstacle_x * area.size.x
	var top := maxf(0, gap_y - GAP_HALF)
	var bottom := minf(1, gap_y + GAP_HALF)
	var tower_top := Rect2(ox, area.position.y, area.size.x * TOWER_WIDTH, top * area.size.y).intersection(area)
	var tower_bottom := Rect2(ox, area.position.y + bottom * area.size.y, area.size.x * TOWER_WIDTH, (1.0 - bottom) * area.size.y).intersection(area)
	if tower_top.has_area(): canvas.draw_rect(tower_top, Color("2da484"))
	if tower_bottom.has_area(): canvas.draw_rect(tower_bottom, Color("2da484"))
	var pos := area.position + Vector2(BIRD_X * area.size.x, bird_y * area.size.y)
	canvas.draw_circle(pos, 21, Color("f7ba44"))
	canvas.draw_circle(pos + Vector2(7, -8), 5, INK)
	canvas.draw_colored_polygon(PackedVector2Array([pos + Vector2(16, 0), pos + Vector2(34, 8), pos + Vector2(16, 13)]), Color("ec7d43"))
