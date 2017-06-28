local class = {}
local physics = require( "physics" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

--this class creates a laser trap, which is a series of alternating laser beams firing at specific time intervals. The laserbeams use raycast to simulate physics collision
--with the shapes that interact with it
function class.newspike( levelparams )
	local currentLevel = levelparams
    local newspike, spikeid, newpivot, newswingingspiketrap, pivotJoint, spawnrapidspikeTimer 
    local spikeGroup = display.newGroup()
    local wall_width, wall_height = currentLevel.shapeDetails.wall_width, currentLevel.shapeDetails.wall_height
    local newspikewidth = wall_width/4
    local newspikehalfwidth = newspikewidth/2
    local spikevertices = {newspikehalfwidth,0, -newspikehalfwidth,newspikehalfwidth, -newspikehalfwidth,-newspikehalfwidth}

    if currentLevel.spikesDetails ~= nil then
    	local spikePos = currentLevel.spikesDetails.spikes_location
		local no_of_spikes = currentLevel.spikesDetails.no_of_spikes		
		for i = 1, no_of_spikes do
			spikeid = i			
    		newspike = display.newPolygon(0, 0, spikevertices)
    		newspike.fill = colours.red.colour 
    		newspike.x, newspike.y = spikePos[spikeid].x, spikePos[spikeid].y 
    		newspike.rotation = currentLevel.spikesDetails.spikes_direction[spikeid]
    		newspike.type = 'spike'
    		newspike.id = spikeid 
    		--newspike.actualX, newspike.actualY = newspike:localToContent(0,0)		
			--print( 'newspike actual coordinates on stage', newspike.actualX, newspike.actualY )
			--newspike.x, newspike.y = newspike.actualX, newspike.actualY
    		physics.addBody(newspike, 'static', {vertices=spikevertices, density=1.0, bounce=0, friction=0.3})
    		spikeGroup:insert(newspike)
    	end
    else
    	print('current level has no spikes')
    end

    if currentLevel.movingSpikedWallDetails ~= nil then
        local spikePos = currentLevel.movingSpikedWallDetails.spikes_location
        local no_of_spikes = currentLevel.movingSpikedWallDetails.no_of_spikes       
        for i = 1, no_of_spikes do
            spikeid = i         
            newspike = display.newPolygon(0, 0, spikevertices)
            newspike.fill = colours.red.colour 
            newspike.x, newspike.y = spikePos[spikeid].x, spikePos[spikeid].y 
            newspike.rotation = currentLevel.spikesDetails.spikes_direction[spikeid]
            newspike.type = 'spike'
            newspike.id = spikeid
            physics.addBody(newspike, 'static', {vertices=spikevertices, density=1.0, bounce=0, friction=0.3})
            spikeGroup:insert(newspike) 
        end
        local triggerZonePos = currentLevel.movingSpikedWallDetails.triggerZone
        local triggerZone = display.newRect(triggerZonePos.x, triggerZonePos.y, wall_height*2, wall_height)
        triggerZone.type = 'triggerZone'
        triggerZone.alpha = 0.4
        triggerZone.id = 1
        physics.addBody(triggerZone, 'static', {density=1.0, bounce=0, friction=0.1})
        triggerZone.isSensor = true 
        spikeGroup:insert(triggerZone)
        spikeGroup.anchorChildren = true
    else
        print('current level has no moving spikes')
    end
    
    if currentLevel.swingingSpikeTrapDetails ~= nil then
        local jointMotorSpeed = 35
        local leftspikeshape = {-newspikehalfwidth,0, newspikehalfwidth,-newspikehalfwidth, newspikehalfwidth,newspikehalfwidth}
        local tailspikeshape = {-newspikehalfwidth,-newspikehalfwidth, newspikehalfwidth,-newspikehalfwidth, 0,newspikehalfwidth}
        local rightspikeshape = {newspikehalfwidth,0, -newspikehalfwidth,newspikehalfwidth, -newspikehalfwidth,-newspikehalfwidth}
        local barShape = {-0.5*wall_height,-0.6*wall_width, 0.5*wall_height,-0.6*wall_width, 0.5*wall_height,0.6*wall_width, -0.5*wall_height,0.6*wall_width}
        local swingingSpikeTrapDetails = currentLevel.swingingSpikeTrapDetails
        --create the pivot point and swinging bar first, since the spikes' positions are relative to the bar.
        newpivot = display.newRect(swingingSpikeTrapDetails.pivot.x, swingingSpikeTrapDetails.pivot.y, swingingSpikeTrapDetails.pivot.width, swingingSpikeTrapDetails.pivot.height)
        newpivot.alpha = 0.1
        newpivot.type = 'pivot'
        newpivot.id = 1
        physics.addBody( newpivot, "static", { isSensor=true } )
        newswingingspiketrap = display.newImage('graphics/images/swingingspikeaxe_mod.png')
        newswingingspiketrap.x, newswingingspiketrap.y = swingingSpikeTrapDetails.swingingBar.x, swingingSpikeTrapDetails.swingingBar.y+newspikehalfwidth
        newswingingspiketrap.id, newswingingspiketrap.type = 1, 'swinging spike trap'
        newswingingspiketrap.canBeBlocked = false
        physics.addBody(newswingingspiketrap, "dynamic",
            {shape=barShape},
            {shape=leftspikeshape},
            {shape=leftspikeshape},
            {shape=tailspikeshape},
            {shape=rightspikeshape},
            {shape=rightspikeshape} 
        )

        -- Create joint
        pivotJoint = physics.newJoint( "pivot", newpivot, newswingingspiketrap, newpivot.x, newpivot.y )
        pivotJoint.isMotorEnabled = true
        pivotJoint.motorSpeed = -jointMotorSpeed
        pivotJoint.maxMotorTorque = 4000
        pivotJoint.isLimitEnabled = true
        pivotJoint:setRotationLimits( swingingSpikeTrapDetails.swingingBar.angleA, swingingSpikeTrapDetails.swingingBar.angleB )
        newswingingspiketrap.pivotJoint = pivotJoint

        local function pivotjointRotation( event )
            if pivotJoint and pivotJoint.jointSpeed == 0 and math.floor(pivotJoint.jointAngle) <= swingingSpikeTrapDetails.swingingBar.angleA then 
                print('spike trap reached negative limit, reversing rotation')
                pivotJoint.motorSpeed = jointMotorSpeed
            elseif pivotJoint and pivotJoint.jointSpeed == 0 and math.floor(pivotJoint.jointAngle) >= swingingSpikeTrapDetails.swingingBar.angleB then
                print('spike trap reached positive limit, reversing rotation')
                pivotJoint.motorSpeed = -jointMotorSpeed
            end
            --print('pivotjoint speed and angle:', pivotJoint.jointSpeed, math.floor(pivotJoint.jointAngle))
        end

        local function swingingSpikeTrapCollisionListener( self, event )
            local phase = event.phase
            local stage = display.getCurrentStage()

            if phase == "began" then
                print( self.type .. event.selfElement, ": collision began with " .. event.other.type .. event.other.id )
                
            elseif ( event.phase == "ended" ) then
                print(self.type, event.selfElement, 'has ended collision with' .. event.other.type .. event.other.id )
                local vx, vy = event.other:getLinearVelocity()
                print( "Linear X velocity = " .. vx )
                print( "Linear Y velocity = " .. vy )
                if event.selfElement ~= 1 and event.other.type == 'blocker' then --only if boulder collides with spikes
                    self.pivotJoint.motorSpeed = 0 
                    --stop boulder
                    timer.performWithDelay( 200, function() event.other:setLinearVelocity(0,0) end )
                end
            end

        end

        Runtime:addEventListener( "enterFrame", pivotjointRotation)
        newswingingspiketrap.collision = swingingSpikeTrapCollisionListener
        newswingingspiketrap:addEventListener("collision")

        spikeGroup:insert(newpivot)
        spikeGroup:insert(newswingingspiketrap)    
    end

    if currentLevel.rapidSpikeTrapDetails ~= nil then
        local rapidSpike, x_rapidSpikeVelocity, y_rapidSpikeVelocity
        local rapidSpikeTbl = {}
        local no_of_rapid_spikes = 0
        local function spawnrapidSpike( event )
            -- body
            no_of_rapid_spikes = no_of_rapid_spikes + 1
            rapidSpike = display.newPolygon(0, 0, spikevertices)
            rapidSpike.fill = colours.red.colour
            rapidSpike.x, rapidSpike.y = currentLevel.rapidSpikeTrapDetails.startPos.x, currentLevel.rapidSpikeTrapDetails.startPos.y
            rapidSpike.rotation = currentLevel.rapidSpikeTrapDetails.spike_direction
            rapidSpike.id = no_of_rapid_spikes
            rapidSpike.type = 'spike' 
            physics.addBody(rapidSpike, 'kinematic', {vertices=spikevertices, density=1.0, bounce=0, friction=0.3})
            rapidSpikeTbl[#rapidSpikeTbl+1] = rapidSpike
            if currentLevel.rapidSpikeTrapDetails.x_velocitymin ~= 0 then
                x_rapidSpikeVelocity = math.random(currentLevel.rapidSpikeTrapDetails.x_velocitymin, currentLevel.rapidSpikeTrapDetails.x_velocitymax)
            else
                x_rapidSpikeVelocity = 0
            end

            if currentLevel.rapidSpikeTrapDetails.y_velocitymin ~= 0 then
                y_rapidSpikeVelocity = math.random(currentLevel.rapidSpikeTrapDetails.y_velocitymin, currentLevel.rapidSpikeTrapDetails.y_velocitymax)
            else 
                y_rapidSpikeVelocity = 0
            end
                      
            if rapidSpike ~= nil then rapidSpike:setLinearVelocity( x_rapidSpikeVelocity, y_rapidSpikeVelocity ) ; spikeGroup:insert(rapidSpike) end
            
            if table.maxn(rapidSpikeTbl) ~= 0 then
                for i = 1, #rapidSpikeTbl do
                    if rapidSpikeTbl[i] ~= nil then
                        if rapidSpikeTbl[i].y > screenH then
                            display.remove(rapidSpikeTbl[i])
                            rapidSpikeTbl[i] = nil 
                        elseif rapidSpikeTbl[i].y < 0 then
                            display.remove(rapidSpikeTbl[i])
                            rapidSpikeTbl[i] = nil
                        elseif rapidSpikeTbl[i].x > screenW then
                            display.remove(rapidSpikeTbl[i])
                            rapidSpikeTbl[i] = nil
                        elseif rapidSpikeTbl[i].x < 0 then
                            display.remove(rapidSpikeTbl[i])
                            rapidSpikeTbl[i] = nil
                        end 
                    end
                end
            end
        end

        spawnrapidspikeTimer = timer.performWithDelay( currentLevel.rapidSpikeTrapDetails.intervaltimer, spawnrapidSpike, 0 )
    end

    --save the spikegroup to the levelparams table so it can be accessed elsewhere in the game
    currentLevel.spikeGroup = spikeGroup
    if spawnrapidspikeTimer ~= nil then
        if currentLevel.Timers == nil then --check for existing timers tbl
            currentLevel.Timers = {}
        end
        currentLevel.Timers[#currentLevel.Timers+1] = spawnrapidspikeTimer    
    end 

    return spikeGroup
end
return class 