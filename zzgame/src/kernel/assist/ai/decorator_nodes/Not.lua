module("ai",package.seeall)

clsNot = class("clsNot", clsDecoratorNode)

function clsNot:ctor(target)
	clsDecoratorNode.ctor(self, target)
end

function clsNot:Proc(theOwner)
	return not clsDecoratorNode.Proc(self, theOwner)
end
