local player = {}
player.__index = player

function player.new(name, id)
	local self = setmetatable({}, player)
	
	local inventory = require("inventory")
	
	self.name = name
	self.id = id
	self.inventory = inventory.new()
	
	return self
end

function player:getName()
	return self.name
end

function player:getID()
	return self.id
end

function player:getInventory()
	return self.inventory
end

function player:addToInventory(name, id, frequency)
	local frequency = frequency or 1

	self.inventory:addItem(name, id, frequency)
	
	return self
end

function player:removeFromInventory(id, frequency)
	local frequency = frequency or 1

	self.inventory:removeItem(id, frequency)
	
	return self
end

return player