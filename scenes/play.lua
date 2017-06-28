local sceneName = ...
-- required corona apis
local composer = require( "composer" )
local widget = require( "widget" )
local json = require ("json")
local physics = require( "physics" )

--load libs and classes
local screenSize = require( "libs.screenSize" )
local myApp = require( "libs.myapp" ) 
local colours = require( "libs.colours" )

local gameMath = require( "classes.gameMath" )
local deepCopy = require( "classes.deepCopyTbl").deepCopy
local loadlevelText = require( "classes.loadText" ).loadText
local loadLevel = require( "classes.generateLevel" ).generateLevel
local generateLaserTrap = require( "classes.laserTrap" ).newlaserTrap
local generateBoomerangTrap = require( "classes.boomerangTrap" ).newBoomerangTrap
local generateAsteroidTrap = require( "classes.asteroidTrap" ).newAsteroidTrap
local generatePrismPuzzle = require( "classes.prismPuzzle" ).newPrismPuzzle
local generateTriangularPuzzle = require( "classes.triangularPuzzle" ).newTriangularPuzzle
local generateSpike = require( "classes.newSpikes" ).newspike
local checkLevelCompletion = require( "classes.endGameState" ).endGameState
local checkGameOverState = require( "classes.gameOverState" ).checkGameOverState

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local level, levelParams, HomeButton
local levelFound = false --flag that switches to true when a level with no attempts is found
physics.start()
physics.setGravity( 0, 0 )

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
	local guideTextTbl
	--physics.setDrawMode( "hybrid" )
	print( "1: play scene create event" )	
		
	self.leveldetails = myApp.leveldetails
	--check leveldetails for first unattempted level
	for i = 1, #(self.leveldetails) do --#(self.leveldetails) = no of levels
		level = self.leveldetails[i]
		if not level.isAttempted then
			levelFound = true 
			self.levelId = level.id 
		else
			print('level'..level.id, 'has been attempted')
			if level.id == #(self.leveldetails) then --last level completed
				--go back to level 1 for now
				self.levelId = 1 				 
			end 
		end
		if levelFound then break end
	end	

	--if previous scene was the levelselection scene, levelId needs to be changed to get the parameter returned by the levelselection buttons
	if event.params ~= nil then 
		if event.params.fromScene == 'level selection' then
			self.levelId = event.params.levelId
		else
			print('level selector was not used')
		end
	end

	--uncomment this to assign manually level to load, for testing of new levels or changes made to existing levels
	--self.levelId = 1 
	print( "level id", self.levelId)	
	
	levelParams = require( "levels.demo." .. self.levelId)
	--loadlevel:create the walls, circles, portals, traps and exits
	self.spikeGroup = generateSpike(levelParams)
	self.masterShapeGroup, self.portalGroup, self.wallGroup, self.textGroup, self.tileGroup = loadLevel(self, levelParams) 

	sceneGroup:insert(self.tileGroup)
	sceneGroup:insert(self.masterShapeGroup)
	sceneGroup:insert(self.portalGroup)
	sceneGroup:insert(self.wallGroup)
	sceneGroup:insert(self.textGroup)
	sceneGroup:insert(self.spikeGroup)

	--check if level contains guidetext, if yes, load them
	if levelParams.isthereGuideText then
		guideTextTbl = levelParams.guideText
		self.guideTextGroup = loadlevelText(guideTextTbl)
		sceneGroup:insert(self.guideTextGroup)
	end

	local laserGunTbl = {}
	--create laser traps separately, if any
	if levelParams.laserTrapDetails ~= nil then	
		local firingTimeInterval = levelParams.laserTrapDetails.intervaltimer or 2000 
		local no_of_lasers = levelParams.laserTrapDetails.no_of_lasers_per_trap
		for i = 1, no_of_lasers do
			local laserGun = generateLaserTrap(levelParams, i)
			laserGun.firingTimeInterval = firingTimeInterval
			laserGunTbl[#laserGunTbl+1] = laserGun			
			sceneGroup:insert(laserGun)
			firingTimeInterval = firingTimeInterval + 1000
		end

		local function laserTrapLoop( )
			for i = 1, #laserGunTbl do
				laserGunTbl[i]:firelaser()			
			end
		end 
	
		self.laserfiringTimer = timer.performWithDelay( firingTimeInterval, laserTrapLoop, 0)
	else
		print('current level has no laser traps')
	end

	--create boomerang traps separately, if any
	if levelParams.boomerangTrapDetails ~= nil then	
		self.boomerangGroup, self.boomerangConstantForceTimer = generateBoomerangTrap(levelParams)
		sceneGroup:insert(self.boomerangGroup)
	else
		print('current level has no boomerang traps')
	end

	--create asteroid traps separately, if any
	if levelParams.asteroidTrapDetails ~= nil then
		self.asteroidTrapGroup = generateAsteroidTrap(levelParams)
		sceneGroup:insert(self.asteroidTrapGroup)
	else
		print('current level has no asteroid traps')
	end

	--create prism laser puzzle separately, if any
	if levelParams.prismPuzzleDetails ~= nil then
		self.prismPuzzleGroup = generatePrismPuzzle(levelParams)
		sceneGroup:insert(self.prismPuzzleGroup)
	else
		print('current level has no prism puzzles')
	end

	--create puzzleTriangle separately, if any
	if levelParams.puzzleDetails ~= nil then
		self.triangularPuzzleGroup = generateTriangularPuzzle(levelParams)
		sceneGroup:insert(self.triangularPuzzleGroup)
	end
	--create electrified walls separately, if any

	

	--create asteroid field separately, if any


	-- create home button
    self.HomeButton = widget.newButton( { x = 0.95*screenW, y = screenH * 0.95, width = screenW*0.1, height = screenW*0.1,
    defaultFile = "graphics/buttons/home2-default.png", id = "home2-default",
    overFile = "graphics/buttons/home2-over.png", id = "home2-over",
    onPress = function() composer.gotoScene( "scenes.home", "crossFade", 400 ) end } )

    sceneGroup:insert(self.HomeButton)

    -- create reload current level button
	self.ReloadLevelButton = widget.newButton( { x = 0.85*screenW, y = screenH * 0.95, width = screenW*0.1, height = screenW*0.1,
    defaultFile = "graphics/buttons/reload-default.png", id = "reload-default",
    overFile = "graphics/buttons/reload-over.png", id = "reload-over",
    onPress = function() local currScene = composer.getSceneName( "current" ); local customParams = {scene_name=currScene}
    composer.gotoScene( "scenes.reloadlevel", {"crossFade", 400, params=customParams} ) end } )

    sceneGroup:insert(self.ReloadLevelButton)
end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "did" == phase then
	
		print( "2: play scene show event, phase did" )		
		
		-- remove previous scenes' view
		composer.removeScene( "scenes.home", true )		
		composer.removeScene( "scenes.levelselection", true )
		composer.removeScene( "scenes.reloadlevel", true )
		composer.removeScene( "scenes.nextlevel", true )

		local function MonitorGameState( event )			 
			-- This function checks if level completed every certain interval		
			self.isLevelCompleted = checkLevelCompletion(levelParams, self.masterShapeGroup, self.levelId)			
			print( 'is level completed?', tostring(self.isLevelCompleted) )	
			--self.isGameOver = checkGameOverState(self.wallGroup, self.masterShapeGroup, levelParams)
			if self.isGameOver then
				print('Game Over, show game over and reload prompt as an overlay')
				local options =
				{
    				isModal = true,
    				effect = "crossfade",
    				time = 400,
    				params = {
        				currentlevelid = self.levelId,
        				currScene = composer.getSceneName( "current" )
    				}
				}
				--composer.gotoScene("scenes.reloadlevel", "crossFade", 400)
			end		
		end	

		self.endGameStateCheckTimer = timer.performWithDelay( 1600, MonitorGameState, 0 )	

	end
end

function scene:hide( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "will" == phase then
		--do cleanups; remove all timers
		timer.cancel( self.endGameStateCheckTimer )

		if levelParams.Timers ~= nil then
			for i = 1, #levelParams.Timers do
				timer.cancel( levelParams.Timers[i] ) ; print('timer', i, 'cancelled')
			end
		end

		if self.boomerangConstantForceTimer ~= nil then
			timer.cancel( self.boomerangConstantForceTimer )
		end

		if self.laserfiringTimer ~= nil then
			timer.cancel( self.laserfiringTimer )
		end 	

		--self.level, self.levelParams, self.HomeButton, self.masterShapeGroup, self.guideTextGroup = nil, nil, nil, nil, nil  
		--self.portalGroup, self.textGroup, self.wallGroup, self.spikeGroup, self.laserfiringTimer, self.endGameStateCheckTimer = nil, nil, nil, nil, nil, nil   
		print( "2: play scene hide event, phase will" )

	elseif phase == 'did' then
			
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene
