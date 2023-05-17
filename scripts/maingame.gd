extends Node2D

# load other supporting GDScript files:
var pC = load("res://scripts/playerClasses.gd").new()
var gsys = load("res://scripts/gamesys.gd").new()
var gc = load("res://scripts/gameClock.gd").new()
var gsave = load("res://scripts/save_system/gamesave.gd").new()
var gdata = load("res://scripts/data/gamedata.gd").new()

# GaveSave vars:
@onready var indie_save_game = "user://indie_game_data.save"
@onready var gs = gsave.GameSave.new(indie_save_game)

# Initialize starting point of playerData dict:
@onready var playerData : Dictionary = pC.playerData
@onready var CurrentPointsOfTot : Dictionary = gdata.CurrentPointsOfTot

@onready var playerGames : Array
@onready var selectedPlayerGame
@onready var lastCreatedGame
@onready var mmenu_popup = $GameLayer/MainMenuBar/MainMenu.get_popup()
@onready var resmenu_popup = $GameLayer/MainMenuBar/Resources.get_popup()

# Phase Data Variables:
# NOTE: These are not persisted as save game data, but rather new
# for each "new game" iteration.:
var CDesignPhase = gdata.CurrentDesignPhase
var CDevPhase = gdata.CurrentDevPhase
var CTestPhase = gdata.CurrentTestPhase
# ******************************************

# Sales Objects:
@onready var GameSalesEvt
@onready var gameSalesMax:int = 20 #TODO Add logic for different publishing options | DEBUG @ 20

# Ratings Objects:
@onready var GameRatings:Dictionary = pC.playerGameRatings

# Research Global Objects:
@onready var CurrentResearch:Dictionary = gdata.ResearchData

# Time Objects:
@onready var game_clock = gc.GameClock.new()
@onready var game_timer:Timer = Timer.new()
@onready var game_dev_timer1:Timer = Timer.new()
@onready var game_dev_timer1_valcheck
@onready var game_dev_testing_inprogress = false
@onready var game_dev_inprogress:bool = false
@onready var game_running:bool = false
@onready var game_sales_timer:Timer = Timer.new()
@onready var game_sales_inprogress:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_game_info()
	mmenu_popup.connect("index_pressed",self._on_main_menu_index_pressed)
	resmenu_popup.connect("index_pressed",self._on_resmenu_index_pressed)
	_init_timers()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init_timers():
	# Add Game Clock to main game loop:
	game_timer.connect("timeout",self.game_clock_timeout)
	game_timer.wait_time = game_clock.GetBaseDay()
	game_timer.one_shot = true
	add_child(game_timer)
	
	# Add Game Dev Timer Clock:
	game_dev_timer1.connect("timeout",self._on_game_dev_timer1_timeout)
	game_dev_timer1.wait_time = game_clock.GetBaseDay()
	game_dev_timer1.one_shot = true
	add_child(game_dev_timer1)
	
	# Add game sales timer:
	game_sales_timer.connect("timeout",self.game_sales_timeout)
	game_sales_timer.wait_time = game_clock.GetBaseDay()
	game_sales_timer.one_shot = true
	add_child(game_sales_timer)

func game_sales_timeout():
	GameSalesEvt = pC.GameSalesEvent.new(lastCreatedGame.get_key(),lastCreatedGame.gameSales,game_clock.GameDays(),9.99) # TODO: Remove hardcoded GamePrice of $9.99
	GameSalesEvt.calcValue(1,1) # TODO: Logic for calculating sales by.
	lastCreatedGame.gameSales = GameSalesEvt.EventArray
	print(lastCreatedGame.gameSales)
	if lastCreatedGame.gameSalesDays <= gameSalesMax:
		lastCreatedGame.gameSalesDays += 1
		game_sales_timer.start()
	else:
		game_sales_inprogress = false
		_pause_game()
		gsys.msgdialog("Place holder for game sales over \n Total Sales: "+str(lastCreatedGame.calc_gameSalesTot()),"Game Sales End Place Holder")
	pass

func game_clock_timeout():
	var i:int = game_clock.Iterations()
	i += 1
	game_clock.SetIterations(i)
	game_clock.SetElaspedMS()
	game_clock.CalcGameDays()
	$GameLayer/GCIGameDaysValuelbl.text = str(game_clock.GameDays())
	game_timer.start()
	

func _on_ng_ok_btn_pressed():
	playerData.company_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGCompanyNameStr.text
	playerData.first_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGUserFirstNameStr.text
	playerData.last_name = $GameLayer/NewGameCollectInfo/NewGameInfo/NGUserLastNameStr.text
	$GameLayer/NewGameCollectInfo.visible = false
	

