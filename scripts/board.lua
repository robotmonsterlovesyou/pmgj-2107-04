local Platform = require "scripts.platform"
local Person = require "scripts.person"

board = inheritsFrom( nil )

function board:init(options)
	self.entities = {};
	self.boardLayer = options.layer

	self.platformLayer = display.newGroup()
	self.boardLayer:insert(self.platformLayer)
	
	self.personLayer = display.newGroup()
	self.boardLayer:insert(self.personLayer)

	Person:create({
		layer = self.personLayer,
		x = 50, y = 768 - 150,
		teamNumber = 1
	})

 	-- left platform
	Platform:create({
		layer = self.platformLayer,
		x = 270, y = 768 - 200,
		width = 300, height = 15
	})

	-- right platform 
	Platform:create({
		layer = self.platformLayer,
		x = 1024-270, y = 768 - 200,
		width = 300, height = 15
	})

 	-- left platform
	Platform:create({
		layer = self.platformLayer,
		x = 270, y = 768 - 400,
		width = 300, height = 15
	})

	-- right platform 
	Platform:create({
		layer = self.platformLayer,
		x = 1024-270, y = 768 - 400,
		width = 300, height = 15
	})

	-- center platform
	Platform:create({
		layer = self.platformLayer,
		x = 1024/2, y = 768 - 300,
		width = 300, height = 15
	})
 	
	-- floor
	Platform:create({
		layer = self.platformLayer,
		x = 1024/2, y = 768-90,
		width = 1024, height = 30
	})
end

return board