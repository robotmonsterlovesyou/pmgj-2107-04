person = inheritsFrom( nil )

function person:init(options)
	local x = options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber
	self.collisionEntities = options.collisionEntities

	self.vx = 6
	self.vy = 0

	function addGuySpriteSheet()
		local options =
		{
		    frames = {},
		    sheetContentWidth=2176, sheetContentHeight=139
		}

		local currentX = 0
		function addFrame(xDistanceFromLast, width)
			local newX = currentX + xDistanceFromLast
			table.insert(options.frames, {
				x = newX,
				y = 0,
				width = width or 94,
				height = 139
			})
			currentX = newX
		end 

		addFrame(20)
		addFrame(93, 87)
		addFrame(93)

		addFrame(90)
		addFrame(90)

		-- jump
		addFrame(90)
		addFrame(85)
		addFrame(85)
		addFrame(90)
		addFrame(110)
		addFrame(110)
		addFrame(100)
		addFrame(94)
		addFrame(92)
		addFrame(100)
		addFrame(100)
		addFrame(95)
		addFrame(88)
		
		-- first surprise appears
		addFrame(87)
		addFrame(90)
		addFrame(86, 90)
		addFrame(84, 83)
		addFrame(80, 86)

		local sheet = graphics.newImageSheet( "images/players/Redguy.png", options )
		if self.teamNumber == 2 then
			sheet = graphics.newImageSheet( "images/players/Blueguy.png", options )
		end

		local sequenceData = {
			{ name = "run", 
			frames= { 1, 2, 3, 4, 5 },
			time=400, loopCount=0 },

			{ name = "jump", 
			frames= { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
			time=900, loopCount=1 },

			{ name = "stand", 
			frames= { 3, 23 },
			time=500, loopCount=0 },

			-- { name = "jump", 
			-- frames= { 9, 10, 11, 12 }, 
			-- time=500, loopCount=1 },
			-- { name = "land", 
			-- frames= { 13, 14, 15 }, 
			-- time=500, loopCount=1 }
		}

		self.guy = display.newSprite( sheet, sequenceData )
		self.guy.x = x
		self.guy.y = y
		self.guy.xScale = 0.65
		self.guy.yScale = 0.65

		self.guy:setSequence( "run" )
		self.guy:play()
	end 

	addGuySpriteSheet()

	self.body = self.guy
	self.layer:insert(self.body)
	-- self.body = display.newRect(x, y, 25, 30) 
	-- self.body:setFillColor(1, 0, 0)
	-- self.layer:insert(self.body)

	self.onFloor = true
	self.againstWall = false 
	self.againstFloor = false
	self.jumping = false

	if self.teamNumber == 2 then
		self.guy.xScale = self.guy.xScale * -1
		self.vx = self.vx * -1
	end

	self.actionPressedListener = function(event)
		self:handleUserAction(event)
	end 
	Runtime:addEventListener("actionPressed", self.actionPressedListener)

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end 

function person:handleUserAction(event)
	if event.phase == "began" and event.teamNumber == self.teamNumber then
		if self.againstWall then
			self.vx = self.vx * -1
			self.againstWall = false 
			self.body.xScale = self.body.xScale * -1
		end 
			
		self.vy = -15
		self.body:setSequence("jump")
		self.body:play()
		self.againstFloor = false
		self.jumping = true
	end 
end

function person:update()
	local floorY = 768 - 120
	local maxRight = 1000
	local maxLeft = 24

	local minY = floorY

	currentCollision = checkCollision(self, self.collisionEntities)
	if currentCollision then
		self.body.y = math.min(self.body.y + self.vy, getBoundsFromEntity(currentCollision).y)
		if self.againstFloor == false then
			self.guy:setSequence( "run" )
			self.guy:play()
			self.againstFloor = true
			self.vy = 0
		end
	else
		self.vy = self.vy + 1
		self.body.y = self.body.y + self.vy
	end

	local newXLocation
	if self.vx > 0 then 
		-- moving right
		newXLocation = math.min(self.body.x + self.vx, maxRight)
		if newXLocation == maxRight then
			self.againstWall = true
		end 
	else 
		-- moving left
		newXLocation = math.max(self.body.x + self.vx, maxLeft)
		if newXLocation == maxLeft then
			self.againstWall = true
		end 
	end 
	self.body.x = newXLocation
end

function person:setMinY(platforms)
	local guyX = self.body.x
	local guyWidth = 30

	local floorY = 768 - 120
	local minY = floorY

	for k, platform in pairs(platforms) do
		local platformBounds = getBoundsFromEntity(platform)

		if (guyX < platformBounds.x + platformBounds.width and
			guyX + guyWidth > platformBounds.x) then

			local platformY = platformBounds.y
			if platformY < minY then
				minY = platformY
			end 
		end
	end

	self.minY = minY
	print(minY)
end 

function getBoundsFromEntity (entity)
	bounds = {}
	bounds.x = entity.body.x - (entity.body.width / 2)
	bounds.y = entity.body.y - (entity.body.height / 2)
	bounds.width = entity.body.width
	bounds.height = entity.body.height
	return bounds
end

function checkCollision (guy, entities)
	local guyX = guy.body.x
	local guyY = guy.body.y
	local guyWidth = 30
	local guyHeight = 30

	for k, v in pairs(entities) do

		local compareBounds = getBoundsFromEntity(entities[k])

		if (guyX < compareBounds.x + compareBounds.width and
			guyX + guyWidth > compareBounds.x and
			guyY < compareBounds.y + compareBounds.height and
			guyHeight + guyY > compareBounds.y) then
			return entities[k]
		end
	end

	return nil
end

return person