local Item = Object:extend()

function Item:new(name, id, frequency)
	local frequency = frequency or 1
	
	self.name = name
	self.id = id
	self.frequency = frequency
end

function Item:getName()
	return self.name
end

function Item:getID()
	return self.id
end

function Item:getFrequency()
	return self.frequency
end

function Item:increaseFrequency(value)
	self.frequency = self.frequency + value
	
	if self.frequency > 999 then
		self.frequency = 999
	end
end

function Item:decreaseFrequency(value)
	self.frequency = self.frequency - value
end

return Item