func _create_new_game():
	if !game_dev_inprogress:
		$GameLayer/NewGameDev.visible = true
	else:
		gsys.msgdialog("Game Development In-Porgess Right Now","Game Development In-Progress")

func _on_resmenu_index_pressed(index):
	match index:
		0: # Create Game
			_create_new_game()
		1: # Research
			_on_research_btn_pressed()
		2: # Revenue Report
			_on_revenue_pressed()
		3: # Bank Report
			_on_bank_pressed()	
		5: # Game History
			$GameLayer/GameDevHistory.visible = true
		6: # Info
			$GameLayer/LoadedGameData.visible = true

func _on_main_menu_index_pressed(index):
	match index:
		0: # Save Game
			_save_player_data()
			gsys.msgdialog("Your progress has been saved.","Game Saved")
		1: # Load Game
			_load_player_data()
			gsys.msgdialog("Your game has been loaded.","Game Loaded")
		2: # Game Menu
			get_tree().change_scene_to_file("res://scenes/main_menu_control.tscn")
		4: # Quit
			get_tree().quit()


func _save_player_data():
	gs.Meta(game_clock.to_dict()) # using meta section to save game clock state
	gs.PlayerData(playerData)
	# Convert array of player game classes to dict of dicts:
	gs.GameData(pC.playerGameClass.get_playerGamesDict(playerGames))
	gs.Misc(GameRatings)
	gs.WriteSaveGame()
	


func _load_player_data():
	if FileAccess.file_exists(indie_save_game):
		gs.LoadSavedGame()
		GameRatings = gs.Misc()
		game_clock = gc.GameClock.from_dict(gs.Meta()) # loaded GameClock from meta
		$GameLayer/GCIGameDaysValuelbl.text = str(game_clock.GameDays())
		playerData = gs.PlayerData()
		var gameData = gs.GameData()
		
		playerGames.clear()
		var i:int = 0
		while i < gameData.size():
			var pgd:Dictionary = gameData[i]
			var pgc = pC.playerGameClass.from_dict(pgd)
			playerGames.append(pgc)
			i += 1
				
		# load game info into game elements:
		_load_game_info()
		if !$GameLayer/LoadedGameData.visible:
			$GameLayer/LoadedGameData.visible = true
	
	

func _load_game_info():
	$GameLayer/LoadedGameData/LoadedGameInfo/LGICompanyNameStr.text = playerData.company_name
	$GameLayer/LoadedGameData/LoadedGameInfo/LGIUserFirstNameStr.text = playerData.first_name
	$GameLayer/LoadedGameData/LoadedGameInfo/LGIUserLastNameStr.text = playerData.last_name
	_load_player_games()
	_load_gamedata_values()
	

func _load_player_games():
	var preGames = $GameLayer/GameDevHistory/HistoryInfo/PreviousGames
	preGames.clear()
	for g in playerGames:
		preGames.add_item(g.get_str())

func _on_game_dev_timer1_timeout():
	var v = $GameLayer/CurrentTotGameProgress.value
	v = v + 1
	$GameLayer/CurrentTotGameProgress.value = v
	if $GameLayer/CurrentTotGameProgress.value < game_dev_timer1_valcheck:
		game_dev_timer1.start()
	else:
		_load_player_games()
		game_dev_inprogress = false
		_pause_game()
		var gtitle = $GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameTitleLbl
		var gtopic = $GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameTopicLbl
		var ggenre = $GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameGenreLbl
		var gplat = $GameLayer/GameDevComplete/GameDevCompletePnl/GDCGamePlatformLbl
		var cpg = playerGames[playerGames.size()-1]
		gtitle.text = gtitle.text + " " + cpg.title
		gtopic.text = gtopic.text + " " + cpg.topic
		ggenre.text = ggenre.text + " " + cpg.genre
		gplat.text = gplat.text + " " + cpg.platform
		if cpg.get_platform_spritetype() == 0: # Desktop
			$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformDesktopA.visible = true
		elif cpg.get_platform_spritetype() == 1: # Web
			$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformWebA.visible = true
		elif cpg.get_platform_spritetype() == 2: # Mobile
			$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformMobileA.visible = true
		elif cpg.get_platform_spritetype() == 3: # Game System
			$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformGameSystemA.visible = true
		$GameLayer/GameDevComplete.visible = true
	


