local sceneName = ...
-- required corona apis
local composer = require( "composer" )
local widget = require( "widget" )
--load libs 
local screenSize = require( "libs.screenSize" )
local myApp = require( "libs.myapp" ) 
local colours = require( "libs.colours" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )
--this scene is an overlay, it is called when the isGameOver state returned by play.lua is true, it gives the player the option of going back to the home page or restarting/reloading the level

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

	print( "1: reload level scene create event" )

end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view
	--get currLevel from event.params
	local currLevel = event.params.scene_name

	if phase == 'will' then
        -- Preload the scene
        composer.loadScene(currLevel) 
	elseif "did" == phase then	
		print( "2: reload level event, phase did" )							
		timer.performWithDelay( 500, function() composer.gotoScene( currLevel, "crossFade", 400 ) end )		
	end
end

function scene:hide( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "will" == phase then	
		print( "3: reload level scene hide event, phase will" )	
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene