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
local gameMath = require( "classes.gameMath" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view
	local GameTitle, infotxt, attribution, versionText, versionNo, PlayButton, LevelSelectionButton, HelpButton, BackGround, loadedSettings, leveldetails, leveltoload
	local levelCount = composer.getVariable('levelCount') 

	local function onSystemEvent( event )
    print( "System event name and type: " .. event.name, event.type )
    	if (event.type == "applicationStart") then  		
			loadedSettings = loadsave.loadTable('settings.json')
			loadedLevelDetails = loadsave.loadTable('leveldetails.json')
			myApp.levelCount = levelCount
			if loadedSettings ~= nil then
				if not loadedSettings.initialLaunch then --app has been launched before					
					myApp.settings = loadedSettings
					myApp.leveldetails = loadedLevelDetails
					print('initial Launch is:', myApp.settings.initialLaunch, myApp.leveldetails)
					--check if existing no of levels is same as levelcount, if it's not, add the new level to leveldetails
					local no_of_existing_levels = #(myApp.leveldetails) ; print('no of existing levels:', no_of_existing_levels)
					if no_of_existing_levels < levelCount then
						print('new levels found')
						myApp.leveldetails[#myApp.leveldetails+1] = {id = #myApp.leveldetails+1, isCompleted = false, isAttempted = false}
					end 
				end
			else --no settings found, intialize settings
				print('no settings found')
				--stores initial launch app settings 
				myApp.settings = {}
				myApp.settings.initialLaunch = true					
				myApp.settings.tutorialEnabled = true 				
				myApp.leveldetails = {} --initialize a table under myApp that stores all the level details
				leveldetails = myApp.leveldetails
				--create subtables inside leveldetails for each level with levelid and starting default values
				for i = 1, levelCount do 
					leveldetails[i] = {id = i, isCompleted = false, isAttempted = false}
				end
				
			end
			
		elseif (event.type == "applicationExit") then
			--store myApp table in json
			if myApp.settings.initialLaunch then
				myApp.settings.initialLaunch = false --so now set it to false if exiting after first launch
				myApp.settings.tutorialEnabled = false --tutorial no longer needed but can be accessed from main menu
			end
			loadsave.saveTable(myApp.settings, 'settings.json')	
			loadsave.saveTable(myApp.leveldetails, 'leveldetails.json')			
		end
	end
	Runtime:addEventListener( "system", onSystemEvent )

	BackGround = display.newRect( halfW, halfH, screenW, screenH )
	BackGround.fill = colours.black.colour 
	sceneGroup:insert(BackGround)

	--Game title text
	GameTitle = display.newText( "", halfW, 0.2*screenH, myApp.fontBold, 60, "center")
	GameTitle.text = "Coluraze"
	GameTitle.fill = colours.pearl.colour 
	sceneGroup:insert(GameTitle)

	--info text
	infotxt = display.newText( "", halfW, 0.25*screenH, 500,0, myApp.font, 40, "center")
	infotxt.text = "Pre pre pre pre Alpha Demo\ntouch play to begin"
	infotxt.fill = colours.pearl.colour 
	sceneGroup:insert(infotxt)

	--attribution text
	attribution = display.newText( "Icons designed by melapics", 0.8*screenW, 0.9*screenH, myApp.fontBold, 25)
	attribution.fill = colours.pearl.colour 
	sceneGroup:insert(attribution)

	local versionsInfoTbl = versionInfoTbl 
	--get latest version number 	
	versionNo = versionsInfoTbl[#versionsInfoTbl]
	
	--version number 
	versionText = display.newText( "Version" .. tostring(versionNo), 0.08*screenW, 0.9*screenH, myApp.fontBold, 25)
	versionText.fill = colours.pearl.colour 
	sceneGroup:insert(versionText)

	-- Play button, goes to setup scene first to determine no of players and players' names.
	PlayButton = widget.newButton( { x = halfW, y = halfH-50, --width = screenW*0.1, height = screenW*0.1,
	defaultFile = "graphics/buttons/play2-default.png", id = "play-default",
	--overFile = "graphics/buttons/play-over.png", id = "play-over",
	onPress = function () composer.gotoScene("scenes.play", "crossFade", 400) end  } )
	sceneGroup:insert(PlayButton)

	--goes to level selection scene to allow selection of levels
	LevelSelectionButton = widget.newButton( { x = halfW, y = halfH+70, --width = screenW*0.1, height = screenW*0.1,
	defaultFile = "graphics/buttons/levels-default.png", id = "levels-default",
	--overFile = "graphics/buttons/play-over.png", id = "play-over",
	onPress = function () composer.gotoScene("scenes.levelselection", "crossFade", 400) end  } )
	sceneGroup:insert(LevelSelectionButton)

	-- Help button, when pressed, goes to rules scene which explains the rules
	--HelpButton = widget.newButton( { x = halfW+100, y = halfH, 
	--defaultFile = "graphics/buttons/help.png", id = "Help",
	--onPress = function () composer.gotoScene("scenes.rules", "crossFade", 400) end } )
	--sceneGroup:insert(HelpButton)

	print( "\n1: Home created")

end

function scene:show( event )
	
	local phase = event.phase
	local sceneGroup = self.view

	if "did" == phase then
	
		print( "1: home scene show event, phase did" )
	
		-- remove previous scene's view
		--composer.removeScene( "scenes.rules" )
		composer.removeScene( "scenes.play", true )
	end
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

---------------------------------------------------------------------------------

return scene