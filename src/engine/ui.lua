local ui = {}
ui.__index = ui

windowWidth = 800
windowHeight = 600

environmentX = -800
environmentX2 = -800
inventoryX = 700
inventoryX2 = 700

normalFonts = {}
boldFonts = {}
normalPath = "font/DejaVuSansMono.ttf"
boldPath = "font/DejaVuSansMono-Bold.ttf"
fontSizes = {8, 10, 12, 16, 20, 24, 32, 48}

offscreenBackgroundColor = {16, 16, 16}

fullScreenOffsetX = 0
fullScreenOffsetY = 0
textPaddingX = 48
textPaddingY = 24
textCursorX = textPaddingX
textCursorY = textPaddingY
characterWidth = 8
characterHeight = 24
trueCharacterWidth = 8
trueCharacterHeight = 24
pageBottomHeight = 600 - 18 - 12

-- 88 rows
-- 23 columns
totalRows = (windowWidth - textPaddingX * 2) / characterWidth
totalColumns = (windowHeight - textPaddingY * 2) / characterHeight

mouseX = 0
mouseY = 0

menuState = "center"
menuTransitioning = false

hoveredFragmentIndex = -1;

textFragments = {}
cursors = {}

function ui.new()
	local self = setmetatable({}, ui)
	
	love.window.setFullscreen(true, "desktop") -- "exclusive" for changing resolution
	--love.window.setMode(windowWidth, windowHeight, {})
	love.window.setTitle("Test")
	
	fullScreenOffsetX = (love.graphics.getWidth() - windowWidth) / 2
	fullScreenOffsetY = (love.graphics.getHeight() - windowHeight) / 2
	
	cursors.arrow = love.mouse.getSystemCursor("arrow")
	cursors.hand = love.mouse.getSystemCursor("hand")
	
	backgroundImage = love.graphics.newImage("img/background.png")
	inventoryImage = love.graphics.newImage("img/inventory.png")
	environmentImage = love.graphics.newImage("img/environment.png")
	love.graphics.setNewFont(12)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setBackgroundColor(offscreenBackgroundColor[1], offscreenBackgroundColor[2], offscreenBackgroundColor[3])
	
	self.fontSizes = {8, 10, 12, 16, 20, 24, 48}
	
	for i = 1, 7 do
		normalFonts[i] = love.graphics.newFont(normalPath, fontSizes[i])
		boldFonts[i] = love.graphics.newFont(boldPath, fontSizes[i])
	end
	
	normalFonts[8] = love.graphics.newFont(normalPath, 8)
	boldFonts[8] = love.graphics.newFont(boldPath, 8)
	normalFonts[10] = love.graphics.newFont(normalPath, 10)
	boldFonts[10] = love.graphics.newFont(boldPath, 10)
	normalFonts[12] = love.graphics.newFont(normalPath, 12)
	boldFonts[12] = love.graphics.newFont(boldPath, 12)
	normalFonts[16] = love.graphics.newFont(normalPath, 16)
	boldFonts[16] = love.graphics.newFont(boldPath, 16)
	normalFonts[20] = love.graphics.newFont(normalPath, 20)
	boldFonts[20] = love.graphics.newFont(boldPath, 20)
	normalFonts[24] = love.graphics.newFont(normalPath, 24)
	boldFonts[24] = love.graphics.newFont(boldPath, 24)
	normalFonts[32] = love.graphics.newFont(normalPath, 32)
	boldFonts[32] = love.graphics.newFont(boldPath, 32)
	normalFonts[48] = love.graphics.newFont(normalPath, 48)
	boldFonts[48] = love.graphics.newFont(boldPath, 48)
	
	self.inventory = {}
	
	return self
end

function ui:setPage(page)
	textFragments = page:getPhrases()
end

function ui:setInventory(inventory)
	self.inventory = inventory
end

function ui:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(backgroundImage, fullScreenOffsetX, fullScreenOffsetY)
	
	self:drawContent()
	self:drawSideMenus()
	
	love.graphics.setFont(boldFonts[10])
	love.graphics.setColor(colors["lgrey"])
	love.graphics.print("fps: " .. tostring(love.timer.getFPS()), fullScreenOffsetX + 750, fullScreenOffsetY + 4)
end

