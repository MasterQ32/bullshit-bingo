local grid

local gameIsWon = false
local bullshit, cryout_for_help

local function reset()
	-- Slurp words every reset
	local words = { }
	do
		local f = io.open("words", "r")
		while true do
			local w = f:read("*line")
			if w then
				table.insert(words, w)
			else
				break
			end
		end
	end
	
	local function CELL(wildcard)
		local text
		if not wildcard then
			local idx = math.random(1, #words)
			text = words[idx]
			table.remove(words, idx)
		else
			text = "*"
		end
		return {
			wildcard = not not wildcard,
			selected = not not wildcard,
			text = text,
		}
	end

	grid =
	{
		[1] = {
			[1] = CELL(),
			[2] = CELL(),
			[3] = CELL(),
			[4] = CELL(),
			[5] = CELL(),
		},
		[2] = {
			[1] = CELL(),
			[2] = CELL(),
			[3] = CELL(),
			[4] = CELL(),
			[5] = CELL(),
		},
		[3] = {
			[1] = CELL(),
			[2] = CELL(),
			[3] = CELL(true),
			[4] = CELL(),
			[5] = CELL(),
		},
		[4] = {
			[1] = CELL(),
			[2] = CELL(),
			[3] = CELL(),
			[4] = CELL(),
			[5] = CELL(),
		},
		[5] = {
			[1] = CELL(),
			[2] = CELL(),
			[3] = CELL(),
			[4] = CELL(),
			[5] = CELL(),
		},
	}
	gameIsWon = false
end

reset()

local function checkHasWon()

	if gameIsWon then
		return
	end

	local hasWon = false
	
	-- Horiz
	for i=1,5 do
		local good = true
		for j=1,5 do
			good = good and grid[i][j].selected
		end
		if good then hasWon = true end
	end
	
	-- Vert
	for i=1,5 do
		local good = true
		for j=1,5 do
			good = good and grid[j][i].selected
		end
		if good then hasWon = true end
	end
	
	-- Diag
	local good1 = true
	local good2 = true
	for i=1,5 do
		good1 = good1 and grid[i][i].selected
		good2 = good2 and grid[6-i][i].selected
	end
	
	if good1 then hasWon = true end
	if good2 then hasWon = true end

	if hasWon then
		cryout_for_help:play()
		gameIsWon = hasWon
	end
	
end

function love.load()
	love.window.setMode(800, 800)
	love.window.setTitle("Buzzword Bingo - Made in 'Architektur für Anwendungssysteme'")
	love.graphics.setFont(love.graphics.newFont(18))
	bullshit = love.graphics.newImage "bullshit.png"
	cryout_for_help = love.audio.newSource "cryout.wav"
end

function love.update(dt)

	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local cs = 150
	
	for x=1,5 do
		for y=1,5 do
			local c = grid[x][y]
			c.x = cs*(x-1) + (w - 5*cs)/2
			c.y = cs*(y-1) + (h - 5*cs)/2
			c.size = cs
		end
	end

end

function love.mousepressed(px,py,btn)

	if gameIsWon then
		reset()
		return
	end

	for x=1,5 do
		for y=1,5 do
			local c = grid[x][y]
			if px >= c.x and
			   py >= c.y and
				 px < (c.x + c.size) and
				 py < (c.y + c.size) then
				c.selected = true
			end
		end
	end
	checkHasWon()
end

function love.keypressed(key)
	if key == "r" then
		reset()
	end
end

function love.draw()
	local g = love.graphics
	
	g.clear(255, 255, 255)
	for x=1,5 do
		for y=1,5 do
			local c = grid[x][y]
			
			if c.wildcard then
				g.setColor(128,128,255)
			elseif c.selected then
				g.setColor(128,255,128)
			else
				g.setColor(255,255,255)
			end
			
			g.rectangle(
				"fill",
				c.x, c.y,
				c.size, c.size)
			g.setColor(0,0,0)
			g.rectangle(
				"line",
				c.x, c.y,
				c.size, c.size)
			
			g.setColor(0,0,0)
			g.printf(
				c.text,
				c.x + 4,
				c.y + 0.5 * (c.size - g.getFont():getHeight()),
				c.size - 8,
				"center")
			
		end
	end
	
	if gameIsWon then
		g.setColor(0, 0, 0, 64)
		g.rectangle(
			"fill",
			0, 0,
			love.graphics.getWidth(),
			love.graphics.getHeight())
		g.setColor(255, 255, 255)
		g.draw(
			bullshit,
			(love.graphics.getWidth() - bullshit:getWidth()) / 2,
			(love.graphics.getHeight() - bullshit:getHeight()) / 2)
	end

end