extends Node2D

# load other supporting GDScript files:
var pC = load("res://scripts/playerClasses.gd").new()
var gsys = load("res://scripts/gamesys.gd").new()
var gc = load("res://scripts/gameClock.gd").new()
var gsave = load("res://scripts/save_system/gamesave.gd").new()

@onready var playerData : Dictionary = {
	company_name = "<company name here>",
	first_name = "<first name here>",
	last_name = "<last name here>",
	game_id = 0,
	game_diffuclty = 0
}

@onready var playerGames : Array
@onready var mmenu_popup = $GameLayer/MainMenuBar/MainMenu.get_popup()
@onready var resmenu_popup = $GameLayer/MainMenuBar/Resources.get_popup()

# save data vars:
@onready var indie_save_game = "user://indie_game_data.save"

# Time Objects:
@onready var game_clock = gc.GameClock.new()
@onready var game_timer:Timer = Timer.new()
@onready var game_dev_timer1:Timer = Timer.new()
@onready var game_dev_inprogress:bool = false
@onready var game_running:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_game_info()
	mmenu_popup.connect("index_pressed",self._on_main_menu_index_pressed)
	resmenu_popup.connect("index_pressed",self._on_resmenu_index_pressed)
	game_dev_timer1.connect("timeout",self._on_game_dev_timer1_timeout)
	game_dev_timer1.wait_time = 0.5
	game_dev_timer1.one_shot = true
	add_child(game_dev_timer1)
	
	# Add Game Clock to main game loop:
	game_timer.connect("timeout",self.game_clock_timeout)
	game_timer.wait_time = 0.5 #game_clock.GetWaitTime()
	game_timer.one_shot = true
	add_child(game_timer)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_clock_timeout():
	var i:int = game_clock.Iterations()
	i += 1
	game_clock.SetIterations(i)
	game_clock.SetElaspedMS()
	game_clock.CalcGameDays()
	$GameLayer/GCIGameDaysValuelbl.text = str(game_clock.GameDays())
	game_timer.start()
	pass

func _on_ng_ok_btn_pressed():
	playerData.company_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGCompanyNameStr.text
	playerData.first_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGUserFirstNameStr.text
	playerData.last_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGUserLastNameStr.text
	$GameLayer/NewGameCollectInfo.visible = false
	pass # Replace with function body.

func _on_resmenu_index_pressed(index):
	match index:
		0: # Create Game
			if !game_dev_inprogress:
				$GameLayer/NewGameDev.visible = true
			else:
				gsys.msgdialog("Game Development In-Porgess Right Now","Game Development In-Progress")
		1: # Game History
			$GameLayer/GameDevHistory.visible = true
		4: # Info
			$GameLayer/LoadedGameData.visible = true
	pass

func _on_main_menu_index_pressed(index):
	match index:
		0: # Save Game
			_save_player_data()
		1: # Load Game
			_load_player_data()
		2: # Game Menu
			get_tree().change_scene_to_file("res://scenes/main_menu_control.tscn")
		4: # Quit
			get_tree().quit()
	
	pass # Replace with function body.


func _on_new_game_info_ready():
		
	pass # Replace with function body.

func _save_player_data():
	var gs = gsave.GameSave.new(indie_save_game)
	
	#var fpd = FileAccess.open(save_player_data,FileAccess.WRITE)
	#fpd.store_var(playerData,true)
	
	gs.PlayerData(playerData)
	
	# Convert array of player game classes to dict of dicts:
	var playerGamesDict:Dictionary
	var i:int = 0
	for g in playerGames:
		playerGamesDict.keys().append(i)
		playerGamesDict[i] = g.to_dict()
		i+=1
	
	#var fpg = FileAccess.open(save_player_games,FileAccess.WRITE)
	#fpg.store_var(playerGamesDict,true)
	
	gs.GameData(playerGamesDict)
	gs.WriteSaveGame()
	
	pass

func _load_player_data():
	if FileAccess.file_exists(indie_save_game):
		var gs = gsave.GameSave.new(indie_save_game)
		gs.LoadSavedGame()
		playerData = gs.PlayerData()
		playerGames.clear()
		var i:int = 0
		var gameData = gs.GameData()
		while i < gameData.size():
			var pgd:Dictionary = gameData[i]
			var pgc = pC.playerGameClass.from_dict(pgd)
			playerGames.append(pgc)
			i += 1
				
		# load game info into game elements:
		_load_game_info()
		if !$GameLayer/LoadedGameData.visible:
			$GameLayer/LoadedGameData.visible = true
	
	pass

func _load_game_info():
	$GameLayer/LoadedGameData/LoadedGameInfo/LGICompanyNameStr.text = playerData.company_name
	$GameLayer/LoadedGameData/LoadedGameInfo/LGIUserFirstNameStr.text = playerData.first_name
	$GameLayer/LoadedGameData/LoadedGameInfo/LGIUserLastNameStr.text = playerData.last_name
	_load_player_games()
	pass

