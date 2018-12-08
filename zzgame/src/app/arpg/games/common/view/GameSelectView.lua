-------------------------
-- 子游戏选择界面
-------------------------
module("ui", package.seeall)

clsGameSelectView = class("clsGameSelectView", clsBaseUI)

function clsGameSelectView:ctor(parent,gameArg)
	clsBaseUI.ctor(self, parent, "uistu/GameSelectView.csb")
	self.Panel_1:setPositionY(self.Panel_1:getPositionY()+GAME_CONFIG.HEIGHT_DIFF)
	g_EventMgr:AddListener(self, "on_req_goucai_all_games", self.on_req_goucai_all_games, self)
end

function clsGameSelectView:dtor()
	
end

function clsGameSelectView:RefleshUI(gid, gameType)
	self.gid = gid
	self.gameType = gameType
	local allgames = ClsGameMgr.GetInstance():GetAllGameInfo()
	if not allgames then 
		return 
	end
	local infos = ClsGameMgr.GetInstance():GetGameInfosOfType(gameType)
	
	self.Panel_1:removeAllChildren()
	
	local count = table.size(infos)
	local SPACE = 2
	local ITEMWID, ITEMHEI = 220, 72
	local ROW, COL = 7, 2
	if count <= 7 then 
		ROW = count 
		COL = 1 
	else 
		ROW = math.ceil(count/2)
		COL = 2
	end
	self.Panel_1:setContentSize( ITEMWID*COL+SPACE*(COL-1), ITEMHEI*ROW+SPACE*(ROW-1) )
	local VIEW_W, VIEW_H = self.Panel_1:getContentSize().width, self.Panel_1:getContentSize().height
	
	local idx = 0
	for curGid, gameInfo in pairs(infos) do
		local BtnMenu = ccui.Layout:create()
		BtnMenu:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		BtnMenu:setBackGroundColor(cc.c3b(255,255,255))
		BtnMenu:setTouchEnabled(true)
		BtnMenu:setContentSize(ITEMWID, ITEMHEI)
		self.Panel_1:addChild(BtnMenu)
		
		idx = idx + 1
		local r = idx%ROW  if r==0 then r=ROW end
		local c = math.ceil(idx/ROW)
		
		local x,y = VIEW_W-ITEMWID*c-SPACE*(c-1), VIEW_H-ITEMHEI*r-SPACE*(r-1)
		BtnMenu:setPosition(x,y)
		
		local labTitle = utils.CreateLabel(gameInfo.name, 28, cc.c3b(0,0,0))
		BtnMenu:addChild(labTitle)
		labTitle:setPosition(ITEMWID/2, ITEMHEI/2)
		
		utils.RegClickEvent(BtnMenu, function() 
			ClsGameMgr.GetInstance():OpenGame(tonumber(curGid), gameInfo.type, gameInfo.name)
			self:removeSelf()
		end)
	end
	
	if COL==2 and idx % 2 ~= 0 then
		idx = idx + 1
		local r = idx%ROW  if r==0 then r=ROW end
		local c = math.ceil(idx/ROW)
		local x,y = VIEW_W-ITEMWID*c-SPACE*(c-1), VIEW_H-ITEMHEI*r-SPACE*(r-1)
		local BtnMenu = ccui.Layout:create()
		BtnMenu:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		BtnMenu:setBackGroundColor(cc.c3b(255,255,255))
		BtnMenu:setContentSize(ITEMWID, ITEMHEI)
		self.Panel_1:addChild(BtnMenu)
		BtnMenu:setPosition(x,y)
	end
end

function clsGameSelectView:on_req_goucai_all_games(recvdata)
	self:RefleshUI(self.gid, self.gameType)
end