func _on_gdc_ok_btn_pressed():
	$GameLayer/CurrentTotGameProgress.value = 0
	$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformDesktopA.visible = false
	$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformWebA.visible = false
	$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformGameSystemA.visible = false
	$GameLayer/GameDevComplete/GameDevCompletePnl/PlatformMobileA.visible = false
	$GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameTitleLbl.text = "Title:"
	$GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameTopicLbl.text = "Topic:"
	$GameLayer/GameDevComplete/GameDevCompletePnl/GDCGameGenreLbl.text = "Genre:"
	$GameLayer/GameDevComplete/GameDevCompletePnl/GDCGamePlatformLbl.text = "Platform:"
	$GameLayer/GameDevComplete.visible = false
	# TODO: Finalize better sync between timers, using game clock object instance.:
	lastCreatedGame = playerGames[playerGames.size()-1]
	print(lastCreatedGame.phaseXPused)
	_rate_game()
	_player_research()
	game_timer.start()
	game_running = true
	game_sales_timer.start()
	game_sales_inprogress = true

func _rate_game():
	var gre = pC.GameRatingsEvent.new(lastCreatedGame.get_key(),GameRatings.Ratings,game_clock.GameDays(),lastCreatedGame,playerData.RD) # TODO: Add agent, DEBUG default for now
	var rate:float = gre.calcValue(1,1)
	gsys.msgdialog("Game Rated By: "+gre.Agent+"\n\nRating of: "+str(rate),"Game Rating Place Holder")
	GameRatings.Ratings = gre.EventArray

func _player_research():
	#playerData.RD.topics.Space.XP = 30
	# update research points based on game creation options:
	
	var pr = pC.playerResearch.new(playerData)
	pr.calcResearch()
	playerData = pr.playerData 

func _on_new_game_collect_info_visibility_changed():
	if $GameLayer/NewGameCollectInfo.visible == true:
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	


func _on_game_dev_complete_visibility_changed():
	if $GameLayer/GameDevComplete.visible == true:
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	


func _on_game_dev_history_visibility_changed():
	if $GameLayer/GameDevHistory.visible == true:
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	


func _on_gdh_ok_btn_pressed():
	$GameLayer/GameDevHistory.visible = false
	$GameLayer/GameDevHistoryDetails.visible = true

func _on_ngd_next_btn_pressed():
	var titlestr = $GameLayer/NewGameDev/NGDInfo/NGDGameTitleStr
	var topiclist = $GameLayer/NewGameDev/NGDInfo/NGDTopicsList
	var genrelist = $GameLayer/NewGameDev/NGDInfo/NGDGenresList
	if len(titlestr.text) > 0 and topiclist.is_anything_selected() and genrelist.is_anything_selected():
		$GameLayer/NewGameDev/NGDInfo.visible = false
		$GameLayer/NewGameDev/NGDInfo2.visible = true
	else:
		gsys.msgdialog("All fields must be filled / selected before proceeding. \n Please fill out completely, then click 'next'.","Can't Continue...")

func _on_ngd_ok_btn_pressed():
	var stylelist = $GameLayer/NewGameDev/NGDInfo2/NGDStyleList
	var sizelist = $GameLayer/NewGameDev/NGDInfo2/NGDSizeList
	var audiencelist = $GameLayer/NewGameDev/NGDInfo2/NGDAudienceList
	var platformlist = $GameLayer/NewGameDev/NGDInfo2/NGDPlatformList
	if stylelist.is_anything_selected() and sizelist.is_anything_selected() and audiencelist.is_anything_selected() and platformlist.is_anything_selected():
		$GameLayer/NewGameDev/NGDInfo2.visible = false
		CDesignPhase = gdata.CurrentDesignPhase
		CDevPhase = gdata.CurrentDevPhase
		CTestPhase = gdata.CurrentTestPhase
		$GameLayer/NewGameDev/NGDDesignPhase/NGDTotPointslbl.text = str(pC.get_phasetot(playerData.phaseXP.design))
		$GameLayer/NewGameDev/NGDDevPhase/NGDTotPointslbl.text = str(pC.get_phasetot(playerData.phaseXP.development))
		$GameLayer/NewGameDev/NGDTestPhase/NGDTotPointslbl.text = str(pC.get_phasetot(playerData.phaseXP.testing))
		$GameLayer/NewGameDev/NGDDesignPhase.visible = true
		
	else:
		gsys.msgdialog("All fields must be filled / selected before proceeding. \n Please fill out completely, then click 'next'.","Can't Continue...")

func _strip2gameoptionID(v:String) -> String:
	var ret:String = ""
	var i:int = v.find("-",0)
	ret = v.substr(0,i-1)
	return ret

