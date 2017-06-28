local sceneName = ...
-- required corona apis
local composer = require( "composer" )
-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )
--this scene acts as an intermediary between endgamestate and play. i.e. when a level is completed, this scene is called by endgamestate, this scene then cleans up the play.lua
--and calls the play.lua again.

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
	
	print( "1: load next level scene create event" )		

end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view
	if phase == 'will' then
        -- Preload the scene
        composer.loadScene("scenes.play") 
	elseif "did" == phase then	
		print( "2: load next level event, phase did" )							
		timer.performWithDelay( 500, function() composer.gotoScene( "scenes.play", "crossFade", 400 ) end )		
	end
end

function scene:hide( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "will" == phase then	
		print( "3: load next level scene hide event, phase will" )	
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene