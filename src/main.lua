function love.load()
	Object = require("classic")
	Game = require("game")
	
	game = Game("greenlightning")
end

function love.draw()
	game:draw()
end

function love.update(dt)
	game:update(dt)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	game:keyPressed(key)
end

function love.mousepressed(x, y, button, istouch)
	game:mousePressed(x, y, button, isTouch)
end

function love.mousereleased(x, y, button, istouch)
	game:mouseReleased(x, y, button, isTouch)
end
