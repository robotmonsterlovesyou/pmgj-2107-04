zone = inheritsFrom( nil )

zoneStateNormal = 1
zoneStateOnFire = 2

zoneWidth = 100
zoneHeight = 100

function zone:init(options)
	local x = options.x
	local y = options.y

	self.layer = options.layer
	self.width = zoneWidth
	self.height = zoneHeight
	self.zoneState = options.zoneState or zoneStateNormal
	self.artPieceIndex = options.artPieceIndex
	
	self.body = display.newGroup()
	self.layer:insert(self.body)
	self.body.x = x
	self.body.y = y

	self.box = display.newRect(0, 0, self.width, self.height)
	self.letter = display.newText( "zone", 0, 0, native.systemFont, 16 )
	self.box:setStrokeColor(1,1,1,1)
	self.letter:setFillColor(1,0,0,1)
	self.box:setFillColor(0,0,0,0)
	self.box.strokeWidth = 2
	self.body:insert(self.box)
	self.body:insert(self.letter)
	self.box.isVisible = false

	local artWidth = {} 
	artWidth[1] = 100
	artWidth[2] = 81
	artWidth[3] = 100
	artWidth[4] = 100
	artWidth[5] = 97
	artWidth[6] = 66

	local artHeight = {}
	artHeight[1] = 78
	artHeight[2] = 100
	artHeight[3] = 100
	artHeight[4] = 75
	artHeight[5] = 138
	artHeight[6] = 184

	local i = display.newImageRect("images/art/art-piece-" .. self.artPieceIndex .. ".png", 
		artWidth[self.artPieceIndex], artHeight[self.artPieceIndex])

	self.body:insert(i)

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end

function zone:update()
	if self.zoneState == zoneStateNormal then
		self.letter:setFillColor(0,0,1,1)
		self.box:setStrokeColor(0,0,1,1)
	else 
		self.letter:setFillColor(1,0,0,1)
		self.box:setStrokeColor(1,0,0,1)
	end 
end 

function zone:checkCollisions(persons)
	if self.held then return end 

	for k, person in pairs(persons) do
		if (person.body.x + guyWidth/2) > (self.body.x - zoneWidth/2) and
			(person.body.x - guyWidth/2) < (self.body.x + zoneWidth/2) and
			(person.body.y + guyHeight/2) > (self.body.y - zoneHeight/2) and
			(person.body.y - guyHeight/2) < (self.body.y + zoneHeight/2) then

			if person.item ~= nil then
				if person.teamNumber == 1 
					and person.item.itemType == itemTypeFlameThrower
					and self.zoneState ~= zoneStateOnFire then
						self.zoneState = zoneStateOnFire
						person:useItem()

				elseif person.teamNumber == 2 
					and person.item.itemType == itemTypeExtinguisher
					and self.zoneState ~= zoneStateNormal then
						self.zoneState = zoneStateNormal
						person:useItem()
				end 
			end
		end 
	end 
end 

return zone