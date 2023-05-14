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
		"Jungle",
		"Puzzle",
		"Dance",
		"Music",
		"Fantasy",
		"Civilization Building",
		"Sports",
		"Dark",
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
		"Levels/Level Editor",
		"HUD"
	],
	testing=[
		"Review",
		"Bug Fix",
		"Quality Grading",
	],
	publish=[
		"Marketing",
		"Publish"
	],
	support=[
		"Free Bug Fixes",
		"Free Feature Pack",
		"Paid-For Feature Pack",
		"New Platform",
		"New Release" # Will spawn as new game, tied to previous version release
	],
	retire=[
		"Remove From Market",
		"Publish as OpenSource",
		"AbandonWare"
	]
}	

enum GamePhases {
	design = 0,
	development = 1,
	testing = 2,
	publishing = 3,
	remake = 4,
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
