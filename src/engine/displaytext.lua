local DisplayText = Object:extend()

function DisplayText:new(phrase, xBegin, yBegin)
	self.text = phrase.text
	self.color = phrase.color
	self.colorHover = phrase.colorHover
	self.action = phrase.action
	self.data = phrase.data
	
	self.xBegin = xBegin
	self.yBegin = yBegin
	
	local ui = require("ui")
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = ui.textPaddingX
		currentY = currentY + ui.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = ui.textPaddingX
		currentY = ui.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if currentX + ui.characterWidth >= ui.windowWidth - ui.textPaddingX then
				currentX = ui.textPaddingX
				currentY = currentY + ui.characterHeight
			else
				currentX = currentX + ui.characterWidth
			end
		end
	end
	
	self.xEnd = currentX
	self.yEnd = currentY
end

function DisplayText:draw(mouseX, mouseY)
	local ui = require("ui")
	
	love.graphics.setFont(boldFonts[12])
	
	local hovered = self:isHovered(mouseX, mouseY)
	
	local textColor = colors[self.color]
	--local textColor = colors["lgrey"]
	if hovered then
		textColor = colors[self.colorHover]
	end
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = ui.textPaddingX
		currentY = currentY + ui.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = ui.textPaddingX
		currentY = ui.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if character == "_" then -- space that doesn't count for hover
				character = " "
			end
			
			love.graphics.setColor(textColor)
			love.graphics.print(character, ui.fullScreenOffsetX + currentX, ui.fullScreenOffsetY + currentY)
			
			if currentX + ui.characterWidth >= ui.windowWidth - ui.textPaddingX then
				currentX = ui.textPaddingX
				currentY = currentY + ui.characterHeight
			else
				currentX = currentX + ui.characterWidth
			end
		end
	end
end

function DisplayText:isHovered(mouseX, mouseY)
	local ui = require("ui")
	
	if self.action == "" then
		--return false
	end
	
	local currentX = self.xBegin
	local currentY = self.yBegin
	
	if self.text == "" then -- newline
		currentX = ui.textPaddingX
		currentY = currentY + ui.characterHeight
	elseif self.text == "^" then -- pagebottom
		currentX = ui.textPaddingX
		currentY = ui.pageBottomHeight
	else
		for i = 1, #self.text do
			local character = self.text:sub(i, i)
			
			if character ~= "_" then
				if mouseX >= currentX and mouseX < currentX + ui.characterWidth and mouseY >= currentY and mouseY < currentY + ui.characterHeight then
					return true
				end
			end
			
			if currentX + ui.characterWidth >= ui.windowWidth - ui.textPaddingX then
				currentX = ui.textPaddingX
				currentY = currentY + ui.characterHeight
			else
				currentX = currentX + ui.characterWidth
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
