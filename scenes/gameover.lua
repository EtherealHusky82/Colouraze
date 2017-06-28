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
	local maskRect, gameOverText
	print( "1: game over scene create event" )
	--get currLevel from event.params
	--local currLevel = event.params.currScene

	--create a mask over the level scene 	
	maskRect = display.newRect( halfW, halfH, screenW, screenH )
	maskRect.fill = colours.black.colour 
	maskRect.alpha = 0.7
	sceneGroup:insert(maskRect)

    --show game over text and text telling user the options
    gameOverText = display.newText( 'No paths can be made with existing circles, please tap on the button below to restart the level', halfW, screenH*0.4, 0.8*screenW, 0, myApp.font, 30 )
    gameOverText.fill = colours.pearl.colour 
    sceneGroup:insert(gameOverText)

    --create reload button
    self.ReloadButton = widget.newButton( { x = halfW, y = halfH+100, width = screenW*0.15, height = screenW*0.15,
    defaultFile = "graphics/buttons/reload-default.png", id = "reload-default",
    overFile = "graphics/buttons/reload-over.png", id = "reload-over",
    onPress = function() composer.gotoScene("scenes.play", "crossFade", 400) end } )
    sceneGroup:insert(self.ReloadButton)

end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view
	if phase == 'will' then
        -- Preload the scene
        --composer.loadScene("scenes.play") 
	elseif "did" == phase then	
		print( "2: game over scene show event, phase did" )							
		--timer.performWithDelay( 500, function() composer.gotoScene( "scenes.play", "crossFade", 400 ) end )		
	end
end

function scene:hide( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "will" == phase then	
		print( "3: game over scene hide event, phase will" )	
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene