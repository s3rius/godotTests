extends Node

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(22099, 20)
	get_tree().set_network_peer(peer)
	
	#var peer = NetworkedMultiplayerENet.new()
	#peer.create_client("46.0.193.227", 22099)
	#get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "s3rius" }

func _player_connected(id):
	pass # Will go unused, not useful here

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info

func _connected_ok():
    # Only called on clients, not server. Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected():
	pass # Server kicked us, show error and abort

func _connected_fail():
	pass # Could not even connect to server, abort

remote func register_player(id, info):
    # Store the info
	player_info[id] = info
    # If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
        # Send my info to new player
		rpc_id(id, "register_player", 1, my_info)
        # Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])

    # Call function to update lobby UI here
remote func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	# Load my player
	var my_player = preload("res://Player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	get_node("/root/Players").add_child(my_player)

	# Load other players
	for p in player_info:
		var player = preload("res://Player.tscn").instance()
		player.set_name(str(p))
		get_node("/root/Players").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring
	rpc_id(1, "done_preconfiguring", selfPeerID)
	
var players_done = []
remote func done_preconfiguring(who):
    # Here is some checks you can do, as example
	assert(get_tree().is_network_server())
	assert(who in player_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == player_info.size():
		rpc("post_configure_game")

remote func post_configure_game():
	get_tree().set_pause(false)
    # Game starts now!
