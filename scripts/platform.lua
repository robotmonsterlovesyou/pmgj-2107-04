platform = inheritsFrom( nil )

platformTypeSingle = 1
platformTypeDouble = 2
platformTypeTriple = 3

function platform:init(options)
	local x = options.x
	local y = options.y
	local width = options.width
	local height = options.height
	local layer = options.layer

	self.layer = layer

	local platformType = platformTypeSingle --options.platformType

	self.floor = display.newRect(x, y, width, height)
	self.body = self.floor
	self.layer:insert(self.floor)

end

return platform