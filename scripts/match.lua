local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local physics = require "physics"
local Board = require "scripts.board"
local ActionButton = require "scripts.actionButton"

physics.start()
physics.setGravity(0,0)
physics.pause()

board = {}

teamOne = 1
teamTwo = 2
teamThree = 3	
teamFour = 4

modeTitleScreen = 0
modeSetupScreen = 1
modeMatchScreen = 2

matchSetup = 1
matchRunning = 2
matchComplete = 3

function scene:createScene( event )
	
	print("=============================== BEGIN =================================")

	local disableAudio = true
	disableAudio = false -- DISABLES AUDIOS (COMMENT-OUT TO DISABLED AUDIO)

	if disableAudio then
		audio.setVolume(0)
	end

	local bgMusic = audio.loadSound("audio/mx_mainsong.mp3")
	audio.play(bgMusic)

-- if self.shakeValue > 0 then
-- self.body.x = self.baseX + math.random(self.shakeValue) - self.shakeValue/2
-- self.body.y = self.baseY + math.random(self.shakeValue) - self.shakeValue/2
-- self.shakeValue = self.shakeValue - 1
-- else
-- self.body.x = self.baseX

	function addLayer(group, layerName)
		local layer = display.newGroup()
		group:insert(layer)
		self[layerName] = layer
	end

	addLayer(self.view, "layerShake")

	addLayer(self.layerShake, "layerBackground")
	addLayer(self.layerShake, "layerTurnIndicators")
	addLayer(self.layerShake, "layerTiles")
	addLayer(self.layerShake, "layerBorder")
	addLayer(self.layerShake, "layerBoard")
	addLayer(self.layerShake, "layerStart")
	addLayer(self.layerShake, "layerButtons")
	addLayer(self.layerShake, "layerShipMenu")
	addLayer(self.layerShake, "layerVictory")

    ActionButton:create({
    	layer = self.layerButtons,
		teamNumber = teamOne, 
		x = 50,
		y = 768 - 75})

	ActionButton:create({
		layer = self.layerButtons,
		teamNumber = teamTwo, 
		x = 1024 - 50,
		y = 768 - 75})

	self.secondsRemaining = 120

	self.flashCurtain = display.newRect(self.layerStart, 1024/2, 768/2, 1024, 768 )
	self.flashCurtain:setFillColor( 0.68, 0.85, 0.90 )
	self.flashCurtain.alpha = 0

	self.progress = display.newImageRect("images/ui/progress-bar.png", 1024, 24)
	self.layerBackground:insert(self.progress)
	self.progress.y = 726
	self.progress.anchorX = 0
	self.progress.anchorY = 0

	self.backgroundNoFire = display.newImageRect("images/background-nofire.png", 1024, 768)
	self.layerBackground:insert(self.backgroundNoFire)
	self.backgroundNoFire.anchorX = 0
	self.backgroundNoFire.anchorY = 0

	self.backgroundMostFire = display.newImageRect("images/background-most_fire.png", 1024, 768)
	self.layerBackground:insert(self.backgroundMostFire)
	self.backgroundMostFire.anchorX = 0
	self.backgroundMostFire.anchorY = 0
	self.backgroundMostFire.alpha = 0.5

	local secondsRemainingTextLabelOptions = {}
	secondsRemainingTextLabelOptions.text = self.secondsRemaining
	secondsRemainingTextLabelOptions.x = 1024/2 - 30
	secondsRemainingTextLabelOptions.y = 678
	secondsRemainingTextLabelOptions.align = "center"
	secondsRemainingTextLabelOptions.fontSize = 30

	self.secondsRemainingTextLabel = display.newText(secondsRemainingTextLabelOptions)
	self.secondsRemainingTextLabel:setFillColor(0, 0, 0)
	self.layerBackground:insert(self.secondsRemainingTextLabel)
	self.secondsRemainingTextLabel.anchorX = 0
	self.secondsRemainingTextLabel.anchorY = 0

	function addListeners()

		------- P A U S E -- L I S T E N E R --
		self.paused = false
	    local pauseEventListener = function(event) 
	        if event.phase == "began" then
	            self.paused = true
	            physics.pause( )
	        elseif event.phase == "ended" then
	            self.paused = false
	            physics.start()
	        end
	    end
	    Runtime:addEventListener("pauseEvent", pauseEventListener) 

	    ------- R E M A T C H -- L I S T E N E R --
		self.rematchListener = function(event)
			if self.board then self.board:reset() end

			self.flashCurtain.alpha = 0
			transition.to(self.flashCurtain, {time=400, alpha=1, onComplete=function()
				timer.performWithDelay( 100, function()
					transition.to(self.flashCurtain, {time=500, alpha=0})
				end)
			end})
		end

		Runtime:addEventListener("rematch", self.rematchListener)

		------- R E M A T C H -- L I S T E N E R --
		self.victoryListener = function(event)
			self:showVictory(event.teamNumber)
		end

		Runtime:addEventListener("victory", self.victoryListener)
	end

	addListeners()
	
