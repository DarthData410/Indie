# this file contains game data used with different parts of the game:


var NewGameDataOptions:Dictionary = {
	topics=[
		"Space",
		"Fighting",
		"Racing",
		"Western",
		"City Building",
		"Historical",
		"Military",
		"Dinosaurs",
		"Puzzle",
		"Dance",
		"Music",
		"Fantasy",
		"Civilization Building",
		"Sports",
		"Horror",
		"Humor",
		"Flight",
		"Business",
		"Fitness",
		"Arcade"
	],
	genres=[
		"Action",
		"Adventure",
		"Platformer",
		"Casual",
		"Role Playing",
		"First Person Shooter",
		"Simulation",
		"Strategy",
		"Survival",
		"Tower Defense",
		"Retro"
	],
	platforms=[
		"Mindows",
		"PearOS",
		"Linx",
		"pOS",
		"cyborg",
		"YBox",
		"PlayTrain",
		"Ninrendo",
		"Online"
	],
	audiences=[
		"Everyone",
		"Youth",
		"Young Adult",
		"NC17",
		"Mature"
	],
	styles=[
		"2d",
		"2d-Isometric",
		"2d-Hex",
		"3d",
		"3d-First Person",
		"3d-Third Person"
	],
	sizes=[
		"FirstGame",
		"Small",
		"Medium",
		"Large",
		"Studio"
	]
}

var GamePhaseData:Dictionary = {
	design=[
		"Graphics",
		"User Interface",
		"GamePlay",
		"Audio/FX"
	],
	development=[
		"Game Engine",
		"AI",
		"Levels",
		"Heads-Up-Display (HUD)"
	],
	testing=[
		"Review",
		"Bug Fix",
		"User Testing",
	],
	publish=[
		"Paid For",
		"Free|In-Game Ads",
		"Free|In-App Purchases",
		"Yearly Subscription",
		"OpenSource Sponserships"
	],
	marketing=[
		"Search Engine Ads",
		"Social Media Ads",
		"Influncers",
		"TV"
	],
	support=[
		"Free|Bug Fixes",
		"Free|Feature Pack",
		"Paid-For|Feature Pack",
		"DLC|Downloaded Content",
		"New|Platform Build",
		"New|Release" # Will spawn as new game, tied to previous version release
	],
	retire=[
		"Remove From Market",
		"Publish as OpenSource",
		"AbandonWare"
	]
}	

var ResearchData:Dictionary = {
	type = "",
	key = "", # playerData.RD.[key]
	action = "", # update or new
	value = 0, # XP to spend on type, for action
	tab = "", # current tab object on
	tree = "", # current tree object, within current tab
	treeitem = "" # currently selected item object, from tree, from tab
}

enum GamePhases {
	design = 0,
	development = 1,
	testing = 2,
	publishing = 3,
	support = 4,
	retire = 5
}

enum GamePhaseLevels {
	Basic = 0,
	Expereinced = 1,
	Professional = 2,
	Elite = 3,
	Pioneer = 4
}

var CurrentDesignPhase:Dictionary = {
	Graphics = 0,
	UI = 0,
	GamePlay = 0,
	Audio = 0
}

var CurrentDevPhase:Dictionary = {
	GameEngine = 0,
	AI = 0,
	Levels = 0,
	HUD = 0
}

var CurrentTestPhase:Dictionary = {
	Review = 0,
	BugFix = 0,
	UserTesting = 0
}

var CurrentPointsOfTot:Dictionary = {
	points = 0,
	total = 0
}

var MetaWrapper:Dictionary = {
	Version = {
		Major = 0,
		Minor = 1,
		Build = 1
	},
	Saved = {
		Date = Time.get_date_string_from_system()
	}
}

var MiscWrapper:Dictionary = {
	Objects = []
}
