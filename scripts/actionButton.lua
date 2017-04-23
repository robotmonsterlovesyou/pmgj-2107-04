local widget = require( "widget" )

actionButton = inheritsFrom( nil )

function actionButton:init(options) 
    self.layer = options.layer
    self.teamNumber = options.teamNumber
    self.x = options.x
    self.y = options.y

    local buttonColors = {}
    buttonColors[teamTwo] = "fire"
    buttonColors[teamOne] = "water"
    
    -- Function to handle button events
    local function handleButtonEvent( event )
        local jumpPressedEvent = {
            name = "actionPressed",
            teamNumber = self.teamNumber,
            phase = event.phase
        }
        
        Runtime:dispatchEvent( jumpPressedEvent )
    end

	local button1 = nil

	if self.teamNumber == 1 then
    
		button1 = widget.newButton(
			{
				width = 71,
				height = 117,
				defaultFile = "images/buttons/fire-button.png",
				overFile = "images/buttons/fire-button-pressed.png",
				label = "button",
				onEvent = handleButtonEvent
			}
		)

	elseif self.teamNumber == 2 then
    
		button1 = widget.newButton(
			{
				width = 71,
				height = 117,
				defaultFile = "images/buttons/water-button.png",
				overFile = "images/buttons/water-button-pressed.png",
				label = "button",
				onEvent = handleButtonEvent
			}
		)

	end

    -- Center the button
    button1.x = self.x
    button1.y = self.y

    -- Change the button's label text
    button1:setLabel( "" )
	self.layer:insert(button1)
    
	return button1
end

return actionButton;
