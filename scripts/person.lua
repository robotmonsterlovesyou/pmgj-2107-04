person = inheritsFrom( nil )

function person:init(options)
	local x = options.x
	local y = options.y
	self.layer = options.layer
	self.teamNumber = options.teamNumber

	self.body = display.newRect(x, y, 25, 30) 
	self.body:setFillColor(1, 0, 0)
	self.layer:insert(self.body)

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end 

function person:update()
	self.body.x = self.body.x + 6
end 

return person