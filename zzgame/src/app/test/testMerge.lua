----------------------
-- test 3D
----------------------
local test = {}

local imglist = {
	"xxxxx1.png",
	"xxxxx2.png",
	"xxxxx3.png",
	"xxxxx4.png",
	"xxxxx5.png",
}

local img9list = {
	"yyyyyy1.png",
	"yyyyyy2.png",
	"yyyyyy3.png",
	"yyyyyy4.png",
	"yyyyyy5.png",
}
	
function test.test_merge()
	local inst = xianyou.TextureMerge:getInstance()
	local mainPanel = ClsUIManager.GetInstance():GetWindow("clsMainPanel")
	for i=1, #imglist do 
		local spr = inst:createSprite(imglist[i],false)
		if spr then 
			mainPanel:addChild(spr) 
			spr:setPosition((i-3)*150, 0)
		end
		
		local spr9 = inst:createScale9Sprite(img9list[i],false)
		if spr9 then
			mainPanel:addChild(spr9) 
			spr9:setPosition((i-3)*190, 100)
			spr9:setContentSize(150,150)
		end
	end
	inst:addString("我的abc")
	inst:saveToFile(GAME_CONFIG.LOCAL_DIR .. "/merge.png")
end

return test
