local class = {}
local physics = require( "physics" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local gameMath = require( "classes.gameMath" )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.newBoomerangTrap( levelparams )
	local currentLevel = levelparams
	local constantForce = currentLevel.boomerangTrapDetails.constantForce
	local boomerangGroup = display.newGroup()
	--spawn flying boomerang trap
	local boomerangFile = currentLevel.boomerangTrapDetails.filename
	local boomerangOutline = graphics.newOutline( 2, boomerangFile )

	local function boomerangCollisionListener( self, event )
		if ( event.phase == "began" ) then
        	print( self.type .. self.id, ": collision began with " .. event.other.type .. event.other.id )
        	if event.other.type == 'circle' then 
        		transition.fadeOut(event.other, {time=800, onComplete=function()					
 					timer.performWithDelay(1, physics.removeBody(event.other))
 					event.other.isSaved = false
 					event.other.isActive = false
 				end	} )	
 			end 
 		elseif ( event.phase == "ended" ) then

 		end
	end

	for i = 1, currentLevel.boomerangTrapDetails.no_of_boomerangs do
		local boomerang = display.newImageRect( boomerangFile, 90, 160 )
		boomerang.id = i 
		boomerang.type = "boomerang trap"
		boomerang.x = currentLevel.boomerangTrapDetails.coordinates[i].x
		boomerang.y = currentLevel.boomerangTrapDetails.coordinates[i].y 
		boomerang.initialPosX, boomerang.initialPosY = boomerang.x, boomerang.y 
		boomerangGroup:insert(boomerang)
		physics.addBody(boomerang, "dynamic", {density=0.3, bounce=1, friction=0.2, outline=boomerangOutline})
		boomerang.linearDamping = 0.2
		boomerang.angularDamping = 0.4
		--boomerang.collision = boomerangCollisionListener
		--boomerang:addEventListener("collision")
		--apply an initial force
		boomerang:applyForce(currentLevel.boomerangTrapDetails.initialXForce,currentLevel.boomerangTrapDetails.initialYForce, boomerang.x-10, boomerang.y+10)
	end

	local function applyForceOnBoomerang()
		for i = 1, boomerangGroup.numChildren do 
			local boomerangChild = boomerangGroup[i]
			math.randomseed( os.time() )
			local xForce = math.random(-constantForce, constantForce)
			local yForce = math.random(-constantForce, constantForce)
			boomerangChild:applyForce(xForce, yForce, boomerangChild.x-10, boomerangChild.y+10)
			print('random force applied on boomerang:', xForce, yForce)

			--calculate distance between boomerang and maze's exit point, if its falls within a range, i.e. gets too close, 
			--apply a force that returns boomerang to it's initial spawn position
			for j = 1, currentLevel.no_ofshapes.exit_sensor do
				local exitPoint = currentLevel.shapeDetails.exit_coordinates[j]
				local distanceBetweenBoomerang_andExit = gameMath.find_distance(boomerangChild, exitPoint)
				if distanceBetweenBoomerang_andExit < 40 then
					print('boomerang near exit, reversing direction')
					local dx = exitPoint.x - boomerangChild.initialPosX
					local dy = exitPoint.y - boomerangChild.initialPosY
					boomerangChild:applyForce(-dx, -dy, boomerangChild.x-10, boomerangChild.y+10)
				end
			end
		end
	end

	local boomerangconstantForceTimer = timer.performWithDelay( 1000, applyForceOnBoomerang, 0 )

	return boomerangGroup, boomerangconstantForceTimer
end

return class 