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
	self.letter.isVisible = false

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

	self.normalImage = display.newImageRect("images/art/art-piece-" .. self.artPieceIndex .. ".png", 
		artWidth[self.artPieceIndex], artHeight[self.artPieceIndex])

	-- self.fireImage = display.newImageRect("images/art/art-piece-" .. self.artPieceIndex .. "-onfire.png", 
	-- 	artWidth[self.artPieceIndex], artHeight[self.artPieceIndex])

	self.body:insert(self.normalImage)
	-- self.body:insert(self.fireImage)

	function addFireSpriteSheet()

		local options = {width = 90, height = 139, sheetContentWidth=630, sheetContentHeight=139, numFrames = 7}
		local sheet = graphics.newImageSheet( "images/effects/Fire.png", options )
		local sequenceData = {
			{ name = "burn", 
			frames= { 1, 2, 3, 4, 5, 6, 7 },
			time=350, loopCount=0 },
		}

		self.fire = display.newSprite( sheet, sequenceData )
		self.fire.x = 0
		self.fire.y = 0
		self.fire:setSequence( "burn" )
		self.fire:play()
		self.body:insert(self.fire)

		self.smallFire = display.newSprite( sheet, sequenceData )
		self.smallFire.x = 0
		self.smallFire.y = 0		
		self.smallFire.xScale = -0.5
		self.smallFire.yScale = 0.5
		self.smallFire:setSequence( "burn" )
		self.smallFire:play()
		
		self.body:insert(self.smallFire)
	end 

	addFireSpriteSheet()
	self.fireShown = true

	if self.zoneState == zoneStateNormal then
		self.fire.isVisible = false
		self.smallFire.isVisible = false
 	else 
 		self.fire.isVisible = true
		self.smallFire.isVisible = true
		self.fire.x = math.random(30) - 15 
		self.fire.y = math.random(30) - 30
		self.smallFire.x = math.random(30) - 15
		self.smallFire.y = math.random(30)
 	end 

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end

function zone:update()

	if self.zoneState == zoneStateNormal then
		-- extinguish
		if self.fireShown == true then
			self.fireShown = false
			self.fire.isVisible = false
			self.smallFire.isVisible = false
		end 
	else 
		-- start fire
		if self.fireShown == false then
			self.fireShown = true
			self.fire.isVisible = true
			self.smallFire.isVisible = true
			self.fire.x = math.random(30) - 15 
			self.fire.y = math.random(30) - 30
			self.smallFire.x = math.random(30) - 15
			self.smallFire.y = math.random(30)

			self.fire.xScale = 0.1
			self.fire.yScale = 0.1
			transition.to(self.fire, {time=200, xScale=1, yScale=1})

			self.smallFire.xScale = -0.1
			self.smallFire.yScale = 0.1
			transition.to(self.smallFire, {time=200, xScale=-0.5, yScale=0.5})
		end 
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