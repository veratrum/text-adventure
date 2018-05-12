local DisplayText = Object:extend()

function DisplayText:new(phrase, xBegin, yBegin)
	self.text = phrase.text
	self.color = phrase.color
	self.colorHover = phrase.colorHover
	self.action = phrase.action
	self.data = phrase.data
	
	self.xBegin = xBegin
	self.yBegin = yBegin
	
	local UI = require("ui")
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = UI.textPaddingX
		currentY = currentY + UI.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = UI.textPaddingX
		currentY = UI.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if currentX + UI.characterWidth >= UI.windowWidth - UI.textPaddingX then
				currentX = UI.textPaddingX
				currentY = currentY + UI.characterHeight
			else
				currentX = currentX + UI.characterWidth
			end
		end
	end
	
	self.xEnd = currentX
	self.yEnd = currentY
end

function DisplayText:draw(mouseX, mouseY)
	local UI = require("ui")
	
	love.graphics.setFont(UI.boldFonts[12])
	
	local hovered = self:isHovered(mouseX, mouseY)
	
	local textColor = colors[self.color]
	--local textColor = colors["lgrey"]
	if hovered then
		textColor = colors[self.colorHover]
	end
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = UI.textPaddingX
		currentY = currentY + UI.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = UI.textPaddingX
		currentY = UI.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if character == "_" then -- space that doesn't count for hover
				character = " "
			end
			
			love.graphics.setColor(textColor)
			love.graphics.print(character, UI.fullScreenOffsetX + currentX, UI.fullScreenOffsetY + currentY)
			
			if currentX + UI.characterWidth >= UI.windowWidth - UI.textPaddingX then
				currentX = UI.textPaddingX
				currentY = currentY + UI.characterHeight
			else
				currentX = currentX + UI.characterWidth
			end
		end
	end
end

function DisplayText:isHovered(mouseX, mouseY)
	local UI = require("ui")
	
	if self.action == "" then
		--return false
	end
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = UI.textPaddingX
		currentY = currentY + UI.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = UI.textPaddingX
		currentY = UI.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if character ~= "_" then
				if mouseX >= currentX and mouseX < currentX + UI.characterWidth and mouseY >= currentY and mouseY < currentY + UI.characterHeight then
					return true
				end
			end
			
			if currentX + UI.characterWidth >= UI.windowWidth - UI.textPaddingX then
				currentX = UI.textPaddingX
				currentY = currentY + UI.characterHeight
			else
				currentX = currentX + UI.characterWidth
			end
		end
	end
	
	return false
end

function DisplayText:getEndCoordinates()
	return {
		x = self.xEnd,
		y = self.yEnd
	}
end

function DisplayText:getAction()
	return self.action
end

function DisplayText:getData()
	return self.data
end

return DisplayText