func _on_NewGameDev_complete():
	var titlestr = $GameLayer/NewGameDev/NGDInfo/NGDGameTitleStr
	var topiclist = $GameLayer/NewGameDev/NGDInfo/NGDTopicsList
	var genrelist = $GameLayer/NewGameDev/NGDInfo/NGDGenresList
	var stylelist = $GameLayer/NewGameDev/NGDInfo2/NGDStyleList
	var sizelist = $GameLayer/NewGameDev/NGDInfo2/NGDSizeList
	var audiencelist = $GameLayer/NewGameDev/NGDInfo2/NGDAudienceList
	var platformlist = $GameLayer/NewGameDev/NGDInfo2/NGDPlatformList
	
	if stylelist.is_anything_selected() and sizelist.is_anything_selected() and audiencelist.is_anything_selected() and platformlist.is_anything_selected():
		var titletxt = titlestr.text
		var topictxt = _strip2gameoptionID(topiclist.get_item_text(topiclist.get_selected_items()[0]))
		var genretxt = _strip2gameoptionID(genrelist.get_item_text(genrelist.get_selected_items()[0]))
		var styletxt = _strip2gameoptionID(stylelist.get_item_text(stylelist.get_selected_items()[0]))
		var sizetxt = _strip2gameoptionID(sizelist.get_item_text(sizelist.get_selected_items()[0]))
		var audiencetxt = _strip2gameoptionID(audiencelist.get_item_text(audiencelist.get_selected_items()[0]))
		var platformtxt = _strip2gameoptionID(platformlist.get_item_text(platformlist.get_selected_items()[0]))
		
		if game_dev_timer1.is_stopped():			
			var npc = pC.playerGameClass.new(titletxt,topictxt,genretxt,styletxt,sizetxt,audiencetxt,platformtxt,playerData.game_id)
			npc.set_datenow() # TODO: Have system date & time vs. game date & time
			# Set timer1 wait based on the phaseXP & Game Size calculations:
			npc.calc_xpwait(playerData.phaseXP,game_clock.GetBaseDay()) # ONLY CALL ONCE ***
			
			npc.price = 9.99 # Place-Holder for price. Need logic added.
			
			# ************* FOR DESIGN PHASE ***********
			var cdesign_phase_points = _total_design_values()
			playerData.phasePoints.design = int(playerData.phasePoints.design) + cdesign_phase_points
			var cphaseXPdesign = playerData.phaseXP.design
			playerData.phaseXP.design = _calc_PhaseXP_from_Points(playerData.phasePoints.design)
			if playerData.phaseXP.design != cphaseXPdesign:
				gsys.msgdialog("You have leveled up your XP for: Design","Leveled Up!")
			# ***************************************
			
			# ************* FOR DEV PHASE ***********
			var cdev_phase_points = _total_dev_values()
			playerData.phasePoints.development = int(playerData.phasePoints.development) + cdev_phase_points
			var cphaseXPdev = playerData.phaseXP.development
			playerData.phaseXP.development = _calc_PhaseXP_from_Points(playerData.phasePoints.development)
			if playerData.phaseXP.development != cphaseXPdev:
				gsys.msgdialog("You have leveled up your XP for: Dev","Leveled Up!")
			# ***************************************
			
			# ************* FOR DEV PHASE ***********
			var ctest_phase_points = _total_test_values()
			playerData.phasePoints.testing = int(playerData.phasePoints.testing) + ctest_phase_points
			var cphaseXPtest = playerData.phaseXP.testing
			playerData.phaseXP.testing = _calc_PhaseXP_from_Points(playerData.phasePoints.testing)
			if playerData.phaseXP.testing != cphaseXPtest:
				gsys.msgdialog("You have leveled up your XP for: Testing","Leveled Up!")
			# ***************************************
			
			var PhaseXPUsed:Dictionary = pC.gamePhaseXPUsed
			PhaseXPUsed["design"] = cdesign_phase_points
			PhaseXPUsed["development"] = cdev_phase_points
			PhaseXPUsed["testing"] = ctest_phase_points
			npc.phaseXPused = PhaseXPUsed
			
			# ********* calc total progress for now *****
			# TODO: Move to each section having their own progress
			# *******************************************
			$GameLayer/CurrentTotGameProgress.max_value = round(
					(	
						cdesign_phase_points
						*float(npc.phaseXP.design)
					) +
					(
						cdev_phase_points
						*float(npc.phaseXP.development)
					) +
					(
						ctest_phase_points
						*float(npc.phaseXP.testing)
					)
				)
			game_dev_timer1_valcheck = $GameLayer/CurrentTotGameProgress.max_value
			# *********** END CALC **********************
			
			
			playerGames.append(npc)
			game_dev_inprogress = true
			
			game_dev_timer1.start()
			# clear selections:
			titlestr.text = ""
			topiclist.deselect_all()
			genrelist.deselect_all()
			stylelist.deselect_all()
			sizelist.deselect_all()
			audiencelist.deselect_all()
			platformlist.deselect_all()
			$GameLayer/NewGameDev/NGDInfo2.visible = false
			$GameLayer/NewGameDev/NGDInfo.visible = true
			$GameLayer/NewGameDev.visible = false
			if !game_running:
				_start_game()
	else:
		gsys.msgdialog("All fields must be filled / selected before proceeding. \n Please fill out completely, then click 'ok'.","Can't Continue...")
	

