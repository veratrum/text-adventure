local Game = Object:extend()

util = require("util")
colors = require("colors")

-- gameData will generally stay the same and is there just to provide support for different games on the same engine
-- there can be multiple saves for each game selected by the menu system

function Game:new(gameDataLocation)
	local UI = require("ui")
	local gameData = require(gameDataLocation)

	self.ui = UI()
	
	self.rooms = gameData.createRooms()
	self.players = gameData.createPlayers() -- represents multiple individuals you can control
	self.plotVariables = gameData.createPlotVariables() -- flags that can change throughout the game
	
	--self.currentRoom = self.rooms[1]:getID() -- initialising this would make the starting room's exit action execute
	self.currentPlayer = self.players[1]:getID()
	--self.currentPage = 1
	
	self.currentPages = {} -- represents a copy of pages that only exists while you are in that room. can be modified by custom actions
	
	self:changeRoom(self.rooms[1]:getID())
	self:updateUIInventory()
end

function Game:draw()
	self.ui:draw()
end

function Game:update(dt)
	self.ui:update(dt)
end

function Game:keyPressed(key)
	self.ui:keyPressed(key)
end

function Game:mousePressed(x, y, button, isTouch)
	self.ui:mousePressed(x, y, button, isTouch)
end

function Game:mouseReleased(x, y, button, isTouch)
	self.ui:mouseReleased(x, y, button, isTouch)
end

function Game:loadState(saveDataLocation) -- implement later
	loadData = require(saveDataLocation)
end
	
function Game:saveState(saveDataLocation) -- implement later
	-- write data to location
end

function Game:getAllPages()
	return self.currentPages
end

function Game:nextPage()
	self.currentPage = self.currentPage + 1
end

function Game:previousPage()
	self.currentPage = self.currentPage - 1
end

function Game:changeRoom(id)
	local room = util.searchByID(self.rooms, self.currentRoom)
	
	local newRoom = util.searchByID(self.rooms, id)
	
	if newRoom ~= nil then
		if room ~= nil then -- when setting the room for the first time there is no previous room
			self:executeAction("exit")
		end
		
		self.currentRoom = id
		self.currentPage = 1
		
		self.currentPages = newRoom:getAllPages()
		
		self:executeAction("enter")
	end
end

function Game:executeAction(actionName, data)
	local room = util.searchByID(self.rooms, self.currentRoom)
	
	local action = room:getAction(actionName)
	
	print(actionName)
	
	self.currentPages = action(data, self, self.plotVariables)
	self:updateUIPage()
end

function Game:updateUIPage()
	local currentPage = self.currentPages[self.currentPage]

	self.ui:setPage(currentPage)
end

function Game:updateUIInventory()
	local player = util.searchByID(self.players, self.currentPlayer)

	self.ui:setInventory(player:getInventory())
end

return Game
