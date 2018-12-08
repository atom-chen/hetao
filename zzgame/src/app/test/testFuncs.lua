-----------------------------
-- 功能测试
-----------------------------
local test = {}

function test.testContainerInterface(parent)
	local scrollView = ccui.ScrollView:create()
	scrollView:setDirection(ccui.ScrollViewDir.both)
	scrollView:setBounceEnabled(true)
	scrollView:setContentSize({ width = 720, height = 400 })
	scrollView:setPosition(0,0)
	parent:addChild(scrollView, 2)
	
	scrollView:setBackGroundColorType(1)
	scrollView:setBackGroundColor({ r = 222, g = 222, b = 222 })
	
	local innerInterface = clsContainerInterface.new(scrollView)
	
	local createFunc = function(data) 
		local cell = utils.CreateButton(RES_CONFIG.common_mask_red,RES_CONFIG.common_mask_red,"")
		cell:setScale9Enabled(true)
		cell:setTitleFontSize(24)
		-- todo: 根据data创建cell的属性，比如子控件，按钮标题等
		cell:setTitleText(data)
		
		return cell
	end
	
	local innerWid = 100 * 30
	local innerHei = 64 * 520
	scrollView:setInnerContainerSize(cc.size(innerWid,innerHei))
	
	local idx = 0
	for r=1, 520 do
		for c=1, 30 do
			idx = idx + 1
			local data = idx  -- data可是任意类型
			local bound = { x=(c-0.5)*100, y=innerHei-(r-0.5)*64, w=96, h=62 }  --如果锚点不是(0.5,0.5)需要设置 bound.anchorX和bound.anchorY  如果scale不是1，需要设置bound.scale 
			innerInterface:AddObjectDelay(nil, bound, createFunc, nil, data)
		end
	end
	
	innerInterface:CheckSeeable()
end

function test.testPromise1()
	logger.normal("--------- testPromise1 ------------------")
	local aaa = smartor.clsPromise.new():SetName("aaa")
	
	
	local bbb = aaa:PartCall(1, function(thisObj, promise, v)
		KE_SetTimeout(55, function() 
			promise:Done() 
		end)
	end, "this", "bbb"):SetName("bbb")
	
	local ccc = aaa:PartCall(1, function(thisObj, promise, v)
		KE_SetTimeout(33, function() 
			promise:Done() 
		end)
	end, "this", "ccc"):SetName("ccc")
	
	local ddd = smartor.clsPromise.new():SetName("ddd")
	ddd:SetProcFunc(function(thisObj, promise, v) 
		KE_SetTimeout(45*2, function() 
			promise:Done() 
		end)
	end, nil, "ddd")
	aaa:SetNext(ddd)
	
	local eee = smartor.clsPromise.new():SetName("eee")
	eee:SetProcFunc(function(thisObj, promise, v) 
		KE_SetTimeout(25, function() 
			promise:Done() 
		end)
	end, nil, "eee")
	ddd:AddPart(5, eee)
	
	local fff = smartor.clsPromise.new():SetName("fff")
	fff:SetProcFunc(function(thisObj, promise, v) 
		KE_SetTimeout(45, function() 
			promise:Done() 
		end)
	end, nil, "fff")
	ddd:AddPart(35, fff)
	
	aaa:Run()
end 

function test.testPromise2()
	logger.normal("--------- testPromise2 ------------------")
	local aaa = smartor.clsPromise.new()
	aaa:SetProcFunc(function(thisObj, promise, v) 
		logger.normal("---begin", v)
		KE_SetTimeout(44, function() 
			logger.normal("---end", v)
			promise:Done() 
		end)
	end, nil, "a")
	
	local bbb = smartor.clsPromise.new()
	bbb:SetProcFunc(function(thisObj, promise, v) 
		logger.normal("---begin", v)
		KE_SetTimeout(30, function() 
			logger.normal("---end", v)
			promise:Done() 
		end)
	end, nil, "b")
		local bbb1 = smartor.clsPromise.new()
		bbb1:SetProcFunc(function(thisObj, promise, v) 
				logger.normal("---begin", v)
				KE_SetTimeout(5, function() 
					logger.normal("---end", v) 
					promise:Done() 
				end)
			end, nil, "b1")
		bbb:AddPart(5, bbb1)
		local bbb1 = smartor.clsPromise.new()
		bbb1:SetProcFunc(function(thisObj, promise, v) 
				logger.normal("---begin", v)
				logger.normal("---end", v)
				promise:Done()
			end, nil, "b2")
		bbb:AddPart(0, bbb1)
			local bbb11 = smartor.clsPromise.new()
			bbb11:SetProcFunc(function(thisObj, promise, v) 
					logger.normal("---begin", v)
					logger.normal("---end", v)
					promise:Done()
				end, nil, "b11")
			bbb1:AddPart(0, bbb11)
				local bbb111 = smartor.clsPromise.new()
				bbb111:SetProcFunc(function(thisObj, promise, v) 
						logger.normal("---begin", v)
						logger.normal("---end", v)
						promise:Done()
					end, nil, "b111")
				bbb11:SetNext(bbb111)
		local bbb1 = smartor.clsPromise.new()
		bbb1:SetProcFunc(function(thisObj, promise, v) 
				logger.normal("---begin", v)
				KE_SetTimeout(55, function() 
					logger.normal("---end", v) 
					promise:Done() 
				end)
			end, nil, "b3")
		bbb:AddPart(0, bbb1)
	aaa:SetNext(bbb)
	
	local ccc = smartor.clsPromise.new()
	ccc:SetProcFunc(function(thisObj, promise, v) 
		logger.normal("---begin", v)
		logger.normal("---end", v)
		promise:Done()
	end, nil, "c")
	aaa:SetNext(ccc)
	
	logger.normal("检查是否成环", aaa:HasCircle())
	
	aaa:Run()
	aaa:Run()
	aaa:Run()
	
	local ddd = smartor.clsPromise.new()
	ddd:SetProcFunc(function(thisObj, promise, v) 
		logger.normal("---begin", v)
		logger.normal("---end", v)
		promise:Done()
	end, nil, "d")
	aaa:SetNext(ddd)
	
	aaa:Run()
	
	local RecoverTimes = 2 
	local eee = smartor.clsPromise.new()
	eee:SetProcFunc(function(thisObj, promise, v) 
		logger.normal("---begin", v)
		if RecoverTimes > 0 then
			RecoverTimes = RecoverTimes - 1
			KE_SetTimeout(20, function() 
				logger.normal("重跑")
				aaa:Recover() 
				aaa:Run()
			end)
		end
		logger.normal("---end", v)
		promise:Done()
	end, nil, "e")
	aaa:SetNext(eee)
	aaa:Recover()
	KE_SetTimeout(15,function() aaa:Recover() aaa:Run() end)
	
	local all_promise = {}
	aaa:walk_all(function(promise) 
		logger.normal("walk: ", promise._procCaller.args[1]) 
		if all_promise[promise] then
			logger.normal("存在环")
		end
		all_promise[promise] = true
	end)
end

return test
