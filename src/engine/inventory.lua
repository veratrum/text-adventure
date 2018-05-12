local Inventory = Object:extend()

function Inventory:new()
	self.items = {}
end

function Inventory:addItem(name, id, frequency)
	local Item = require("item")
	
	local existingItem = util.searchByID(self.items, id)
	if existingItem ~= nil then
		existingItem:increaseFrequency(frequency)
	else
		local newItem = Item(name, id)
		newItem:increaseFrequency(frequency - 1)
		table.insert(self.items, newItem)
	end
	
	return self
end

function Inventory:removeItem(id, frequency)
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

function Inventory:getItems()
	return self.items
end

return Inventory
