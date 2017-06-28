local class = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local gamemath = require( "classes.gameMath" )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

--this class creates a laser trap, which is a series of alternating laser beams firing at specific time intervals. The laserbeams use raycast to simulate physics collision
--with the shapes that interact with it
function class.newlaserTrap( levelparams, laserid )
    local currentlevel = levelparams
    local distanceBetweenWalls = currentlevel.laserTrapDetails.distanceBetweenWalls
    local wallId = currentlevel.laserTrapDetails.wallId
    local laserTrapPos = currentlevel.laserTrapDetails.lasers_location
    local laserGun, childWallGroup, childWallA, childWallB
    local beamGroup, laserGunGroup = display.newGroup(), display.newGroup()
    local maxBeams, firingTimeInterval = 10, 1000
     
    laserGun = display.newRect(0,0,10,10)
    laserGun.isVisible = false 
    laserGun.x = laserTrapPos[laserid].x 
    laserGun.y = laserTrapPos[laserid].y
    laserGun.rotation = currentlevel.laserTrapDetails.lasers_direction[laserid]
    --laserGunGroup:insert(laserGun)   

    local function clearObject( object )
        display.remove( object )
        object = nil
    end

    local function resetBeams()
    	-- Clear all beams/bursts from display
    	for i = beamGroup.numChildren,1,-1 do
        	local child = beamGroup[i]
        	display.remove( child )
        	child = nil
    	end
     
    	-- Reset beam alpha
   	 	beamGroup.alpha = 1   
    end

    local function drawBeam( startX, startY, endX, endY )
    	-- unpack colour
    	local RedVal, GreenVal, BlueVal = unpack(colours.red.colour)
    	-- Draw a series of overlapping lines to represent the beam
    	local beam1 = display.newLine( beamGroup, startX, startY, endX, endY )
    	beam1.strokeWidth = 5 ;  beam1:setStrokeColor( RedVal, GreenVal, BlueVal, 1 ) ; beam1.blendMode = "add" ; beam1:toBack()
    	local beam2 = display.newLine( beamGroup, startX, startY, endX, endY )
    	beam2.strokeWidth = 10 ; beam2:setStrokeColor( RedVal, GreenVal, BlueVal, 0.706 ) ; beam2.blendMode = "add" ; beam2:toBack()
    	local beam3 = display.newLine( beamGroup, startX, startY, endX, endY )
    	beam3.strokeWidth = 15 ; beam3:setStrokeColor( RedVal, GreenVal, BlueVal, 0.392 ) ; beam3.blendMode = "add" ; beam3:toBack()     
    end


    function laserGun:rayCast( startX, startY, endX, endY )
    local hits, hitObject, hitX, hitY, FirstObjectHitByBeam, distanceBetweenCircleAndWall
 
        -- Perform ray cast
        hits = physics.rayCast( startX, startY, endX, endY, "sorted" )
        print('coordinates of rayCast:', startX, startY, endX, endY)
        -- There is a hit; calculate the entire ray sequence to the first hit (initial ray and reflections)
        if ( hits and beamGroup.numChildren <= maxBeams ) then
            print( "number of hits" , #hits )        
                   
            for i = 1, #hits do
                print('beam hit object:', hits[i].object.type)
            end

            hitObject = hits[1]
            FirstObjectHitByBeam = hitObject.object
            print( "object type: ", FirstObjectHitByBeam.type)
           
            -- Play laser sound
            --audio.play( sndLaserHandle )

            -- Store the hit X and Y position of the first bubble hit by raycast to local variables
            hitX, hitY = hitObject.position.x, hitObject.position.y
            print( "Hit position: ", hitX, hitY )
               
            -- Draw the first beam
            drawBeam( startX, startY, hitX, hitY ) 

            if FirstObjectHitByBeam.type == 'circle' then
                --distanceBetweenCircleAndWall = gamemath.find_distance(self, FirstObjectHitByBeam)
                --if distanceBetweenCircleAndWall <= distanceBetweenWalls then
                --circle is between the walls of the corridor
                    transition.fadeOut(FirstObjectHitByBeam, {time=800, onComplete=function(FirstObjectHitByBeam)                   
                    timer.performWithDelay(1, physics.removeBody(FirstObjectHitByBeam))
                    self.isSaved = false
                    end } )         
                --end 
            end 

            -- Fade out entire beam group after a short delay
            transition.to( beamGroup, { time=800, delay=200, alpha=0, onComplete=resetBeams } )    
             
        -- Else, ray casting sequence is complete
        else
            print('no hits from raycast')
            -- Draw only the first beam if there no hits
            drawBeam( startX, startY, endX, endY )

            -- Fade out entire beam group after a short delay
            transition.to( beamGroup, { time=400, delay=200, alpha=0, onComplete=resetBeams } )
        end
    
    end --end of function   

    function laserGun:firelaser()
        local xDest, yDest 
         -- Calculate ending x/y of beam
        xDest = self.x - (math.cos(math.rad(self.rotation+90)) * 2000 )
        yDest = self.y - (math.sin(math.rad(self.rotation+90)) * 2000 )
        print('xDest and yDest of fired beam', xDest, yDest)
        laserGun:rayCast(laserGun.x, laserGun.y, xDest, yDest)       
    end

    --fire first beam
    timer.performWithDelay( firingTimeInterval, laserGun:firelaser() )
   
    return laserGun
end 
return class 