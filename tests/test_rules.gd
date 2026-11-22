extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	game.tick(3.0)
	check(not game.ended and is_equal_approx(game.bird_y, 0.47) and not game.started, "jogo aguarda primeiro toque")
	game.flap()
	check(game.bird_speed < 0.0, "toque gera impulso")
	game._advance(0.01)
	check(game.bird_y < 0.47, "personagem sobe")
	game.bird_y = 0.5
	game.obstacle_x = 0.04
	game.gap_y = 0.5
	game.passed = false
	game._advance(0.01)
	check(game.score == 1, "obstáculo atravessado pontua")
	game.bird_y = 0.99
	game._advance(0.02)
	check(game.ended, "colisão com chão encerra partida")
	game.reset()
	game.hold(Vector2.ZERO)
	check(not game.started, "soltar toque longo não começa jogo")
	check(not game.ended and game.score == 0, "reinício limpo")
	finish()


func finish() -> void:
	print("Tap Fly: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
