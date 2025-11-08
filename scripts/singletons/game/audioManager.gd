extends Node

func play(stream:AudioStream) -> AudioStreamPlayer:
	var player:AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	get_tree().get_root().add_child(player)
	player.play()
	return player
