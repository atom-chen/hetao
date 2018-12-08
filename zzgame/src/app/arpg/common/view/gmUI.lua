----------------------------------------------
-- gm界面
----------------------------------------------
local locdata = {}

local cmd_table = {
	{
		desc = "显示FPS",
		func = function(gmWnd)
			GAME_CONFIG.ShowFps = not GAME_CONFIG.ShowFps
			cc.Director:getInstance():setDisplayStats(GAME_CONFIG.ShowFps)
		end,
	},
	{
		desc = "打印内存信息",
		func = function(gmWnd)
			DumpDebugInfo()
		end,
	},
	{
		desc = "已加载的文件",
		func = function(gmWnd)
			local cnt = 0
			for k, v in pairs(package.loaded) do
				cnt = cnt + 1
				print("----", k, v)
			end
			print("----------------总数量：", cnt)
		end,
	},
	{
		desc = "热更指定文件",
		func = function(gmWnd)
			print("尚未实现")
			proto.req_home_tip_award_way({id="68"})
		end,
	},
	{
		desc = "重新登录",
		func = function(gmWnd)
			KE_SafeDelete(gmWnd)
			ClsStateMachine:GetInstance():ToStateLogin()
		end,
	},
}

----------------------------------------------

clsGmUI = class("clsGmUI", clsBaseUI)

function clsGmUI:ctor(parent)
    clsBaseUI.ctor(self, parent, "uistu/gmUI.csb")
    self:initUI()
    
    --关闭
	utils.RegClickEvent(self.BtnClose, function()
		self:removeSelf()
	end)
	
	self.EditCmd = utils.ReplaceTextField(self.EditCmd)
	
	utils.RegClickEvent(self.BtnRun, function()
		if self.EditCmd:getString() == "" then return end
		pcall( loadstring(self.EditCmd:getString()) )
	end)
end

function clsGmUI:initUI()
	self.AreaAuto:setItemModel(self.ListItem)
	for idx, info in ipairs(cmd_table) do 
		self.AreaAuto:pushBackDefaultItem()
		local testBtn = self.AreaAuto:getItem(idx-1)
		testBtn:setTitleText(info.desc)
		testBtn:addTouchEventListener(function(sender, touchType)
			if touchType ~= ccui.TouchEventType.ended then return end 
			info.func(self)
		end)
	end 
end 
