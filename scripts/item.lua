item = inheritsFrom( nil )


itemTypeFlameThrower = 1
itemTypeExtinguisher = 2

itemWidth = 40
itemHeight = 40

function item:init(options)
	local layer = options.layer
	local x = options.x
	local y = options.y

	self.layer = layer
	self.width = itemWidth
	self.height = itemHeight
	self.itemType = options.itemType
	
	self.shakeLayer = display.newGroup()
	self.layer:insert(self.shakeLayer)

	self.body = display.newGroup()
	self.shakeLayer:insert(self.body)

	self.body.x = x
	self.body.y = y

	self.box = display.newRect(0, 0, self.width, self.height)
	self.letter = display.newText( "F", 0, 0, native.systemFont, 16 )
	self.box:setStrokeColor(1,0,0,1)
	self.letter:setFillColor(1,0,0,1)

	self.image = display.newImageRect("images/players/weapon-blowtorch.png", 50, 42)

	if self.itemType == itemTypeExtinguisher then
		self.image = display.newImageRect("images/players/weapon-fire-extinguisher.png", 50, 42)
		self.box:setStrokeColor(0,0,1,1)
		self.letter:setFillColor(0,0,1,1)
		self.letter.text = "E"
	end 

	self.image.x = 30

	self.body:insert(self.image)
	self.box:setFillColor(0,0,0,0)
	self.box.strokeWidth = 2

	self.box.isVisible = false
	self.letter.isVisible = false

	self.body:insert(self.box)
	self.body:insert(self.letter)

	self.held = false

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end

function item:setupHold()
	if self.image.xScale > 0 then
		self.image.x = 30
	else 
		self.image.x = -30
	end 
end 

function item:update()
	if self.held then
		if (self.owner.guy.xScale > 0 and self.image.xScale < 0)
			or (self.owner.guy.xScale < 0 and self.image.xScale > 0) then
			self.image.xScale = self.image.xScale * -1

			if self.image.xScale > 0 then
				self.image.x = 30
			else 
				self.image.x = -30
			end 
		end 
	else 
		if self.image.xScale > 0 then
			self.image.x = 0
		else 
			self.image.x = 0
		end
	end 
	-- self.angle = self.angle + 10
 --    if self.angle > 360 then self.angle = self.angle - 360 end

 --    local radAngle = (self.angle) * (math.pi / 180); 
 --    local rotatedX = math.cos(radAngle) * (self.pointX);
 --    self.shipSpriteLayer.x = rotatedX

	-- if self.held then
	-- 	self.body.x = self.owner.body.x
	-- 	self.body.y = self.owner.body.y
	-- end 
end 

function item:checkCollisions(persons)
	if self.held then return end 

	for k, person in pairs(persons) do
		if (person.body.x + guyWidth/2) > (self.body.x - itemWidth/2) and
			(person.body.x - guyWidth/2) < (self.body.x + itemWidth/2) and
			(person.body.y + guyHeight/2) > (self.body.y - itemHeight/2) and
			(person.body.y - guyHeight/2) < (self.body.y + itemHeight/2) then

			if person.item == nil then
				person:takeItem(self)
				self.owner = person
			else 
				person:dropItem()
				person:takeItem(self)
				self.owner = person
			end
		end 
	end 
end 

return item