func _calc_PhaseXP_from_Points(v:int):
	var ret:int = 0
	
	if v>=100 and v<225: # Basic -> Exp
		ret = 2
	elif v>=225 and v<450: # Exp -> Pro
		ret = 3
	elif v>=450 and v<750: # Pro -> Elite
		ret = 4
	elif v>=750: # Elite -> Pioneer+
		ret = 5
	else:
		ret = 1 # Basic
	return ret
	
func _on_new_game_dev_visibility_changed():
	if $GameLayer/NewGameDev.visible == true:
		_load_gamedata_values()
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	

func _on_loaded_game_data_visibility_changed():
	if $GameLayer/LoadedGameData.visible == true:
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	


func _on_lgi_ok_btn_pressed():
	$GameLayer/LoadedGameData.visible = false
	


func _on_gnli_new_game_btn_pressed():
	$GameLayer/GameNewLoad.visible = false
	$GameLayer/NewGameCollectInfo.visible = true
	


func _on_gnli_load_game_btn_pressed():
	$GameLayer/GameNewLoad.visible = false
	_load_player_data()
	


func _on_game_new_load_visibility_changed():
	if $GameLayer/GameNewLoad.visible == true:
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	


func _on_gc_pausebtn_pressed():
	#game_dev_timer1.is_stopped()
	_pause_game()
	


func _on_gc_startbtn_pressed():
	_start_game()
	


func _on_gci_time_multiplyhs_value_changed(value):
	_pause_game()
	game_clock.CalcMultiplyValues(value)
	game_timer.wait_time = game_clock.GetGameTimerWait()
	game_dev_timer1.wait_time = game_dev_timer1.wait_time*game_clock.GetGameTimerWaitPercent()
	$GameLayer/GCIDayMultiValuelbl.text = str(value) + "x"
	

func _start_game():
	if game_timer.is_stopped():
		game_timer.start()
	if game_dev_inprogress && game_dev_timer1.is_stopped():
		game_dev_timer1.start()
	if game_sales_inprogress && game_sales_timer.is_stopped():
		game_sales_timer.start()
	game_running = true

func _pause_game():
	if game_running:
		if !game_timer.is_stopped():
			game_timer.stop()
		if !game_dev_timer1.is_stopped():
			game_dev_timer1.stop()
		if !game_sales_timer.is_stopped():
			game_sales_timer.stop()
		#gsys.msgdialog("The game, and all activities \n have been paused. \nClick start to resume.","Game Paused")
		game_running = false

func _load_gamedata_values():
	var nv:String
	# NewGameDataOptions Load:
	var NGDOps:Dictionary = gdata.NewGameDataOptions
	# Topics List:
	$GameLayer/NewGameDev/NGDInfo/NGDTopicsList.clear()
	for k in playerData.RD.topics.keys():
		nv = k +" - Level: " + str(playerData.RD.topics[k]["level"])
		$GameLayer/NewGameDev/NGDInfo/NGDTopicsList.add_item(nv)
	# Genres List:
	$GameLayer/NewGameDev/NGDInfo/NGDGenresList.clear()
	for k in playerData.RD.genres.keys():
		nv = k+" - Level: " + str(playerData.RD.genres[k]["level"])
		$GameLayer/NewGameDev/NGDInfo/NGDGenresList.add_item(nv)
	# Styles List:
	$GameLayer/NewGameDev/NGDInfo2/NGDStyleList.clear()
	for k in playerData.RD.styles.keys():
		nv = playerData.RD.styles[k]["label"]+" - Level: " + str(playerData.RD.styles[k]["level"])
		$GameLayer/NewGameDev/NGDInfo2/NGDStyleList.add_item(nv)
	# Sizes List:
	$GameLayer/NewGameDev/NGDInfo2/NGDSizeList.clear()
	for k in playerData.RD.sizes.keys():
		nv = k+" - Level: " + str(playerData.RD.sizes[k]["level"])
		$GameLayer/NewGameDev/NGDInfo2/NGDSizeList.add_item(nv)
	# Audiences List:
	$GameLayer/NewGameDev/NGDInfo2/NGDAudienceList.clear()
	for k in playerData.RD.audiences.keys():
		nv = k+" - Level: " + str(playerData.RD.audiences[k]["level"])
		$GameLayer/NewGameDev/NGDInfo2/NGDAudienceList.add_item(nv)
	# Platforms List:
	$GameLayer/NewGameDev/NGDInfo2/NGDPlatformList.clear()
	for k in playerData.RD.platforms.keys():
		nv = k+" - Level: " + str(playerData.RD.platforms[k]["level"])
		$GameLayer/NewGameDev/NGDInfo2/NGDPlatformList.add_item(nv)

