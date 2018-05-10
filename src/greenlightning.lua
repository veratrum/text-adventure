local game = {}

-- this module doesn't store data. just a set of methods to create and return the players and rooms
	
function game.createPlayers()
	local player = require("player")
	
	local players = {}
	
	table.insert(players, player.new("Samuel", "SAMUEL"))
	table.insert(players, player.new("Alison", "ALISON"))
	
	players[1]:addToInventory("50c coin", "COIN")
	players[1]:addToInventory("Small stone", "STONE", 5)
	
	return players
end

function game.createRooms()
	local room = require("room")
	local page = require("page")
	
	local rooms = {}
	
	page.defineStyle("greenaction", "dgreen", "ggreen")
	page.defineStyle("darktext", "grey", "grey")
	
	table.insert(rooms, room.new("Back yard of 14 Gravel Road", "14GR BACK"))
	table.insert(rooms, room.new("Hammock", "HAMMOCK"))
	
	rooms[1]:addPage(page.new()
	:addPhraseN("You're in the back yard of 14 Gravel Road."):style("darktext")
	:addPhraseN("Your mother is just inside the house washing dinner and cooking the dishes.")
	:addPhraseN("You're free to do whatever you want until she calls you back in.")
	:addPhraseN("There's several options available to you here:")
	:addPhrase("Go for a walk in the ")
	:addPhrase("forest"):click("go", "FOREST"):style("greenaction")
	:addPhraseN(".")
	:addPhrase("Take a swim in the ")
	:addPhrase("ocean"):click("go", "HAMMOCK")
	:addPhraseN("."))
	rooms[1]:addPage(page.new()
	:addPhraseN("An ancient willow tree surveys the property.")
	:addPhrase("There's a ")
	:addPhrase("hammock"):click("go", "HAMMOCK")
	:addPhraseN(" suspended from the immense tree.")
	:addPhraseN("You can't remember the last time it was used."))
	
	rooms[1]:addAction("enter", function(data, game, plotVariables)
		local pages = util.shallowcopy(game:getAllPages()) -- default pages
		
		if plotVariables["night"] == true then
			pages[1] = page.new()
			:addPhraseN("It's the middle of the night and too dark to see anything.")
			:addPhrase("You might as well lie back down, who knows what might lurk in the darkness beyond these ")
			:addPhrase("cotton confines"):click("go", "HAMMOCK")
			:addPhraseN(".")
			
			pages[2] = nil
		end
		
		return pages
	end)
	
	rooms[2]:addPage(page.new()
	:addPhraseN("The idea of taking a short nap in the hammock suddenly seems extremely enticing.")
	:addPhraseN("You lie down and fall into a deep slumber."))
	rooms[2]:addPage(page.new()
	:addPhrase("Excatly twelve hours later, you wake up and take a look ")
	:addPhrase("around"):click("go", "14GR BACK")
	:addPhrase("."))
	
	rooms[2]:addAction("enter", function(data, game, plotVariables)
		local pages = util.shallowcopy(game:getAllPages()) -- default pages
		
		plotVariables["night"] = not plotVariables["night"]
		
		return pages
	end)
	
	return rooms
end

function game.createPlotVariables()
	local plotVariables = {}
	
	plotVariables["night"] = false
	
	return plotVariables
end

return game