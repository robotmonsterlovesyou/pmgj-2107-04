local widget = require( "widget" )

actionButton = inheritsFrom( nil )

function actionButton:init(options) 
    self.layer = options.layer
    self.teamNumber = options.teamNumber
    self.x = options.x
    self.y = options.y

    local buttonColors = {}
    buttonColors[teamTwo] = "blue"
    buttonColors[teamOne] = "red"
    
    local buttonIcons = {}
    buttonIcons[teamOne] = "q_button_jump_ccw"
    buttonIcons[teamTwo] = "q_button_jump_cw"
    
    local buttonRotation = {}
    buttonRotation[teamOne] = -90
    buttonRotation[teamTwo] = -180
    
    -- Function to handle button events
    local function handleButtonEvent( event )
        local jumpPressedEvent = {
            name = "actionPressed",
            teamNumber = self.teamNumber,
            phase = event.phase
        }
        
        Runtime:dispatchEvent( jumpPressedEvent )
    end
    
    print(buttonColors[self.teamNumber])
    local button1 = widget.newButton(
        {
            width = 150,
            height = 150,
            defaultFile = "images/buttons/q_button_" .. buttonColors[self.teamNumber] .. "150x150.png",
            overFile = "images/buttons/q_button_pressed150x150.png",
            label = "button",
            onEvent = handleButtonEvent
        }
    )

    -- Center the button
    button1.x = self.x
    button1.y = self.y
    button1.rotation = buttonRotation[self.teamNumber]
    button1.alpha=0.01

    -- Change the button's label text
    button1:setLabel( "" )
	self.layer:insert(button1)
    
	return button1
end

return actionButton;
