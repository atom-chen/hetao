-------------------------
-- 分页请求数据
-------------------------
module("gameutil", package.seeall)

clsPageCacher = class("clsPageCacher")

function clsPageCacher:ctor(iPageSize)
	assert(iPageSize>=4)
	self.iPageSize = iPageSize
	self:ClearCachedData()
end 

function clsPageCacher:ClearCachedData()
	self.iTotalPage = nil
	self.iTotalCount = nil
	self.tWaiting = {}
	self.tPageDatas = {}
end 

function clsPageCacher:ReqPage(iPageIdx, reqFunc)
	assert(iPageIdx >= 1)
	if self.tPageDatas[iPageIdx] then
		logger.normal("已经获取该页", iPageIdx, self.iTotalPage, self.iTotalCount, #self.tPageDatas)
		return false
	end 
	if self.iTotalPage and iPageIdx > self.iTotalPage then
		logger.normal("总页数",self.iTotalPage, "当前请求页", iPageIdx)
		return false
	end
	if self:IsAllStored() then 
		logger.normal("已经全部获取", self.iTotalPage, self.iTotalCount, #self.tPageDatas)
		return false
	end
	if self.tWaiting[iPageIdx] then
		logger.normal("正在等待响应：",iPageIdx)
		return false
	end 
	self.tWaiting[iPageIdx] = true
	logger.normal("请求页：", iPageIdx, self.iTotalCount, self.iTotalPage)
	reqFunc()
	return true
end 

function clsPageCacher:OnRespPage(iTotalPage, iTotalCount, iPageIdx, dataList)
	self.iTotalPage = iTotalPage
	self.iTotalCount = iTotalCount
	self.tPageDatas[iPageIdx] = dataList
	self.tWaiting[iPageIdx] = false 
end 

function clsPageCacher:RemoveDataByFilter(filterFunc)
	local posList = self:GetPosByFilter(filterFunc)
	for _, pos in ipairs(posList) do 
		logger.printf( "移除数据：第%d页 第%d条", pos[1], pos[2] )
		table.remove(self.tPageDatas[ pos[1] ], pos[2])
	end 
end

------------------------------------------------------

function clsPageCacher:IsAllStored()
	if not self.iTotalPage then return false end 
	if self.iTotalPage == 0 then return true end 
	for i=1, self.iTotalPage do 
		if not self.tPageDatas[i] then return false end 
	end 
	return true
end 

function clsPageCacher:GetTotalCount()
	return self.iTotalCount
end 

function clsPageCacher:GetTotalPage()
	return self.iTotalPage
end 

function clsPageCacher:GetPage(iPageIdx)
	return self.tPageDatas[iPageIdx]
end 

function clsPageCacher:GetPosByFilter(filterFunc)
	local posList = {}
	for iPage, pageData in pairs(self.tPageDatas) do 
		for i, data in pairs(pageData) do 
			if filterFunc(data) then
				table.insert(posList, {iPage, i})
			end
		end
	end 
	return posList
end
