local class = {}
local composer = require( "composer" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" ) 
local colourTrans = require( "classes.colourTransition" ).TransitionColour

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

--this class checks if the level's objectives has been met, saves the level completed to myapp table which will be wriiten to a json file. 
--It also loads the next level if current one is completed, and before that, does a simple screen BG colour transition to the colours of the saved shapes.
function class.endGameState( levelparams, _shapeGroup, _levelId )
	local currentlevel = levelparams	     
      local shapeGroup, levelId = _shapeGroup, _levelId
      local wallGroupTbl = currentlevel.wallGroupsTbl
      local no_of_shapes_to_save = currentlevel.no_ofshapes.circles
      local no_of_shapes_saved, no_of_shapes_in_alpha, backgroundsTbl = 0, 0, {}
      local childShape, childBackground, currentBackground, transitionParams
      local leveldetails = myApp.leveldetails --table to update for the level attempted and completion statuses

        --save backgrounds first into a table
      for i = 1, shapeGroup.numChildren do
            childBackground = shapeGroup[i]
            if childBackground.type == 'background' then
                  backgroundsTbl[#backgroundsTbl+1] = childBackground
            end
      end

      if shapeGroup.numChildren ~= nil then
            for i = 1, shapeGroup.numChildren do
                  childShape = shapeGroup[i]
                  if childShape.type == 'circle' then
                        --check alpha value
                        if childShape.alpha == 0 then                           
                              no_of_shapes_in_alpha = no_of_shapes_in_alpha + 1 ; print('no_of_shapes_in_alpha', no_of_shapes_in_alpha)                             
                              if childShape.isSaved then
                                    no_of_shapes_saved = no_of_shapes_saved + 1 ; print('no_of_shapes_saved', no_of_shapes_saved)
                                    currentBackground = backgroundsTbl[no_of_shapes_saved] 
                                    local circleRedval, circleGreenval, circleBlueval = unpack(childShape.colour)
                                    currentBackground:setFillColor(circleRedval, circleGreenval, circleBlueval)
                                    --transitionParams = { startColour = currentBackground.colour, endColour = childShape.colour, time = 500, transition = easing.inQuad }
                                    --colourTrans(currentBackground, transitionParams)
                                    currentBackground.colour = childShape.colour 
                              end                        
                        end                
                  end
            end
      end

      if no_of_shapes_in_alpha == no_of_shapes_to_save then
            --all shapes are either saved or unsaved
            
            for i = 1, #(leveldetails) do 
                  local level = leveldetails[i]
                  if level.id == levelId then
                        print('level', levelId, 'attempted!')
                        level.isAttempted = true                  
                        if no_of_shapes_saved == no_of_shapes_to_save then
                              level.isCompleted = true 
                              print('congrats! You completed level', levelId)
                        end
                  end 
            end
            --cleanup all walls colour transition listeners
            --for i = 1, #wallGroupTbl do
             --     local childWallGroup = wallGroupTbl[i]
            --      for j = 1, childWallGroup.numChildren do
            --            local childWall = childWallGroup[j]
            --            local listenerRemoved = Runtime:removeEventListener("enterFrame", childWall.runFunc) 
            --            childWall.runFunc = nil 
            --            print('check childWall runFunc:',childWall.runFunc, listenerRemoved)
             --     end
            --end
            --Runtime:removeEventListener( "enterFrame", currentlevel.runTransFunc ) 
            --currentlevel.runTransFunc = nil ; print('runtransfunc status:', currentlevel.runTransFunc)
            --go to nextlevel scene, with a delay, that allows all the colour transitions in play.lua to complete.
            --cancel all timers before going to next level
            if currentlevel.Timers ~= nil then
                  for i = 1, #currentlevel.Timers do
                        timer.cancel(currentlevel.Timers[i])
                  end       
            end
            composer.gotoScene( "scenes.nextlevel", "crossFade", 800 ) 
      else
            print('level not completed')
      end
      
      return levelCompleted
end

return class