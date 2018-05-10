local game = {}
game.__index = game

util = require("util")
colors = require("colors")

-- gameData will generally stay the same and is there just to provide support for different games on the same engine
-- there can be multiple saves for each game selected by the menu system

function game.new(gameDataLocation)
	local self = setmetatable({}, game)
	
	local UI = require("ui")
	local gameData = require(gameDataLocation)

	self.ui = UI.new()
	
	self.rooms = gameData:createRooms()
	self.players = gameData:createPlayers() -- represents multiple individuals you can control
	self.plotVariables = gameData.createPlotVariables() -- flags that can change throughout the game
	
	--self.currentRoom = self.rooms[1]:getID() -- initialising this would make the starting room's exit action execute
	self.currentPlayer = self.players[1]:getID()
	--self.currentPage = 1
	
	self.currentPages = {} -- represents a copy of pages that only exists while you are in that room. can be modified by custom actions
	
	self:changeRoom(self.rooms[1]:getID())
	self:updateUIInventory()
	
	return self
end

function game:draw()
	self.ui:draw()
end

function game:update(dt)
	self.ui:update(dt)
end

function game:keyPressed(key)
	self.ui:keyPressed(key)
end

function game:mousePressed(x, y, button, isTouch)
	self.ui:mousePressed(x, y, button, isTouch)
end

function game:mouseReleased(x, y, button, isTouch)
	self.ui:mouseReleased(x, y, button, isTouch)
end

function game:loadState(saveDataLocation) -- implement later
	loadData = require(saveDataLocation)
end
	
function game:saveState(saveDataLocation) -- implement later
	-- write data to location
end

function game:getAllPages()
	return self.currentPages
end

function game:nextPage()
	self.currentPage = self.currentPage + 1
end

function game:previousPage()
	self.currentPage = self.currentPage - 1
end

function game:changeRoom(id)
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

function game:executeAction(actionName, data)
	local room = util.searchByID(self.rooms, self.currentRoom)
	
	local action = room:getAction(actionName)
	
	print(actionName)
	
	self.currentPages = action(data, self, self.plotVariables)
	self:updateUIPage()
end

function game:updateUIPage()
	local currentPage = self.currentPages[self.currentPage]

	self.ui:setPage(currentPage)
end

function game:updateUIInventory()
	local player = util.searchByID(self.players, self.currentPlayer)

	self.ui:setInventory(player:getInventory())
end

return game