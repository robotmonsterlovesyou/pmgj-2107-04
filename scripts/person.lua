person = inheritsFrom( nil )

guyWidth = 40
guyHeight = 40
speed = 8

function person:init(options)
	local x = options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber
	self.collisionEntities = options.collisionEntities

	self.sfxPunch = audio.loadSound("audio/sfx_attack_slap.wav")
	self.sfxJumpPlayer1 = audio.loadSound("audio/sfx_player1_jump.wav")
	self.sfxJumpPlayer2 = audio.loadSound("audio/sfx_player2_jump.wav")
	self.sfxSuperheroLanding = audio.loadSound("audio/sfx_attack_slam.wav")
	self.sfxJumpLand = audio.loadSound("audio/sfx_player_landing.wav")

	self.vx = speed
	self.vy = 0

	self.minY = 768 - 120;

	function addGuySpriteSheet()

		local options = {width = 100, height = 139, sheetContentWidth=2500, sheetContentHeight=139, numFrames = 25}

		-- local options =
		-- {
		--     frames = {

		--     },
		--     sheetContentWidth=2176, sheetContentHeight=139
		-- }

		-- local currentX = 0
		-- function addFrame(xDistanceFromLast, width)
		-- 	local newX = currentX + xDistanceFromLast
		-- 	table.insert(options.frames, {
		-- 		x = newX,
		-- 		y = 0,
		-- 		width = width or 94,
		-- 		height = 139
		-- 	})
		-- 	currentX = newX
		-- end 

		-- addFrame(20)
		-- addFrame(93, 87)
		-- addFrame(93)

		-- addFrame(90)
		-- addFrame(90)

		-- -- jump
		-- addFrame(90)
		-- addFrame(85)
		-- addFrame(85)
		-- addFrame(90)
		-- addFrame(110)
		-- addFrame(110)
		-- addFrame(100)
		-- addFrame(94)
		-- addFrame(92)
		-- addFrame(100)
		-- addFrame(100)
		-- addFrame(95)
		-- addFrame(88)
		
		-- -- first surprise appears
		-- addFrame(87)
		-- addFrame(90)
		-- addFrame(86, 90)
		-- addFrame(84, 83)
		-- addFrame(80, 86)


		-- addFrame(80, 86)

		local sheet = graphics.newImageSheet( "images/players/Redguy.png", options )
		if self.teamNumber == 2 then
			sheet = graphics.newImageSheet( "images/players/Blueguy.png", options )
		end

		local sequenceData = {
			{ name = "run", 
			frames= { 1, 2, 3, 4, 5},
			time=350, loopCount=0 },

			{ name = "jump", 
			frames= { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
			time=900, loopCount=1 },

			{ name = "stand", 
			frames= { 3, 23 },
			time=500, loopCount=0 },

			{ name = "punch", 
			frames= { 25, 25 },
			time=100, loopCount=1 },

			{ name = "bePunched", 
			frames= { 19, 20, 21, 22 },
			time=100, loopCount=1 },

			-- { name = "jump", 
			-- frames= { 9, 10, 11, 12 }, 
			-- time=500, loopCount=1 },
			-- { name = "land", 
			-- frames= { 13, 14, 15 }, 
			-- time=500, loopCount=1 }
		}

		self.guy = display.newSprite( sheet, sequenceData )

		self.guy.x = 0
		self.guy.y = 0
		self.guy.xScale = 0.70
		self.guy.yScale = 0.70

		self.guy:setSequence( "run" )
		self.guy:play()
	end 

	addGuySpriteSheet()

	self.body = display.newGroup()
	self.body:insert(self.guy)
	self.layer:insert(self.body)
	self.body.x = x
	self.body.y = y
	-- self.body = display.newRect(x, y, 25, 30) 
	-- self.body:setFillColor(1, 0, 0)
	-- self.layer:insert(self.body)

	self.onFloor = true
	self.againstWall = false 
	self.againstFloor = true
	self.jumping = false
	self.frozen = false
	self.backVx = 0

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

function person:takeItem(item)
	self.item = item
	self.item.held = true
	self.item.body.x = 0
	self.item.body.y = 0
	self.body:insert(self.item.body)
end 

function person:useItem()
	self.frozen = true
	self.guy:setSequence( "stand" )
	self.guy:play()
	
	transition.pause(self.teamNumber .. "itemRotation")
	if self.itemDelay then
		timer.cancel(self.itemDelay)
	end
	self.item.body.rotation = 0

	timer.performWithDelay(1000, function()
		self:dropItem()
		self.frozen = false
	end)
end 

function person:dropItem()
	if self.item then
		self.item.held = false
		self.item.body.x = math.random(1024 - 200) + 100
		self.item.body.y = math.random(568) + 100
		self.item.layer:insert(self.item.body)
		self.item = nil
	end
end

function person:bePunched()
	self:dropItem()
	if self.vx > 0 then 
		self.backVx = -10
	else 
		self.backVx = 10
	end
	self.vy = -10
	-- self.frozen = true
	-- self.guy:setSequence( "stand" )
	-- self.guy:play()

	self.guy:setSequence( "bePunched" )
	self.guy:play()
end 

function person:punch()
	self.target:bePunched()
	audio.play(self.sfxPunch)

	self.guy:setSequence( "punch" )
	self.guy:play()

	timer.performWithDelay(100, function()
		self.guy:setSequence( "run" )
		self.guy:play()
	end)
end

function person:setPunchTarget(persons)

	-- override size for bigger punch overlap
	local guyWidth = 50
	local guyHeight = 50

	local newTarget
	for i, person in ipairs(persons) do
		if person ~= self then
			if (person.body.x + guyWidth/2) > (self.body.x - guyWidth/2) and
				(person.body.x - guyWidth/2) < (self.body.x + guyWidth/2) and
				(person.body.y + guyHeight/2) > (self.body.y - guyHeight/2) and
				(person.body.y - guyHeight/2) < (self.body.y + guyHeight/2) then

				newTarget = person 
			end
		end
	end
	self.target = newTarget
end

function person:handleUserAction(event)
	if self.backVx ~= 0 then return end

	if event.phase == "began" and event.teamNumber == self.teamNumber then

		------------ punch!
		if self.target then
			self:punch()

		------------ normal jump
		else 
			if self.againstWall then
				self.vx = self.vx * -1
				self.againstWall = false 
				self.guy.xScale = self.guy.xScale * -1
			end 

			if self.teamNumber == 1 then
				audio.play(self.sfxJumpPlayer1)
			elseif self.teamNumber == 2 then
				audio.play(self.sfxJumpPlayer2)
			end
				
			self.vy = -16
			self.guy:setSequence("jump")
			self.guy:play()
			self.againstFloor = false
			self.jumping = true

			local context = self
			if context.item then
				self.itemDelay = timer.performWithDelay(200, function()
					if context.item then
						transition.to(context.item.body, {time=350, rotation=360, tag=context.teamNumber .. "itemRotation", onComplete=function()
							if context.item then 
								context.item.body.rotation=0
							end 
						end})
					end
				end)
			end 
		end
	end 
end

function person:update()
	if self.frozen then return end

	local maxRight = 1000
	local maxLeft = 24

	-- gravity
	self.vy = self.vy + 1
	self.body.y = math.min(self.body.y + self.vy, self.minY)
			
	if self.body.y == self.minY then
		local isSuperheroLanding = false
		if self.vy > 25 then
			isSuperheroLanding = true
		end
		self.vy = 0
		if self.againstFloor == false then 
			self.againstFloor = true
			self.backVx = 0
			self.guy:setSequence( "run" )
			self.guy:play()
			if isSuperheroLanding then
				audio.play(self.sfxSuperheroLanding)
			else
				audio.play(self.sfxJumpLand)
			end
		end 
	else
		self.againstFloor = false
	end 

	if self.backVx ~= 0 then
		if self.backVx > 0 then 
			self.body.x = math.min(self.body.x + self.backVx, maxRight)
		else 
			self.body.x = math.max(self.body.x + self.backVx, maxLeft)
		end 

		if math.abs(self.backVx) < 1 then
			self.backVx = 0 
		else 
			self.backVx = self.backVx * 0.95
		end

	else
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

		if self.againstWall and self.againstFloor then
			self.vx = self.vx * -1
			self.againstWall = false 
			self.guy.xScale = self.guy.xScale * -1
		end
	end 
end

function person:setMinY(platforms)
	local latestMinY = 768 - 120

	local guyX = self.body.x
	local guyY = self.body.y

	for k, platform in pairs(platforms) do
		local platformBounds = getBoundsFromEntity(platform)
		platform.body:setFillColor(255, 255, 255)

		if (guyY <= platformBounds.y and
			platformBounds.x - platformBounds.width/2 < guyX and
			platformBounds.x + platformBounds.width/2 > guyX) then

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
	bounds.x = entity.body.x
	bounds.y = entity.body.y
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