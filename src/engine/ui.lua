local UI = Object:extend()

UI.windowWidth = 800
UI.windowHeight = 600

UI.environmentX = -800
UI.environmentX2 = 0
UI.inventoryX = 700
UI.inventoryX2 = -100
UI.menuSlideSpeed = 20

UI.normalFonts = {}
UI.boldFonts = {}
UI.normalPath = "font/DejaVuSansMono.ttf"
UI.boldPath = "font/DejaVuSansMono-Bold.ttf"
UI.fontSizes = {8, 10, 12, 16, 20, 24, 32, 48}
UI.offscreenBackgroundColor = {16, 16, 16}

UI.fullScreenOffsetX = 0
UI.fullScreenOffsetY = 0
UI.textPaddingX = 40
UI.textPaddingY = 20
UI.characterWidth = 8
UI.characterHeight = 20
UI.pageBottomHeight = UI.windowHeight - UI.textPaddingY - UI.characterHeight / 2

UI.totalColumns = (UI.windowWidth - UI.textPaddingX * 2) / UI.characterWidth
UI.totalRows = (UI.windowHeight - UI.textPaddingY * 2) / UI.characterHeight

function UI:new()
	love.window.setFullscreen(true, "desktop") -- "exclusive" for changing resolution
	--love.window.setMode(windowWidth, windowHeight, {})
	love.window.setTitle("Test")
	
	UI.fullScreenOffsetX = (love.graphics.getWidth() - UI.windowWidth) / 2
	UI.fullScreenOffsetY = (love.graphics.getHeight() - UI.windowHeight) / 2
	
	UI.cursors = {}
	UI.cursors.arrow = love.mouse.getSystemCursor("arrow")
	UI.cursors.hand = love.mouse.getSystemCursor("hand")
	
	UI.backgroundImage = love.graphics.newImage("img/background.png")
	UI.inventoryImage = love.graphics.newImage("img/inventory.png")
	UI.environmentImage = love.graphics.newImage("img/environment.png")
	love.graphics.setNewFont(12)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setBackgroundColor(UI.offscreenBackgroundColor[1], UI.offscreenBackgroundColor[2], UI.offscreenBackgroundColor[3])
	
	local SlideMenu = require("slidemenu")
	local EnvironmentMenu = require("environmentmenu")
	local InventoryMenu = require("inventorymenu")
	self.environmentMenu = EnvironmentMenu(UI.environmentX, UI.environmentX2, UI.menuSlideSpeed, UI.environmentImage)
	self.inventoryMenu = InventoryMenu(UI.inventoryX, UI.inventoryX2, UI.menuSlideSpeed, UI.inventoryImage)
	print(self.environmentMenu.x1)
	print(self.environmentMenu.x2)
	print(self.inventoryMenu.x1)
	print(self.inventoryMenu.x2)
	
	UI.fontSizes = {8, 10, 12, 16, 20, 24, 48}
	
	for i = 1, 7 do
		UI.normalFonts[i] = love.graphics.newFont(UI.normalPath, UI.fontSizes[i])
		UI.boldFonts[i] = love.graphics.newFont(UI.boldPath, UI.fontSizes[i])
	end
	
	UI.normalFonts[8] = love.graphics.newFont(UI.normalPath, 8)
	UI.boldFonts[8] = love.graphics.newFont(UI.boldPath, 8)
	UI.normalFonts[10] = love.graphics.newFont(UI.normalPath, 10)
	UI.boldFonts[10] = love.graphics.newFont(UI.boldPath, 10)
	UI.normalFonts[12] = love.graphics.newFont(UI.normalPath, 12)
	UI.boldFonts[12] = love.graphics.newFont(UI.boldPath, 12)
	UI.normalFonts[16] = love.graphics.newFont(UI.normalPath, 16)
	UI.boldFonts[16] = love.graphics.newFont(UI.boldPath, 16)
	UI.normalFonts[20] = love.graphics.newFont(UI.normalPath, 20)
	UI.boldFonts[20] = love.graphics.newFont(UI.boldPath, 20)
	UI.normalFonts[24] = love.graphics.newFont(UI.normalPath, 24)
	UI.boldFonts[24] = love.graphics.newFont(UI.boldPath, 24)
	UI.normalFonts[32] = love.graphics.newFont(UI.normalPath, 32)
	UI.boldFonts[32] = love.graphics.newFont(UI.boldPath, 32)
	UI.normalFonts[48] = love.graphics.newFont(UI.normalPath, 48)
	UI.boldFonts[48] = love.graphics.newFont(UI.boldPath, 48)
	
	self.mouseX = 0
	self.mouseY = 0
	self.menuState = "center"
	
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
	love.graphics.draw(UI.backgroundImage, UI.fullScreenOffsetX, UI.fullScreenOffsetY)
	
	self:drawContent()
	self:drawSideMenus()
	
	love.graphics.setFont(UI.boldFonts[10])
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
	if self.menuState == "left" then
		self.environmentMenu:draw(self.inventory)
		self.inventoryMenu:draw(self.inventory)
	else
		self.inventoryMenu:draw(self.inventory)
		self.environmentMenu:draw(self.inventory)
	end
	
	-- cover content outside fullscreen frame
	love.graphics.setColor({UI.offscreenBackgroundColor[1], UI.offscreenBackgroundColor[2], UI.offscreenBackgroundColor[3], 255})
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
	if self.menuState == "center" then
		if key == "right" then
			self:changeMenu("left")
		elseif key == "left" then
			self:changeMenu("right")
		end
	elseif self.menuState == "left" then
		if key == "left" then
			self:changeMenu("center")
		end
	elseif self.menuState == "right" then
		if key == "right" then
			self:changeMenu("center")
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

function UI:changeMenu(menu)
	self.menuState = menu
	
	if self.menuState == "center" then
		self.environmentMenu:moveOut()
		self.inventoryMenu:moveOut()
	elseif self.menuState == "left" then
		self.environmentMenu:moveOut()
		self.inventoryMenu:moveIn()
	elseif self.menuState == "right" then
		self.environmentMenu:moveIn()
		self.inventoryMenu:moveOut()
	end
end

return UI
