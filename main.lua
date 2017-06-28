---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
-- require composer module
local composer = require ( "composer" )
--local hockeyApp = require( "plugin.hockey" )
local myApp = require( "libs.myapp" ) 
local screenSize = require( "libs.screenSize" )
local loadsave = require( "libs.loadsave" )

--hockeyApp.init( "3d3823e3300041da9210a301f74ea68f")
--hockeyApp.checkForUpdate()

--forward declarations and other locals, storing them in a faux global table screenSize
screenSize.screenW = display.actualContentWidth
screenSize.screenH = display.actualContentHeight
screenSize.halfW = display.actualContentWidth*0.5
screenSize.halfH = display.actualContentHeight*0.5
print('actualContentWidth and Height:', screenSize.screenW, screenSize.screenH)

local screenW, screenH = screenSize.screenW, screenSize.screenH 

-- load fonts into faux global table: myApp
myApp.font = "fonts/Roboto-Light.ttf"
myApp.fontBold = "fonts/Roboto-Regular.ttf"
myApp.fontItalic = "fonts/Roboto-LightItalic.ttf"
myApp.fontBoldItalic = "fonts/Roboto-Italic.ttf"
-- load level key parameters
myApp.wall_width = math.floor(0.8*screenW/3.5)
myApp.wall_height =  math.floor(0.8*screenH/50)

math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,10)) )

local composer = require('composer')
composer.recycleOnSceneChange = true -- Automatically remove scenes from memory
composer.setVariable('levelCount', 12) -- Set how many levels there are under levels/ directory

-- load home menu scene
composer.gotoScene( "scenes.home" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)

