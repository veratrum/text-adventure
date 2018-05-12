local UI = Object:extend()

UI.windowWidth = 800
UI.windowHeight = 600

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

UI.fullScreenOffsetX = 0
UI.fullScreenOffsetY = 0
UI.textPaddingX = 48
UI.textPaddingY = 24
UI.extCursorX = textPaddingX
UI.textCursorY = textPaddingY
UI.characterWidth = 8
UI.characterHeight = 24
UI.pageBottomHeight = 600 - 18 - 12

-- 88 rows
-- 23 columns
UI.totalRows = (UI.windowWidth - UI.textPaddingX * 2) / UI.characterWidth
UI.totalColumns = (UI.windowHeight - UI.textPaddingY * 2) / UI.characterHeight

mouseX = 0
mouseY = 0

menuState = "center"
menuTransitioning = false

hoveredFragmentIndex = -1;

--phrases = {}
--cursors = {}

function UI:new()
	love.window.setFullscreen(true, "desktop") -- "exclusive" for changing resolution
	--love.window.setMode(windowWidth, windowHeight, {})
	love.window.setTitle("Test")
	
	UI.fullScreenOffsetX = (love.graphics.getWidth() - UI.windowWidth) / 2
	UI.fullScreenOffsetY = (love.graphics.getHeight() - UI.windowHeight) / 2
	
	UI.cursors = {}
	UI.cursors.arrow = love.mouse.getSystemCursor("arrow")
	UI.cursors.hand = love.mouse.getSystemCursor("hand")
	
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
	self.displayTexts = {}
end

function UI:setPage(page)
	local phrases = page:getPhrases()
	
	local DisplayText = require("displaytext");
	
	self.displayTexts = {}
	local currentX = UI.textPaddingX
	local currentY = UI.textPaddingY
	for i = 1, #phrases do
		local dT = DisplayText(phrases[i], currentX, currentY)
		
		currentPosition = dT:getEndCoordinates()
		currentX = currentPosition.x
		currentY = currentPosition.y
		
		table.insert(self.displayTexts, dT)
	end
end

function UI:setInventory(inventory)
	self.inventory = inventory
end

function UI:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(backgroundImage, UI.fullScreenOffsetX, UI.fullScreenOffsetY)
	
	self:drawContent()
	self:drawSideMenus()
	
	love.graphics.setFont(boldFonts[10])
	love.graphics.setColor(colors["lgrey"])
	love.graphics.print("fps: " .. tostring(love.timer.getFPS()), UI.fullScreenOffsetX + 750, UI.fullScreenOffsetY + 4)
end

function UI:drawContent()
	for i = 1, #self.displayTexts do
		displayText = self.displayTexts[i]
		
		displayText:draw(mouseX, mouseY)
	end
end

