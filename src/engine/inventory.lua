local inventory = {}
inventory.__index = inventory

function inventory.new()
	local self = setmetatable({}, inventory)
	
	self.items = {}
	
	return self
end

function inventory:addItem(name, id, frequency)
	local item = require("item")
	
	local existingItem = util.searchByID(self.items, id)
	if existingItem ~= nil then
		existingItem:increaseFrequency(frequency)
	else
		local newItem = item.new(name, id)
		newItem:increaseFrequency(frequency - 1)
		table.insert(self.items, newItem)
	end
	
	return self
end

function inventory:removeItem(id, frequency)
	local i = 1
	local done = false
	while i <= #self.items and not done do
		local checkItem = self.items[i]
		
		if checkItem:getID() == id then
			done = true
			
			-- if, e.g. you try to remove 4 apples when there are only 3, nothing happens
			if checkItem:getFrequency() > frequency then 
				checkItem:decreaseFrequency(frequency)
			elseif checkItem:getFrequency() == frequency then
				table.remove(self.items, index)
			end
		end
		
		i = i + 1
	end
	
	return self
end

function inventory:getItems()
	return self.items
end

return inventory