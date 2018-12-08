-------------------------------
-- 管理器
-------------------------------
ClsCollectMgr = class("ClsCollectMgr")
ClsCollectMgr.__is_singleton = true

function ClsCollectMgr:ctor()
	self._collectList = nil
end

function ClsCollectMgr:dtor()

end

function ClsCollectMgr:req_user_get_favorite()
	if not self._collectList then
		proto.req_user_get_favorite()
	end
end

function ClsCollectMgr:SetCollectList(data)
	self._collectList = data
end

function ClsCollectMgr:HasCollect(gid)
	if not self._collectList then return false end
	for _, info in ipairs(self._collectList) do
		if gameutil.IsSameGid(gid, info.id) then
			return true
		end
	end
	return false
end

function ClsCollectMgr:AddCollect(info)
	local gid = info.gid
	self._collectList = self._collectList or {}
	if self:HasCollect(gid) then return end
	table.insert(self._collectList, info)	
end

function ClsCollectMgr:DelCollect(gid)
	if self._collectList then
		for idx, info in ipairs(self._collectList) do
			if gameutil.IsSameGid(gid, info.id) then
				table.remove(self._collectList, idx)
				return
			end
		end
	end
end
