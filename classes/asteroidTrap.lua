local class = {}

local physics = require( "physics" )
require( "classes.randomlua")
local newRandNum = require( "classes.GenerateRandNum" ).generateRandNum
local gameMath = require( "classes.gameMath" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" )

local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.newAsteroidTrap( levelparams )
	local currentLevel = levelparams
	local asteroidTrapGroup = display.newGroup()
	local asteroidTrapTbl = {}
	--create variables that stores the no of traps 
	local no_of_traps = currentLevel.asteroidTrapDetails.no_of_traps

	--add to table the no_of_asteroids_per_trap and no of asteroids spawned per trap
	for i = 1, no_of_traps do 
		asteroidTrapTbl[#asteroidTrapTbl+1] = {no_of_asteroids_per_trap = currentLevel.asteroidTrapDetails.no_of_asteroids_per_trap, no_of_asteroids_spawned_per_trap = 0}
	end

	--load moving asteroid sprite
	local moving_asteroid_sheetoptions = currentLevel.asteroidTrapDetails.moving_asteroid_sheetoptions

	local moving_asteroid_sheet = graphics.newImageSheet( currentLevel.asteroidTrapDetails.filename, moving_asteroid_sheetoptions )

	local moving_asteroid_sequenceData = currentLevel.asteroidTrapDetails.moving_asteroid_sequenceData

	local function asteroidTrapCollisionListener( self, event )
		if ( event.phase == "began" ) then
			print( self.type .. self.id, ": collision began with " .. event.other.type .. event.other.id )
			if event.other.type == 'wall' then
				self:setLinearVelocity(0,0)
				transition.fadeOut( self, {time=800, onComplete=function()
					display.remove(self)
					self = nil 
				end})
			elseif event.other.type == 'asteroid trap trigger zone' then
        		--asteroid trap has sprung and has moved into the triggerzone, hence change it's velocity to chase the circle, 
        		--after a short delay, which lets it move towards the centre of the trigger zone
        		timer.performWithDelay(currentLevel.asteroidTrapDetails.timerForDirectionChange, 
        			function() self:setLinearVelocity(currentLevel.asteroidTrapDetails.velocities[self.trapid].x_velocitymin, 
        						currentLevel.asteroidTrapDetails.velocities[self.trapid].y_velocitymax) 
        						print('asteroid moving towards circle')
        			end
        			)
			end
		end
	end

	local function spawnAsteroid( )
		for i = 1, #asteroidTrapTbl do
			if asteroidTrapTbl[i].no_of_asteroids_spawned_per_trap < asteroidTrapTbl[i].no_of_asteroids_per_trap then	
				local moving_asteroid_trap = display.newSprite( moving_asteroid_sheet, moving_asteroid_sequenceData )
				moving_asteroid_trap.x, moving_asteroid_trap.y = currentLevel.asteroidTrapDetails.coordinates[i].x, currentLevel.asteroidTrapDetails.coordinates[i].y
				moving_asteroid_trap.id = asteroidTrapTbl[i].no_of_asteroids_spawned_per_trap + 1 ;print('asteroid trap id:', moving_asteroid_trap.id)
				moving_asteroid_trap.trapid = i --each asteroid has a trapid that is the same as the trap it belongs to. i.e. no of traps = 2, asteroid spawned for trap 1 has trapid = 1
				moving_asteroid_trap.type = 'asteroid trap'
				moving_asteroid_trap:scale(0.75,0.75)				
				print('asteroid width:'..moving_asteroid_trap.contentWidth..'height:'..moving_asteroid_trap.contentHeight)
				physics.addBody(moving_asteroid_trap, "dynamic", {density=1, bounce=0, friction=0.5, radius=(2/3)*moving_asteroid_trap.contentWidth/2})
				moving_asteroid_trap.collision = asteroidTrapCollisionListener
				moving_asteroid_trap:addEventListener("collision")
				asteroidTrapGroup:insert(moving_asteroid_trap)
				asteroidTrapTbl[i].moving_asteroid_trap = moving_asteroid_trap
				asteroidTrapTbl[i].no_of_asteroids_spawned_per_trap = asteroidTrapTbl[i].no_of_asteroids_spawned_per_trap  + 1
			end
		end
	end

	--spawn first set of asteroids, dependent on no of traps, i.e. 1 trap, 1 asteroid, 2 traps, 2 asteroids for respective trap
	spawnAsteroid()	

	local function springAsteroidTrap( asteroidToSpring, triggerZone )
		local asteroidTrap = asteroidToSpring
		local traptriggerZone = triggerZone
		--this vector represent the direction from the asteroid to the trigger zone, 
		--it used to calculate the velocity to move the asteroid to the trigger zone
		local VectorX, VectorY = traptriggerZone.x - asteroidTrap.x, traptriggerZone.y - asteroidTrap.y 
		asteroidTrap:play()
		asteroidTrap:setLinearVelocity(VectorX,VectorY)
		timer.performWithDelay(500, spawnAsteroid)	
	end

	local function trap_trigger_zone_collisionListener ( self, event )
		if ( event.phase == "began" ) then
        	print( self.type .. self.id, ": collision began with " ..event.other.type .. event.other.id )
        	if event.other.type == 'circle' then
        		for i = 1, #asteroidTrapTbl do 
        			local _asteroidTrap = asteroidTrapTbl[i].moving_asteroid_trap
        			--print('asteroid trapid and trigger zone id:', _asteroidTrap.trapid, self.id)
        			if _asteroidTrap.trapid == self.id then --triggerzone id matches the asteroid.trapid
	        			local asteroidToSpring = _asteroidTrap
	        			timer.performWithDelay( 500, springAsteroidTrap( asteroidToSpring, self ) )        							
        			end
        		end 
        	end
        end
	end	

	--create the trap trigger zones for each trap.
	for i = 1, #asteroidTrapTbl do
		local trap_trigger_zone = display.newRect( currentLevel.asteroidTrapDetails.triggerZone[i].x, currentLevel.asteroidTrapDetails.triggerZone[i].y, 
												   currentLevel.asteroidTrapDetails.triggerZone[i].width, currentLevel.asteroidTrapDetails.triggerZone[i].height)
		trap_trigger_zone.alpha = 0.25
		trap_trigger_zone.id = i
		trap_trigger_zone.type = 'asteroid trap trigger zone'		
		physics.addBody(trap_trigger_zone, "static", {density=0.1, bounce=0, friction=0})
		trap_trigger_zone.isSensor = true
		trap_trigger_zone.collision = trap_trigger_zone_collisionListener
		trap_trigger_zone:addEventListener("collision")
		asteroidTrapGroup:insert(trap_trigger_zone)
		asteroidTrapTbl[i].trap_trigger_zone = trap_trigger_zone
	end

	return asteroidTrapGroup
end

return class 