# ********** DESIGN PHASE UI ********************************************
func _on_h_slide_graphics_value_changed(value):
	_design_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDesignPhase/HSlideGraphics,
		$GameLayer/NewGameDev/NGDDesignPhase/NGDGraphicsValuelbl,
		"CDesignPhase.Graphics"
	)

func _on_h_slide_ui_value_changed(value):
	_design_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDesignPhase/HSlideUI,
		$GameLayer/NewGameDev/NGDDesignPhase/NGDUIValuelbl,
		"CDesignPhase.UI"
	)

func _on_h_slide_game_play_value_changed(value):
	_design_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDesignPhase/HSlideGamePlay,
		$GameLayer/NewGameDev/NGDDesignPhase/NGDGamePlayValuelbl,
		"CDesignPhase.GamePlay"
	)

func _on_h_slide_audio_value_changed(value):
	_design_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDesignPhase/HSlideAudio,
		$GameLayer/NewGameDev/NGDDesignPhase/NGDAudioValuelbl,
		"CDesignPhase.Audio"
	)

func test_designphase(x) -> int:
	var ret:int = 0
	if x.name == "HSlideGraphics":
		ret = x.value + CDesignPhase.UI + CDesignPhase.GamePlay + CDesignPhase.Audio 
	elif x.name == "HSlideUI":
		ret = x.value + + CDesignPhase.Graphics + CDesignPhase.GamePlay + CDesignPhase.Audio
	elif x.name == "HSlideGamePlay":
		ret = x.value + CDesignPhase.Graphics + CDesignPhase.UI + CDesignPhase.Audio
	elif x.name == "HSlideAudio":
		ret = x.value + + CDesignPhase.Graphics + CDesignPhase.UI + CDesignPhase.GamePlay
	return ret

# Design Phase XP Check, used by each slider:
func _design_phase_slider_xp_check(x,y,z):
	if test_designphase(x) > pC.get_phasetot(playerData.phaseXP.design):
		gsys.nexp()
		x.value = 0
	else:
		y.text = str(x.value)
		if z == "CDesignPhase.Audio":
			CDesignPhase.Audio = x.value
		elif z == "CDesignPhase.GamePlay":
			CDesignPhase.GamePlay = x.value
		elif z == "CDesignPhase.UI":
			CDesignPhase.UI = x.value
		elif z == "CDesignPhase.Graphics":
			CDesignPhase.Graphics = x.value
		$GameLayer/NewGameDev/NGDDesignPhase/NGDUsedPointslbl.text = str(pC.get_phaseused(CDesignPhase))

func _total_design_values() -> int:
	var ret:int 
	ret = CDesignPhase.Graphics + CDesignPhase.UI + CDesignPhase.GamePlay + CDesignPhase.Audio
	return ret

func _on_ngddesignp_next_btn_pressed():
	$GameLayer/NewGameDev/NGDDesignPhase.visible = false
	# first process design stage.. #TODO Add new "in-progress" panel/dialog
	# for now, colllecting more and adding to the total
	# also need to add "on-going info" and back buttons...
	
	$GameLayer/NewGameDev/NGDDevPhase.visible = true

# *************** END DESIGN PHASE UI ************************

# *************** DEV PHASE UI ************************

func _on_h_slide_gameengine_value_changed(value):
	_dev_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDevPhase/HSlideGameEngine,
		$GameLayer/NewGameDev/NGDDevPhase/NGDGameEngineValuelbl,
		"CDevPhase.GameEngine")
	

func _on_h_slide_ai_value_changed(value):
	_dev_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDevPhase/HSlideAI,
		$GameLayer/NewGameDev/NGDDevPhase/NGDAIValuelbl,
		"CDevPhase.AI"
	)

func _on_h_slide_levels_value_changed(value):
	_dev_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDevPhase/HSlideLevels,
		$GameLayer/NewGameDev/NGDDevPhase/NGDLevelsValuelbl,
		"CDevPhase.Levels"
	)

func _on_h_slide_hud_value_changed(value):
	_dev_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDDevPhase/HSlideHUD,
		$GameLayer/NewGameDev/NGDDevPhase/NGDHUDValuelbl,
		"CDevPhase.HUD"
	)


