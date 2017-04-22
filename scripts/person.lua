person = inheritsFrom( nil )

function person:init(options)
	local x = 600--options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber

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
	self.body.y = math.min(self.body.y + self.vy, minY)
	self.vy = self.vy + 1

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

return person