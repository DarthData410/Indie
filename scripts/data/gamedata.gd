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
		"Flight"
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

var GamePhases:Dictionary = {
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
	remake=[
		"Free Bug Fixes",
		"Free Feature Pack",
		"Paid-For Feature Pack",
		"New Platform",
		"New Release"
	],
	retire=[
		"Remove From Market",
		"Publish as OpenSource",
		"AbandonWare"
	]
}	

enum GamePhaseLevels {
	Basic = 0,
	Expereinced = 1,
	Professional = 2,
	Elite = 3,
	Pioneer = 4
}