function ui:drawContent()
	love.graphics.setFont(boldFonts[12])
	
	local textCursorX = textPaddingX
	local textCursorY = textPaddingY
	
	for i = 1, #textFragments do
		textData = textFragments[i]
		text = textData[1]
		
		if i == hoveredFragmentIndex then
			textColor = colors[textData[3]]
		else
			textColor = colors[textData[2]]
		end
		
		if text == "" then -- newline
			textCursorX = textPaddingX
			textCursorY = textCursorY + characterHeight
		elseif text == "^" then -- pagebottom
			textCursorX = textPaddingX
			textCursorY = pageBottomHeight
		else
			characterIndex = 1
			
			while characterIndex <= #text do
				character = string.sub(text, characterIndex, characterIndex)
				
				if character == "_" then -- space that doesn't count for hover
					character = " "
				end
				
				love.graphics.setColor(textColor)
				love.graphics.print(character, fullScreenOffsetX + textCursorX, fullScreenOffsetY + textCursorY)
				
				if textCursorX + characterWidth >= windowWidth - textPaddingX then
					textCursorX = textPaddingX
					textCursorY = textCursorY + characterHeight
				else
					textCursorX = textCursorX + characterWidth
				end
				
				characterIndex = characterIndex + 1
			end
		end
	end
end

