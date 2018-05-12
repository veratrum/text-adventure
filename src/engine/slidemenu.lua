local SlideMenu = Object:extend()

function SlideMenu:new(x1, x2, speed, image)
	self.x1 = x1
	self.x2 = x2
	self.speed = speed
	self.image = image
	
	self.x = self.x1
	self.xTarget = self.x1
	self.moving = false
end

function SlideMenu:draw()
	local UI = require("ui")
	
	if self.x ~= self.xTarget then
		if self.x > self.xTarget then
			self.x = self.x - 20
		else
			self.x = self.x + 20
		end
	end
	
	love.graphics.setColor({255, 255, 255, 255})
	
	love.graphics.draw(self.image, UI.fullScreenOffsetX + self.x, UI.fullScreenOffsetY)
end

function SlideMenu:moveIn()
	self.xTarget = self.x2
end

function SlideMenu:moveOut()
	self.xTarget = self.x1
end

function SlideMenu:isMoving()
	return self.moving
end

function SlideMenu:printTextByCharacter(text, x, y, width, height, color, font) -- only supports printing in a line (i.e. no word wrap)
	love.graphics.setFont(font)
	love.graphics.setColor(color)
	
	for i = 1, #text do
		love.graphics.print(string.sub(text, i, i), x, y)
		
		x = x + width
	end
end

return SlideMenu
