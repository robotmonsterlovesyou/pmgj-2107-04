person = inheritsFrom( nil )

function person:init(options)
	local x = 600--options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber
	self.collisionEntities = options.collisionEntities

	self.onFloor = true

	self.againstFloor = false

	self.body = display.newRect(x, y, 25, 30) 
	self.body:setFillColor(1, 0, 0)
	self.layer:insert(self.body)

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)

	self.vx = 6
	self.vy = 0

	self.actionPressedListener = function(event)
		if event.phase == "began" then
			if self.againstWall then
				self.vx = self.vx * -1
				self.againstWall = false 
			end 
 			
 			self.vy = -10
		end 
	end 

	self.againstWall = false 

	Runtime:addEventListener("actionPressed", self.actionPressedListener)
end 

function person:update()

	local minY = 768 - 120
	currentCollision = checkCollision(self, self.collisionEntities)
	if currentCollision then
		self.body.y = math.min(self.body.y + self.vy, getBoundsFromEntity(currentCollision).y)
		if self.againstFloor == false then
			self.againstFloor = true
			self.vy = 0
		end
	else
		self.vy = self.vy + 1
		self.body.y = self.body.y + self.vy
	end

	local maxRight = 1000
	local maxLeft = 24

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

function getBoundsFromEntity (entity)

	bounds = {}
	bounds.x = entity.body.x - (entity.body.width / 2)
	bounds.y = entity.body.y - (entity.body.height / 2)
	bounds.width = entity.body.width
	bounds.height = entity.body.height

	return bounds

end

function checkCollision (entity, entities)

	local entityBounds = getBoundsFromEntity(entity)

	for k, v in pairs(entities) do

		local compareBounds = getBoundsFromEntity(entities[k])

		if (entityBounds.x < compareBounds.x + compareBounds.width and
			entityBounds.x + entityBounds.width > compareBounds.x and
			entityBounds.y < compareBounds.y + compareBounds.height and
			entityBounds.height + entityBounds.y > compareBounds.y) then

			return entities[k]

		end

	end

	return nil

end

return person