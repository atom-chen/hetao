-------------------------
-- 辅助库
-------------------------
module("utils", package.seeall)

function TellMe(Txt, DelayTime)
	ClsUIManager.GetInstance():TellMe(Txt, DelayTime)
end

function TellNotice(sNotice,iOrder)
	ClsUIManager.GetInstance():TellNotice(sNotice,iOrder)
end

function TellBarrage(sCont)
	ClsUIManager.GetInstance():TellBarrage(sCont)
end


local g_WaitingQue = 0
local g_sprWaiting

function CheckWaiting()
	if g_WaitingQue <= 0 then 
		g_WaitingQue = 0 
		return 
	end
	local curScene = cc.Director:getInstance():getRunningScene()
	if curScene and not utils.IsValidCCObject(g_sprWaiting) then
		g_sprWaiting = utils.CreateSprite("uistu/others/loadingIcon.png")
		g_sprWaiting:setColor(cc.c3b(200,200,200))
		g_sprWaiting:setPosition(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2)
		curScene:addChild(g_sprWaiting, 999)
		g_sprWaiting:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,360)))
	end
end

function BeginWaiting()
	g_WaitingQue = g_WaitingQue + 1
	CheckWaiting()
end

function FinishWaiting()
	g_WaitingQue = g_WaitingQue - 1
	if g_WaitingQue <= 0 then
		g_WaitingQue = 0
		if utils.IsValidCCObject(g_sprWaiting) then
			KE_SafeDelete(g_sprWaiting)
			g_sprWaiting = nil
		end
	end
end
