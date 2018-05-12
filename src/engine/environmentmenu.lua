local SlideMenu = require("slidemenu")
local EnvironmentMenu = SlideMenu:extend()

function EnvironmentMenu:new(x1, x2, speed, image)
	EnvironmentMenu.super.new(self, x1, x2, speed, image)
end

function EnvironmentMenu:draw(inventory)
	EnvironmentMenu.super.draw(self)
	
	local UI = require("ui")
	
	local items = inventory:getItems()
	
	local textCursorX = UI.textPaddingX + self.x
	local textCursorY = UI.textPaddingY
	
	self:printTextByCharacter(util.padCenter("Environment", 94, " "), UI.fullScreenOffsetX + textCursorX, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["lgrey"], UI.boldFonts[12])
	textCursorY = textCursorY + UI.characterHeight * 2
	
	for i = 1, #items do
		local item = items[i]
		local itemName = item:getName()
		local itemFrequency = item:getFrequency()
		
		love.graphics.setColor(colors["lgrey"])
		love.graphics.print("[", UI.fullScreenOffsetX + textCursorX, UI.fullScreenOffsetY + textCursorY)
		
		if itemFrequency > 99 then
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], UI.boldFonts[12])
		elseif itemFrequency > 9 then
			self:printTextByCharacter("0", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["dgrey"], UI.boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 2, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], UI.boldFonts[12])
		else
			self:printTextByCharacter("00", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["dgrey"], UI.boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 3, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], UI.boldFonts[12])
		end
		
		self:printTextByCharacter("]", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 4, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["lgrey"], UI.boldFonts[12])
		
		self:printTextByCharacter(itemName, UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 6, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["grey"], UI.boldFonts[12])
			
		textCursorY = textCursorY + UI.characterHeight
	end
end

function EnvironmentMenu:moveIn()
	self.super.moveIn(self)
end

function EnvironmentMenu:moveOut()
	self.super.moveOut(self)
end

return EnvironmentMenu
