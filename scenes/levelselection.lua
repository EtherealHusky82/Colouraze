local sceneName = ...
-- required corona apis
local composer = require( "composer" )
local widget = require( "widget" )
local json = require ("json")

--load libs and classes
local screenSize = require( "libs.screenSize" )
local myApp = require( "libs.myapp" ) 
local colours = require( "libs.colours" )
local loadsave = require( "libs.loadsave" )
local versionInfoTbl = require( "libs.versionsInfo" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
local level_selection_buttonsGroup, level_id_textGroup = display.newGroup(), display.newGroup()
local spacing_between_buttons, border_size = 50, math.floor(screenW/10)
local button_size = ( screenW - (2*border_size) - (3*spacing_between_buttons) )/4

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
	print( "\n1: level selection scene created")
	local levelCount = composer.getVariable('levelCount') 
	local no_of_spaces_between_buttons, startPosX, startPosY, distance_between_buttons = 3, border_size+(0.5*button_size), border_size*3+(0.5*button_size), button_size+spacing_between_buttons  
	local buttonPosition, row_number, column_number = 0, 1, 0 --column number affects x positions and row number affects y positions

	--spawn the buttons that correspond to the no. of levels
	for i = 1, levelCount do
		
		if column_number > no_of_spaces_between_buttons then 
			--reset column number to 0 and increase row_number
			column_number = 0 
			row_number = row_number + 1 
		end  

		local options =
			{
			    effect = "crossFade",
			    time = 400,
			    params = {
			        levelId = i,	
			        fromScene = 'level selection'	        
			    }
			}

		--create one button for each level
		local LevelSelectionButton = widget.newButton( { x = 0, y = 0, width = button_size, height = button_size,
		defaultFile = "graphics/buttons/level-selector-default.png", id = "level-selector-default",
		overFile = "graphics/buttons/level-selector-over.png", id = "level-selector-over",
		onPress = function () composer.gotoScene("scenes.play", options) end } )
		LevelSelectionButton.x, LevelSelectionButton.y = startPosX+(distance_between_buttons*column_number), startPosY+(distance_between_buttons*row_number)
		column_number = column_number + 1 
		LevelSelectionButton.levelId = i 
		level_selection_buttonsGroup:insert(LevelSelectionButton)

		local levelId_text = display.newText(tostring(i), LevelSelectionButton.x, LevelSelectionButton.y, myApp.fontBold, 60)
		levelId_text.fill = colours.pearl.colour 
		level_id_textGroup:insert(levelId_text)
				
	end

	local sceneText = display.newText( "Select Level", halfW, 0.1*screenH, myApp.fontBold, 60)
	sceneText.fill = colours.pearl.colour

	sceneGroup:insert(sceneText)
	sceneGroup:insert(level_selection_buttonsGroup)
	sceneGroup:insert(level_id_textGroup)

	-- create home button
    local HomeButton = widget.newButton( { x = 0.9*screenW, y = screenH * 0.95, width = screenW*0.1, height = screenW*0.1,
    defaultFile = "graphics/buttons/home2-default.png", id = "home2-default",
    overFile = "graphics/buttons/home2-over.png", id = "home2-over",
    onPress = function() composer.gotoScene( "scenes.home", "crossFade", 400 ) end } )

    sceneGroup:insert(HomeButton)
end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "did" == phase then
	
		print( "1: level selection scene show event, phase did" )
	
		-- remove previous scene's view
		composer.removeScene( "scenes.home", true )
		composer.removeScene( "scenes.play", true )
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

---------------------------------------------------------------------------------

return scene