end


-- Called immediately after scene has moved onscreen:
-- (e.g. start timers, load audio, start listeners, etc.)
function scene:enterScene( event )
	self.starting = false

	physics.start();
	physics.setReportCollisionsInContentCoordinates(true)

	-- handles the start of a match
	self.readyToStartMatchListener = function(event) 
		if self.starting == false then
			self.starting = true

			self.leftStartBar:start()
			self.rightStartBar:start()

			timer.performWithDelay(1500, function()
				self.starting = false
				self.board:start()
			end, 1)
		end
	end

	Runtime:addEventListener("readyToStartMatch", self.readyToStartMatchListener)
	
	-- setup a fresh board (emits readyToStartMatch when ready)
	local options = {
		mode = modeTableTop,
		layer = self.layerBoard
	}
	self.board = Board:create(options)

	-- pull board's layers into the top level layer structure 
	-- self.layerPuckBoard:insert(self.board.layers)

	self.updateTimer = timer.performWithDelay(100, function() 
		self:update()
	end, 0)

	self.redVictory = display.newImageRect("images/victory/red-winner.png", 1024, 768)
	self.redVictory.anchorX = 0
	self.redVictory.anchorY = 0
	self.redVictory.alpha = 0
	self.redVictory:addEventListener( "touch", function(event)
		self:reset(event)
	end)

	self.blueVictory = display.newImageRect("images/victory/blue-winner.png", 1024, 768)
	self.blueVictory.anchorX = 0
	self.blueVictory.anchorY = 0
	self.blueVictory.alpha = 0
	self.blueVictory:addEventListener( "touch", function(event)
		self:reset(event)
	end)

	self.layerVictory:insert(self.redVictory)
	self.layerVictory:insert(self.blueVictory)
	self.victoryOn = false

	self.updateSecondsTimer = timer.performWithDelay(1000, function() 
		self.secondsRemaining = self.secondsRemaining - 1
	end, 0)
end

function scene:reset(event)
	print("reset")
	if event.phase == "began" then 
		self.victoryOn = false
		self.blueVictory.alpha = 0
		self.redVictory.alpha = 0
		self.secondsRemaining = 120
		timer.resume(self.updateSecondsTimer)
		self.board.zones[1].zoneState = 1
		self.board.zones[2].zoneState = 2
		self.board.zones[3].zoneState = 1
		self.board.zones[4].zoneState = 2
		self.board.zones[5].zoneState = 1
		self.board.zones[6].zoneState = 2
	end 
end 

function scene:showVictory(teamNumber)
	self.victoryOn = true
	print(teamNumber .. " won!")
	if teamNumber == 1 then
		transition.to(self.redVictory, {time=1000, alpha=1})
	else 
		transition.to(self.blueVictory, {time=1000, alpha=1})
	end 
end 

function scene:update()
	-- self.background:update()
	local progressWidth = 255
	local onFirePercent = 0
	local zonesCount = 0
	local zonesOnFire = 0
	for i, zone in ipairs(self.board.zones) do
		zonesCount = zonesCount + 1
		if zone.zoneState == 2 then
			zonesOnFire = zonesOnFire + 1
		end
	end
	onFirePercent = zonesOnFire / zonesCount * 100
	self.backgroundMostFire.alpha = onFirePercent / 100
	self.progress.x = ((progressWidth * 2) * (onFirePercent / 100)) - progressWidth
	self.secondsRemainingTextLabel.text = math.floor(self.secondsRemaining / 60) .. ":" .. (self.secondsRemaining- math.floor(self.secondsRemaining / 60) * 60)

	if self.victoryOn == false and self.secondsRemaining == 0 or (onFirePercent == 0 or onFirePercent == 100) then
		timer.pause(self.updateSecondsTimer)
		print("end game " .. onFirePercent)

		if onFirePercent >= 50 then
			self:showVictory(1)
		else
			self:showVictory(2)
		end
	end

end

-- Called when scene is about to move offscreen:
-- (e.g. stop timers, remove listenets, unload sounds, etc.)
function scene:exitScene( event )
	local group = self.view

	self.layerPuckBoard:remove(self.board.layers)
	self.board:destroy()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
end

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

return scene

