local item = {}
item.__index = item

function item.new(name, id, frequency)
	local self = setmetatable({}, item)
	
	local frequency = frequency or 1
	
	self.name = name
	self.id = id
	self.frequency = frequency
	
	return self
end

function item:getName()
	return self.name
end

function item:getID()
	return self.id
end

function item:getFrequency()
	return self.frequency
end

function item:increaseFrequency(value)
	self.frequency = self.frequency + value
	
	if self.frequency > 999 then
		self.frequency = 999
	end
end

function item:decreaseFrequency(value)
	self.frequency = self.frequency - value
end

return item