-------------------------
-- 回调类
-------------------------
module("smartor",package.seeall)

clsCaller = class("clsCaller")

function clsCaller:ctor(Func, thisObj, ...)
	assert(type(Func)=="function")
	self.Func = Func
	self.thisObj = thisObj
	self.args = {...}
end

function clsCaller:dtor()
	self:Clean()
end

function clsCaller:Clean()
	self.Func = nil
	self.thisObj = nil
	self.args = nil
end

function clsCaller:Call(promise)
	assert(promise.__cname == "clsPromise")
	return self.Func(self.thisObj, promise, unpack(self.args))
end

function clsCaller:CleanCall(promise)
	local tmpFun = self.Func
	local tmpThis = self.thisObj
	local tmpArgs = self.args
	self:Clean()
	return tmpFun(tmpThis, promise, unpack(tmpArgs))
end
