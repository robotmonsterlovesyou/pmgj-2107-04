local storyboard = require "storyboard"
display.setStatusBar( display.HiddenStatusBar )

system.activate( "multitouch" )

-- Create a new class that inherits from a base class
--
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create(options)
        local newinst = {}
        setmetatable( newinst, class_mt )
        newinst:init(options)
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

modeTitleScreen = 0
modeSetupScreen = 1
modeMatchScreen = 2

storyboard.gotoScene( "scripts.match" )