func test_devphase(x) -> int:
	var ret:int = 0
	if x.name == "HSlideGameEngine":
		ret = x.value + CDevPhase.AI + CDevPhase.Levels + CDevPhase.HUD 
	elif x.name == "HSlideAI":
		ret = x.value + + CDevPhase.GameEngine + CDevPhase.Levels + CDevPhase.HUD
	elif x.name == "HSlideLevels":
		ret = x.value + CDevPhase.GameEngine + CDevPhase.AI + CDevPhase.HUD
	elif x.name == "HSlideHUD":
		ret = x.value + + CDevPhase.GameEngine + CDevPhase.AI + CDevPhase.Levels
	return ret

# Dev Phase XP Check, used by each slider:
func _dev_phase_slider_xp_check(x,y,z):
	if test_devphase(x) > pC.get_phasetot(playerData.phaseXP.development):
		gsys.nexp()
		x.value = 0
	else:
		y.text = str(x.value)
		if z == "CDevPhase.GameEngine":
			CDevPhase.GameEngine = x.value
		elif z == "CDevPhase.AI":
			CDevPhase.AI = x.value
		elif z == "CDevPhase.Levels":
			CDevPhase.Levels = x.value
		elif z == "CDevPhase.HUD":
			CDevPhase.HUD = x.value
		$GameLayer/NewGameDev/NGDDevPhase/NGDUsedPointslbl.text = str(pC.get_phaseused(CDevPhase))


func _total_dev_values() -> int:
	var ret:int
	ret = CDevPhase.GameEngine + CDevPhase.AI + CDevPhase.Levels + CDevPhase.HUD
	return ret

func _on_ngddevp_next_btn_pressed():
	$GameLayer/NewGameDev/NGDDevPhase.visible = false
	$GameLayer/NewGameDev/NGDTestPhase.visible = true

# *************** END DEV PHASE UI ************************


# *************** SART TEST PHASE UI ************************


func _on_h_slide_review_value_changed(value):
	_test_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDTestPhase/HSlideReview,
		$GameLayer/NewGameDev/NGDTestPhase/NGDReviewValuelbl,
		"CTestPhase.Review")
	

func _on_h_slide_bugfix_value_changed(value):
	_test_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDTestPhase/HSlideBugFix,
		$GameLayer/NewGameDev/NGDTestPhase/NGDBugFixValuelbl,
		"CTestPhase.BugFix"
	)

func _on_h_slide_usertesting_value_changed(value):
	_test_phase_slider_xp_check(
		$GameLayer/NewGameDev/NGDTestPhase/HSlideUserTesting,
		$GameLayer/NewGameDev/NGDTestPhase/NGDUserTestingValuelbl,
		"CTestPhase.UserTesting"
	)

func test_testphase(x) -> int:
	var ret:int = 0
	if x.name == "HSlideReview":
		ret = x.value + CTestPhase.BugFix + CTestPhase.UserTesting
	elif x.name == "HSlideBugFix":
		ret = x.value + + CTestPhase.Review + CTestPhase.UserTesting
	elif x.name == "HSlideUserTesting":
		ret = x.value + CTestPhase.Review + CTestPhase.BugFix
	return ret

# Dev Phase XP Check, used by each slider:
func _test_phase_slider_xp_check(x,y,z):
	if test_testphase(x) > pC.get_phasetot(playerData.phaseXP.testing):
		gsys.nexp()
		x.value = 0
	else:
		y.text = str(x.value)
		if z == "CTestPhase.Review":
			CTestPhase.Review = x.value
		elif z == "CTestPhase.BugFix":
			CTestPhase.BugFix = x.value
		elif z == "CTestPhase.UserTesting":
			CTestPhase.TestPhase = x.value
		$GameLayer/NewGameDev/NGDTestPhase/NGDUsedPointslbl.text = str(pC.get_phaseused(CTestPhase))


func _total_test_values() -> int:
	var ret:int
	ret = CTestPhase.Review + CTestPhase.BugFix + CTestPhase.UserTesting
	return ret

func _on_ngdtestp_next_btn_pressed():
	_on_NewGameDev_complete()
	$GameLayer/NewGameDev/NGDTestPhase.visible = false
	

# *************** END TEST PHASE UI ************************


func _on_revenue_pressed():
	gsys.msgdialog("place holder for game revenue report.","place holder revenue")

func _on_bank_pressed():
	gsys.msgdialog("place holder for game bank report.","place holder bank")
	
func _on_research_btn_pressed():
	$GameLayer/Research.visible = true

func _on_create_game_btn_pressed():
	_create_new_game()

func _on_previous_games_item_clicked(index, at_position, mouse_button_index):
	var ghskey = $GameLayer/GameDevHistory/HistoryInfo/PreviousGames.get_selected_items()[0]
	selectedPlayerGame = playerGames[ghskey]


# BACK BUTTONS for new game create / development:
func _on_gdhd_ok_btn_pressed():
	$GameLayer/GameDevHistoryDetails.visible = false
	$GameLayer/GameDevHistory.visible = true

