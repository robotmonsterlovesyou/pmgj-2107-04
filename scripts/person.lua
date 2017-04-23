person = inheritsFrom( nil )

function person:init(options)
	local x = 600--options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber
	self.collisionEntities = options.collisionEntities

	self.vx = 6
	self.vy = 0

	self.minY = 768 - 120;

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
		self.guy.x = 200
		self.guy.y = 200
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

	self.actionPressedListener = function(event)
		self:handleUserAction(event)
	end 
	Runtime:addEventListener("actionPressed", self.actionPressedListener)

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end 

function person:handleUserAction(event)
	if event.phase == "began" then
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
	local maxRight = 1000
	local maxLeft = 24

	self.vy = self.vy + 1
	self.body.y = math.min(self.body.y + self.vy, self.minY)

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

	local latestMinY = 768 - 120

	local guyBounds = getBoundsFromEntity(self)

	for k, platform in pairs(platforms) do
		local platformBounds = getBoundsFromEntity(platform)
		platform.body:setFillColor(255, 255, 255)

		if (platformBounds.y > guyBounds.y and
			guyBounds.y + guyBounds.height < platformBounds.y and
			platformBounds.x < guyBounds.x and
			guyBounds.x + guyBounds.width < platformBounds.x + platformBounds.width) then
			if (platformBounds.y <= latestMinY) then
				latestMinY = platformBounds.y
				platform.body:setFillColor(0, 255, 0)
			end
		end

	end

	self.minY = latestMinY
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