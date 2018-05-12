local Player = Object:extend()

function Player:new(name, id)
	local Inventory = require("inventory")
	
	self.name = name
	self.id = id
	self.inventory = Inventory()
end

function Player:getName()
	return self.name
end

function Player:getID()
	return self.id
end

function Player:getInventory()
	return self.inventory
end

function Player:addToInventory(name, id, frequency)
	local frequency = frequency or 1

	self.inventory:addItem(name, id, frequency)
	
	return self
end

function Player:removeFromInventory(id, frequency)
	local frequency = frequency or 1

	self.inventory:removeItem(id, frequency)
	
	return self
end

return Player