func _on_game_dev_history_details_draw():
	$GameLayer/BackgroundTxtBtn.visible = false
	$GameLayer/GameDevHistoryDetails/HistoryInfo/GDHGameDevHistDetLbl.text = selectedPlayerGame.title

func _on_gdh_exit_btn_pressed():
	$GameLayer/GameDevHistory.visible = false


func _on_ngd_back_btn_pressed():
	$GameLayer/NewGameDev/NGDInfo2.visible = false
	$GameLayer/NewGameDev/NGDInfo.visible = true


func _on_ngddp_back_btn_pressed():
	$GameLayer/NewGameDev/NGDDesignPhase.visible = false
	$GameLayer/NewGameDev/NGDInfo2.visible = true


func _on_ngddevp_back_btn_pressed():
	$GameLayer/NewGameDev/NGDDevPhase.visible = false
	$GameLayer/NewGameDev/NGDDesignPhase.visible = true


func _on_ngdtestp_back_btn_pressed():
	$GameLayer/NewGameDev/NGDTestPhase.visible = false
	$GameLayer/NewGameDev/NGDDevPhase.visible = true

# END BACK BUTTONS FOR NEW GAME Create / Development


func _on_background_txt_btn_pressed():
	gsys.msgdialog("Place holder for pop-up resources menu.","Background Resource Placeholder")
	pass # Replace with function body.


func _on_res_ok_btn_pressed():
	$GameLayer/Research.visible = false
	pass # Replace with function body.


func _on_research_visibility_changed():
	if $GameLayer/Research.visible == true:
		var RD = pC.playerResearch.new(playerData)
		RD.calcResearch()
		playerData = RD.playerData
		$GameLayer/Research/ResInfo/XPBankValuelbl.text = str(playerData.RD.XPBank.Balance)
		$GameLayer/BackgroundTxtBtn.visible = false
	else:
		if $GameLayer/BackgroundTxtBtn.visible == false:
			$GameLayer/BackgroundTxtBtn.visible = true
	pass # Replace with function body.


func _on_tab_bar_tab_changed(tab):
	var taba:Array
	taba.append($GameLayer/Research/ResInfo/Topics)
	taba.append($GameLayer/Research/ResInfo/Genres)
	taba.append($GameLayer/Research/ResInfo/Platforms)
	taba.append($GameLayer/Research/ResInfo/Audiences)
	taba.append($GameLayer/Research/ResInfo/Styles)
	taba.append($GameLayer/Research/ResInfo/Sizes)
	
	taba[tab].visible = true
	taba.pop_at(tab)
	for t in taba:
		t.visible = false


func _on_topics_draw():
	
	$GameLayer/Research/ResInfo/Topics/TopicLvlXP.value = 0
	var tree = $GameLayer/Research/ResInfo/Topics/TopicsTree
	tree.clear()
	tree.set_column_title(0,"Topics")
	var root = tree.create_item()
	tree.hide_root = true
	for k in playerData.RD.topics.keys():
		var child = tree.create_item(root)
		child.set_text(0, k)
	


func _on_topics_tree_item_selected():
	var RD = pC.playerResearch.new(playerData)
	RD.calcResearch()
	playerData = RD.playerData
	var tree = $GameLayer/Research/ResInfo/Topics/TopicsTree
	var ts = tree.get_selected()
	$GameLayer/Research/ResInfo/Topics/TopicValuelbl.text = ts.get_text(0)
	var td:Dictionary = playerData.RD.topics[ts.get_text(0)]
	$GameLayer/Research/ResInfo/Topics/LevelValuelbl.text = str(td.level)
	$GameLayer/Research/ResInfo/Topics/XPValuelbl.text = str(td.XP)
	$GameLayer/Research/ResInfo/Topics/TopicLvlXP.max_value = td.XP + td.NextXP
	$GameLayer/Research/ResInfo/Topics/TopicLvlXP.value = td.XP
	$GameLayer/Research/ResInfo/Topics/NextXPValuelbl.text = str(td.NextXP)
	CurrentResearch.type = "topics"
	CurrentResearch.key = ts.get_text(0)
	CurrentResearch.tab = $GameLayer/Research/ResInfo/Topics

func _on_res_spend_btn_pressed():
	var spend = int($GameLayer/Research/ResInfo/XP2SpendEdit.text)
	if spend > 0:
		CurrentResearch.value = spend
		CurrentResearch.action = "update"
		var RD = pC.playerResearch.new(playerData)
		RD.addUpdateData(CurrentResearch.type,CurrentResearch.key,CurrentResearch.value)
		RD.calcResearch()
		playerData = RD.playerData
		CurrentResearch.tab.visible = false
		CurrentResearch.tab.visible = true
