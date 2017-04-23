local Platform = require "scripts.platform"
local Person = require "scripts.person"

board = inheritsFrom( nil )

function board:init(options)
	self.boardLayer = options.layer

	self.platformLayer = display.newGroup()
	self.boardLayer:insert(self.platformLayer)
	
	self.personLayer = display.newGroup()
	self.boardLayer:insert(self.personLayer)

	function createPersons()
		self.persons = {};

		self.redPlayer = Person:create({
			layer = self.personLayer,
			x = 50, y = 768 - 120,
			teamNumber = 1,
			collisionEntities = self.entities
		})
		table.insert(self.persons, self.redPlayer)

		self.bluePlayer = Person:create({
			layer = self.personLayer,
			x = 1024-50, y = 768 - 120,
			teamNumber = 2,
			collisionEntities = self.entities
		})
		table.insert(self.persons, self.bluePlayer)
	end 

	function createPlatforms()
		self.entities = {};

		function createPlatform(x, y, w, h)
			table.insert(self.entities, Platform:create({
				layer = self.platformLayer,
				x = x, y = y,
				width = w, height = h
			}))
		end 


		createPlatform(260, 768 - 441, 320, 15)
		createPlatform(1024 - 270, 768 - 441, 320, 15)
		
		createPlatform(1024/2, 768 - 331, 320, 15)
		
		createPlatform(260, 768-231, 320, 15)
		createPlatform(1024-270, 768-231, 320, 15)
		
		-- floor
		createPlatform(1024/2, 768-89, 1024, 30)
	end

	createPlatforms()
	createPersons()

	self.updateTimer = timer.performWithDelay(10, function() 
		self:update()
	end, 0)
end

function board:update()
	for i, person in ipairs(self.persons) do
		person:setMinY(self.entities)
	end
end 

return board