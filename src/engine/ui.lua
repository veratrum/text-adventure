local ui = {}
ui.__index = ui

ui.windowWidth = 800
ui.windowHeight = 600

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

ui.fullScreenOffsetX = 0
ui.fullScreenOffsetY = 0
ui.textPaddingX = 48
ui.textPaddingY = 24
ui.extCursorX = textPaddingX
ui.textCursorY = textPaddingY
ui.characterWidth = 8
ui.characterHeight = 24
ui.pageBottomHeight = 600 - 18 - 12

-- 88 rows
-- 23 columns
ui.totalRows = (ui.windowWidth - ui.textPaddingX * 2) / ui.characterWidth
ui.totalColumns = (ui.windowHeight - ui.textPaddingY * 2) / ui.characterHeight

mouseX = 0
mouseY = 0

menuState = "center"
menuTransitioning = false

hoveredFragmentIndex = -1;

--phrases = {}
--cursors = {}

function ui.new()
	local self = setmetatable({}, ui)
	
	love.window.setFullscreen(true, "desktop") -- "exclusive" for changing resolution
	--love.window.setMode(windowWidth, windowHeight, {})
	love.window.setTitle("Test")
	
	ui.fullScreenOffsetX = (love.graphics.getWidth() - ui.windowWidth) / 2
	ui.fullScreenOffsetY = (love.graphics.getHeight() - ui.windowHeight) / 2
	
	ui.cursors = {}
	ui.cursors.arrow = love.mouse.getSystemCursor("arrow")
	ui.cursors.hand = love.mouse.getSystemCursor("hand")
	
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
	
	return self
end

function ui:setPage(page)
	local phrases = page:getPhrases()
	
	local displayText = require("displaytext");
	
	self.displayTexts = {}
	local currentX = ui.textPaddingX
	local currentY = ui.textPaddingY
	for i = 1, #phrases do
		local dT = displayText.new(phrases[i], currentX, currentY)
		
		currentPosition = dT:getEndCoordinates()
		currentX = currentPosition.x
		currentY = currentPosition.y
		
		table.insert(self.displayTexts, dT)
	end
end

function ui:setInventory(inventory)
	self.inventory = inventory
end

function ui:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(backgroundImage, ui.fullScreenOffsetX, ui.fullScreenOffsetY)
	
	self:drawContent()
	self:drawSideMenus()
	
	love.graphics.setFont(boldFonts[10])
	love.graphics.setColor(colors["lgrey"])
	love.graphics.print("fps: " .. tostring(love.timer.getFPS()), ui.fullScreenOffsetX + 750, ui.fullScreenOffsetY + 4)
end

function ui:drawContent()
	for i = 1, #self.displayTexts do
		displayText = self.displayTexts[i]
		
		displayText:draw(mouseX, mouseY)
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
		
		love.graphics.draw(inventoryImage, ui.fullScreenOffsetX + inventoryX, ui.fullScreenOffsetY) -- ensure environment is drawn on top
		love.graphics.draw(environmentImage, ui.fullScreenOffsetX + environmentX, ui.fullScreenOffsetY)
	end
	
	if inventoryX ~= inventoryX2 then
		if inventoryX > inventoryX2 then
			inventoryX = inventoryX - 20
		else
			inventoryX = inventoryX + 20
		end
		
		love.graphics.draw(environmentImage, ui.fullScreenOffsetX + environmentX, ui.fullScreenOffsetY) -- ensure inventory is drawn on top
		love.graphics.draw(inventoryImage, ui.fullScreenOffsetX + inventoryX, ui.fullScreenOffsetY)
	end
	
	if environmentX == environmentX2 and inventoryX == inventoryX2 then
		menuTransitioning = false
	
		if menuState == "left" then
			love.graphics.draw(inventoryImage, ui.fullScreenOffsetX + inventoryX, ui.fullScreenOffsetY)
			love.graphics.draw(environmentImage, ui.fullScreenOffsetX + environmentX, ui.fullScreenOffsetY)
		else
			love.graphics.draw(environmentImage, ui.fullScreenOffsetX + environmentX, ui.fullScreenOffsetY)
			love.graphics.draw(inventoryImage, ui.fullScreenOffsetX + inventoryX, ui.fullScreenOffsetY)
		end
	end
	
	local items = self.inventory:getItems()
	
	local textCursorX = ui.textPaddingX + inventoryX + 100
	local textCursorY = ui.textPaddingY
	
	
	self:printTextByCharacter(util.padCenter("Inventory", 94, " "), ui.fullScreenOffsetX + textCursorX, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["lgrey"], boldFonts[12])
	textCursorY = textCursorY + ui.characterHeight * 2
	
	for i = 1, #items do
		local item = items[i]
		local itemName = item:getName()
		local itemFrequency = item:getFrequency()
		
		love.graphics.setColor(colors["lgrey"])
		love.graphics.print("[", ui.fullScreenOffsetX + textCursorX, ui.fullScreenOffsetY + textCursorY)
		
		if itemFrequency > 99 then
			self:printTextByCharacter(itemFrequency .. "", ui.fullScreenOffsetX + textCursorX + ui.characterWidth, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["red"], boldFonts[12])
		elseif itemFrequency > 9 then
			self:printTextByCharacter("0", ui.fullScreenOffsetX + textCursorX + ui.characterWidth, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", ui.fullScreenOffsetX + textCursorX + ui.characterWidth * 2, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["red"], boldFonts[12])
		else
			self:printTextByCharacter("00", ui.fullScreenOffsetX + textCursorX + ui.characterWidth, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["dgrey"], boldFonts[12])
			self:printTextByCharacter(itemFrequency .. "", ui.fullScreenOffsetX + textCursorX + ui.characterWidth * 3, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["red"], boldFonts[12])
		end
		
		self:printTextByCharacter("]", ui.fullScreenOffsetX + textCursorX + ui.characterWidth * 4, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["lgrey"], boldFonts[12])
		
		self:printTextByCharacter(itemName, ui.fullScreenOffsetX + textCursorX + ui.characterWidth * 6, ui.fullScreenOffsetY + textCursorY, ui.characterWidth, ui.characterHeight, colors["grey"], boldFonts[12])
			
		textCursorY = textCursorY + ui.characterHeight
	end
	
	-- cover content outside fullscreen frame
	love.graphics.setColor({offscreenBackgroundColor[1], offscreenBackgroundColor[2], offscreenBackgroundColor[3], 255})
	love.graphics.rectangle("fill", ui.fullScreenOffsetX - 800, ui.fullScreenOffsetY, 800, 600)
	love.graphics.rectangle("fill", ui.fullScreenOffsetX + 800, ui.fullScreenOffsetY, 800, 600)
end

function ui:update(dt)
	mouseX, mouseY = love.mouse.getPosition()
	mouseX = mouseX - ui.fullScreenOffsetX
	mouseY = mouseY - ui.fullScreenOffsetY
	
	local isAnyHovered = false
	for i = 1, #self.displayTexts do
		local displayText = self.displayTexts[i]
		
		if displayText:isHovered(mouseX, mouseY) and displayText:getAction() ~= "" then
			isAnyHovered = true
		end
	end
	
	if isAnyHovered then
		love.mouse.setCursor(ui.cursors.hand)
	else
		love.mouse.setCursor(ui.cursors.arrow)
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
function ui:printTextByCharacter(text, x, y, width, height, color, font) -- only supports printing in a line (i.e. no word wrap)
	love.graphics.setFont(font)
	love.graphics.setColor(color)
	
	for i = 1, #text do
		love.graphics.print(string.sub(text, i, i), x, y)
		
		x = x + width
	end
end

return ui