func _load_player_games():
	var vbox = $GameLayer/GameDevHistory/HistoryInfo/GDHVertScrollCon/GDHVBoxCon
	# remove any children before starting:
	var vbc = vbox.get_children()
	if vbc.size() > 0:
		var i:int = 0
		while i<vbc.size():
			vbox.remove_child(vbc[i])
			i += 1
	
	var f = load("res://assets/fonts/1joystix.ttf")
	for g in playerGames:
		var ngl = Label.new()
		ngl.add_theme_font_override("font",f)
		ngl.text = g.get_str()
		vbox.add_child(ngl)
	

func _on_game_dev_timer1_timeout():
	var v = $GameLayer/CurrentTotGameProgress.value
	v = v + 0.5
	$GameLayer/CurrentTotGameProgress.value = v
	if $GameLayer/CurrentTotGameProgress.value < 100:
		game_dev_timer1.start()
	else:
		_load_player_games()
		game_dev_inprogress = false
		_pause_game()
		$GameLayer/GameDevComplete.visible = true
	pass


func _on_gdc_ok_btn_pressed():
	$GameLayer/CurrentTotGameProgress.value = 0
	$GameLayer/GameDevComplete.visible = false
	pass # Replace with function body.


func _on_new_game_collect_info_visibility_changed():
	if $GameLayer/NewGameCollectInfo.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.


func _on_game_dev_complete_visibility_changed():
	if $GameLayer/GameDevComplete.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.


func _on_game_dev_history_visibility_changed():
	if $GameLayer/GameDevHistory.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.


func _on_gdh_ok_btn_pressed():
	$GameLayer/GameDevHistory.visible = false
	pass # Replace with function body.

func _on_ngd_ok_btn_pressed():
	var titletxt = $GameLayer/NewGameDev/NGDInfo/NGDGameTitleStr.text
	var topictxt = $GameLayer/NewGameDev/NGDInfo/NGDTopicStr.text
	var genretxt = $GameLayer/NewGameDev/NGDInfo/NGDGenreStr.text
	if game_dev_timer1.is_stopped():			
		var npc = pC.playerGameClass.new(titletxt,topictxt,genretxt,playerData.game_id)
		npc.set_datenow() # TODO: Have system date & time vs. game date & time
		playerGames.append(npc)
		game_dev_inprogress = true
		game_dev_timer1.start()
		$GameLayer/NewGameDev.visible = false
	pass # Replace with function body.

func _on_new_game_dev_visibility_changed():
	if $GameLayer/NewGameDev.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.

func _on_loaded_game_data_visibility_changed():
	if $GameLayer/LoadedGameData.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.


func _on_lgi_ok_btn_pressed():
	$GameLayer/LoadedGameData.visible = false
	pass # Replace with function body.


func _on_gnli_new_game_btn_pressed():
	$GameLayer/GameNewLoad.visible = false
	$GameLayer/NewGameCollectInfo.visible = true
	pass # Replace with function body.


func _on_gnli_load_game_btn_pressed():
	$GameLayer/GameNewLoad.visible = false
	_load_player_data()
	pass # Replace with function body.


func _on_game_new_load_visibility_changed():
	if $GameLayer/GameNewLoad.visible == true:
		$GameLayer/MainGameBackground.visible = false
	else:
		if $GameLayer/MainGameBackground.visible == false:
			$GameLayer/MainGameBackground.visible = true
	pass # Replace with function body.


func _on_gc_pausebtn_pressed():
	#game_dev_timer1.is_stopped()
	_pause_game()
	pass # Replace with function body.


func _on_gc_startbtn_pressed():
	_start_game()
	pass # Replace with function body.


func _on_gci_time_multiplyhs_value_changed(value):
	_pause_game()
	game_clock.CalcMultiplyValues(value)
	game_timer.wait_time = game_clock.GetGameTimerWait()
	game_dev_timer1.wait_time = game_clock.GetGameTimerWait() # Sync of timers
	$GameLayer/GCIDayMultiValuelbl.text = str(value) + "x"
	pass # Replace with function body.

func _start_game():
	if game_timer.is_stopped():
		game_timer.start()
	if game_dev_inprogress && game_dev_timer1.is_stopped():
		game_dev_timer1.start()
	game_running = true

func _pause_game():
	if game_running:
		if !game_timer.is_stopped():
			game_timer.stop()
		if !game_dev_timer1.is_stopped():
			game_dev_timer1.stop()
		gsys.msgdialog("The game, and all activities \n have been paused. \nClick start to resume.","Game Paused")
		game_running = false