function ui:drawSideMenus()
	love.graphics.setColor({255, 255, 255, 255})
	
	if environmentX ~= environmentX2 then
		if environmentX > environmentX2 then
			environmentX = environmentX - 20
		else
			environmentX = environmentX + 20
		end
		
		love.graphics.draw(inventoryImage, fullScreenOffsetX + inventoryX, fullScreenOffsetY) -- ensure environment is drawn on top
		love.graphics.draw(environmentImage, fullScreenOffsetX + environmentX, fullScreenOffsetY)
	end
	
	if inventoryX ~= inventoryX2 then
		if inventoryX > inventoryX2 then
			inventoryX = inventoryX - 20
		else
			inventoryX = inventoryX + 20
		end
		
		love.graphics.draw(environmentImage, fullScreenOffsetX + environmentX, fullScreenOffsetY) -- ensure inventory is drawn on top
		love.graphics.draw(inventoryImage, fullScreenOffsetX + inventoryX, fullScreenOffsetY)
	end
	
	if environmentX == environmentX2 and inventoryX == inventoryX2 then
		menuTransitioning = false
	
		if menuState == "left" then
			love.graphics.draw(inventoryImage, fullScreenOffsetX + inventoryX, fullScreenOffsetY)
			love.graphics.draw(environmentImage, fullScreenOffsetX + environmentX, fullScreenOffsetY)
		else
			love.graphics.draw(environmentImage, fullScreenOffsetX + environmentX, fullScreenOffsetY)
			love.graphics.draw(inventoryImage, fullScreenOffsetX + inventoryX, fullScreenOffsetY)
		end
	end
	
	local items = self.inventory:getItems()
	
	local textCursorX = textPaddingX + inventoryX + 100
	local textCursorY = textPaddingY
	
	
	self:printTextByCharacter(util.padCenter("Inventory", 94, " "), fullScreenOffsetX + textCursorX, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["lgrey"], boldFonts[12])
	textCursorY = textCursorY + characterHeight * 2
	
	for i = 1, #items do
		local item = items[i]
		local itemName = item:getName()
		local itemFrequency = item:getFrequency()
		
		love.graphics.setColor(colors["lgrey"])
		love.graphics.print("[", fullScreenOffsetX + textCursorX, fullScreenOffsetY + textCursorY)
		
		if itemFrequency > 99 then
			self:printTextByCharacter(itemFrequency .. "", fullScreenOffsetX + textCursorX + characterWidth, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["red"], boldFonts[12])
		elseif itemFrequency > 9 then
			self:printTextByCharacter("0", fullScreenOffsetX + textCursorX + characterWidth, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", fullScreenOffsetX + textCursorX + characterWidth * 2, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["red"], boldFonts[12])
		else
			self:printTextByCharacter("00", fullScreenOffsetX + textCursorX + characterWidth, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", fullScreenOffsetX + textCursorX + characterWidth * 3, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["red"], boldFonts[12])
		end
		
		self:printTextByCharacter("]", fullScreenOffsetX + textCursorX + characterWidth * 4, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["lgrey"], boldFonts[12])
		
		self:printTextByCharacter(itemName, fullScreenOffsetX + textCursorX + characterWidth * 6, fullScreenOffsetY + textCursorY, characterWidth, characterHeight, colors["grey"], boldFonts[12])
			
		textCursorY = textCursorY + characterHeight
	end
	
	-- cover content outside fullscreen frame
	love.graphics.setColor({offscreenBackgroundColor[1], offscreenBackgroundColor[2], offscreenBackgroundColor[3], 255})
	love.graphics.rectangle("fill", fullScreenOffsetX - 800, fullScreenOffsetY, 800, 600)
	love.graphics.rectangle("fill", fullScreenOffsetX + 800, fullScreenOffsetY, 800, 600)
end

function ui:update(dt)
	mouseX, mouseY = love.mouse.getPosition()
	mouseX = mouseX - fullScreenOffsetX
	mouseY = mouseY - fullScreenOffsetY
	
	if menuState == "center" then
		updateHoveredFragment()
		
		if hoveredFragmentIndex ~= -1 then
			love.mouse.setCursor(cursors.hand)
		else
			love.mouse.setCursor(cursors.arrow)
		end
	else
		hoveredFragmentIndex = -1
		love.mouse.setCursor(cursors.arrow)
	end
end

function ui:keyPressed(key)
	if menuState == "center" then
		if key == "right" then
			changeMenu("left")
		elseif key == "left" then
			changeMenu("right")
		end
	elseif menuState == "left" then
		if key == "left" then
			changeMenu("center")
		end
	elseif menuState == "right" then
		if key == "right" then
			changeMenu("center")
		end
	end
end

function ui:mousePressed(x, y, button, isTouch)
	
end

function ui:mouseReleased(x, y, button, isTouch)
	if hoveredFragmentIndex ~= -1 and button == 1 then -- 1 = primary, 2 = secondary, 3 = middle
		local actionName = textFragments[hoveredFragmentIndex][4]
		local parameter = textFragments[hoveredFragmentIndex][5]
		
		game:executeAction(actionName, parameter)
	end
end

function changeMenu(menu)
	if menuTransitioning then
		--return
	end

	menuState = menu
	menuTransitioning = true
	
	if menuState == "center" then
		environmentX2 = -800
		inventoryX2 = 700
	elseif menuState == "left" then
		environmentX2 = 0
		inventoryX2 = 700
	elseif menuState == "right" then
		environmentX2 = -800
		inventoryX2 = -100
	end
end

function updateHoveredFragment()
	local textCursorX = textPaddingX
	local textCursorY = textPaddingY
	
	hoveredFragmentIndex = -1
	
	for i = 1, #textFragments do -- go through each character and check if the mouse is hovering over it
		textData = textFragments[i]
		text = textData[1]
		
		if text == "" then -- newline
			textCursorX = textPaddingX
			textCursorY = textCursorY + characterHeight
		elseif text == "^" then -- pagebottom
			textCursorX = textPaddingX
			textCursorY = pageBottomHeight
		else
			characterIndex = 1
			
			done = false
			
			while characterIndex <= #text do
				character = string.sub(text, characterIndex, characterIndex)
				
				if character ~= "_" then
					if mouseX >= textCursorX and mouseX < textCursorX + trueCharacterWidth and mouseY >= textCursorY and mouseY < textCursorY + trueCharacterHeight then
						if textData[4] ~= "" then -- if an action is defined for this phrase
							hoveredFragmentIndex = i
						end
					end
				end
				
				if textCursorX + characterWidth >= windowWidth - textPaddingX then
					textCursorX = textPaddingX
					textCursorY = textCursorY + characterHeight
				else
					textCursorX = textCursorX + characterWidth
				end
				
				characterIndex = characterIndex + 1
			end
		end
	end
end

-- should probably refactor this whole text printing thing
function ui:printTextByCharacter(text, x, y, width, height, color, font) -- only supports printing in a line (i.e. no word wrap)
	love.graphics.setFont(font)
	love.graphics.setColor(color)
	
	for i = 1, #text do
		love.graphics.print(string.sub(text, i, i), x, y)
		
		x = x + width
	end
end

return ui