function UI:drawSideMenus()
	love.graphics.setColor({255, 255, 255, 255})
	
	if environmentX ~= environmentX2 then
		if environmentX > environmentX2 then
			environmentX = environmentX - 20
		else
			environmentX = environmentX + 20
		end
		
		love.graphics.draw(inventoryImage, UI.fullScreenOffsetX + inventoryX, UI.fullScreenOffsetY) -- ensure environment is drawn on top
		love.graphics.draw(environmentImage, UI.fullScreenOffsetX + environmentX, UI.fullScreenOffsetY)
	end
	
	if inventoryX ~= inventoryX2 then
		if inventoryX > inventoryX2 then
			inventoryX = inventoryX - 20
		else
			inventoryX = inventoryX + 20
		end
		
		love.graphics.draw(environmentImage, UI.fullScreenOffsetX + environmentX, UI.fullScreenOffsetY) -- ensure inventory is drawn on top
		love.graphics.draw(inventoryImage, UI.fullScreenOffsetX + inventoryX, UI.fullScreenOffsetY)
	end
	
	if environmentX == environmentX2 and inventoryX == inventoryX2 then
		menuTransitioning = false
	
		if menuState == "left" then
			love.graphics.draw(inventoryImage, UI.fullScreenOffsetX + inventoryX, UI.fullScreenOffsetY)
			love.graphics.draw(environmentImage, UI.fullScreenOffsetX + environmentX, UI.fullScreenOffsetY)
		else
			love.graphics.draw(environmentImage, UI.fullScreenOffsetX + environmentX, UI.fullScreenOffsetY)
			love.graphics.draw(inventoryImage, UI.fullScreenOffsetX + inventoryX, UI.fullScreenOffsetY)
		end
	end
	
	local items = self.inventory:getItems()
	
	local textCursorX = UI.textPaddingX + inventoryX + 100
	local textCursorY = UI.textPaddingY
	
	
	self:printTextByCharacter(util.padCenter("Inventory", 94, " "), UI.fullScreenOffsetX + textCursorX, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["lgrey"], boldFonts[12])
	textCursorY = textCursorY + UI.characterHeight * 2
	
	for i = 1, #items do
		local item = items[i]
		local itemName = item:getName()
		local itemFrequency = item:getFrequency()
		
		love.graphics.setColor(colors["lgrey"])
		love.graphics.print("[", UI.fullScreenOffsetX + textCursorX, UI.fullScreenOffsetY + textCursorY)
		
		if itemFrequency > 99 then
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], boldFonts[12])
		elseif itemFrequency > 9 then
			self:printTextByCharacter("0", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 2, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], boldFonts[12])
		else
			self:printTextByCharacter("00", UI.fullScreenOffsetX + textCursorX + UI.characterWidth, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 3, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["red"], boldFonts[12])
		end
		
		self:printTextByCharacter("]", UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 4, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["lgrey"], boldFonts[12])
		
		self:printTextByCharacter(itemName, UI.fullScreenOffsetX + textCursorX + UI.characterWidth * 6, UI.fullScreenOffsetY + textCursorY, UI.characterWidth, UI.characterHeight, colors["grey"], boldFonts[12])
			
		textCursorY = textCursorY + UI.characterHeight
	end
	
	-- cover content outside fullscreen frame
	love.graphics.setColor({offscreenBackgroundColor[1], offscreenBackgroundColor[2], offscreenBackgroundColor[3], 255})
	love.graphics.rectangle("fill", UI.fullScreenOffsetX - 800, UI.fullScreenOffsetY, 800, 600)
	love.graphics.rectangle("fill", UI.fullScreenOffsetX + 800, UI.fullScreenOffsetY, 800, 600)
end

function UI:update(dt)
	mouseX, mouseY = love.mouse.getPosition()
	mouseX = mouseX - UI.fullScreenOffsetX
	mouseY = mouseY - UI.fullScreenOffsetY
	
	local isAnyHovered = false
	for i = 1, #self.displayTexts do
		local displayText = self.displayTexts[i]
		
		if displayText:isHovered(mouseX, mouseY) and displayText:getAction() ~= "" then
			isAnyHovered = true
		end
	end
	
	if isAnyHovered then
		love.mouse.setCursor(UI.cursors.hand)
	else
		love.mouse.setCursor(UI.cursors.arrow)
	end
end

function UI:keyPressed(key)
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

function UI:mousePressed(x, y, button, isTouch)
	
end

function UI:mouseReleased(x, y, button, isTouch)
	local clickedIndex = -1
	
	for i = 1, #self.displayTexts do
		local displayText = self.displayTexts[i]
		
		if displayText:isHovered(mouseX, mouseY) then
			clickedIndex = i
		end
	end
	
	if clickedIndex ~= -1 then
		local displayText = self.displayTexts[clickedIndex]
		
		local actionName = displayText:getAction()
		local parameter = displayText:getData()
		
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

-- should probably refactor this whole text printing thing
function UI:printTextByCharacter(text, x, y, width, height, color, font) -- only supports printing in a line (i.e. no word wrap)
	love.graphics.setFont(font)
	love.graphics.setColor(color)
	
	for i = 1, #text do
		love.graphics.print(string.sub(text, i, i), x, y)
		
		x = x + width
	end
end

return UI
