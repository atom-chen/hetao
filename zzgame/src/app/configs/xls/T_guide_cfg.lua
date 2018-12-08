return {
	["Components"] = {
		["任意区域"] = {},
		["主界面_征途"] = {},
		["世界地图_城市_虎牢关"] = {},
		["城市询问面板_攻占"] = {},
		["主界面_签到"] = {},
		["签到界面_今日"] = {},
	},
	["DetailStep"] = {
		[1] = {
			["Id"] = 1,
			["Component"] = "任意区域",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011001,
		},
		[10001] = {
			["Id"] = 10001,
			["Component"] = "主界面_征途",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011001,
		},
		[10002] = {
			["Id"] = 10002,
			["Component"] = "世界地图_城市_虎牢关",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011002,
		},
		[10003] = {
			["Id"] = 10003,
			["Component"] = "城市询问面板_攻占",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011003,
		},
		[20001] = {
			["Id"] = 20001,
			["Component"] = "主界面_签到",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011001,
		},
		[20002] = {
			["Id"] = 20002,
			["Component"] = "签到界面_今日",
			["Desc"] = "",
			["IsForce"] = true,
			["PreStory"] = 300011001,
		},
	},
	["Guide"] = {
		[100] = {
			["Id"] = 100,
			["CheckAPI"] = function() return true end,
			["Name"] = "新手征战",
			["StepList"] = {
				10001,
				10002,
				10003,
			},
		},
		[200] = {
			["Id"] = 200,
			["CheckAPI"] = function() return true end,
			["Name"] = "签到",
			["StepList"] = {
			--	1,
				20001,
				20002,
			},
		},
	},
}