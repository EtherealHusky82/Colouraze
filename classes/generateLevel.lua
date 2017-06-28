local class = {}

local physics = require( "physics" )
--local newArc = require( "classes.arc" ).newArc 
require( "classes.randomlua")
local newRandNum = require( "classes.GenerateRandNum" ).generateRandNum
local colourTrans = require( "classes.colourTransition" ).TransitionColour
local findColourMatches = require( "classes.findWallColourMatches" ).findColourMatches
local checkLevelCompletion = require( "classes.endGameState" ).endGameState
local gamemath = require( "classes.gameMath" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" )
--local randomSeedStore = require( "libs.randomSeedStore" )

local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.generateLevel (_gameGroup, levelParams)
	--physics.setDrawMode( "debug" )
	local gameGroup = _gameGroup --gameGroup is the group that contains the other level objects such as spikes and laser traps, after play.lua generates them
	local newcircle, newwall, newportal, newexit, newtile, currentTextGroup, currentWallGroup, wallGroupTbl, RedColourVal, GreenColourVal, BlueColourVal, movingwalltimer  
	local shapeColourId, wallColourId, wallGroupId = 0, 0, 0 
	local spikedwallTbl, spikesTbl = {}, {}
	local shapeGroup, portalGroup, wallGroup, textGroup, tileGroup = display.newGroup(), display.newGroup(), display.newGroup(), display.newGroup(), display.newGroup()
	local currentLevel = levelParams --this variable is to be used in the segment touch listener
	local movingwallTrigger = false --default flag for movingwalltrigger, will be set to true once the trap is triggered

	local function circleTouchListener( self, event )
		local phase = event.phase
		local stage = display.getCurrentStage()
		local dx, dy
		--local movementScale = 1000
		
		if phase == "began" then
			stage:setFocus(self)
			self.isFocus = true
			self.x1 = event.x
			self.y1 = event.y 
			--make other non touched shapes, i.e. isFocus=nil, temporarily invisible and set their isBodyActive=false
			for i = 1, shapeGroup.numChildren do 
				local childShape = shapeGroup[i] 
				if childShape.type == 'circle' and not childShape.isFocus then
					childShape.isBodyActive = false
					childShape.isVisible = false 
				end
			end 	

		elseif self.isFocus then
			if phase == "moved" then				
				self.x2 = event.x
				self.y2 = event.y 			
				if self.touchJoint.isActive then 
				--	local targetMoveX, targetMoveY = dx*movementScale, dy*movementScale
					self.touchJoint:setTarget(self.x2, self.y2) --;print('touchJoint', tostring(self.touchJoint.isActive) )
				end 
				self.x1 = self.x2
				self.y1 = self.y2	

			elseif phase == "ended" then												
				stage:setFocus(nil)
        		self.isFocus = false
        		self.x1, self.x2, self.y1, self.y2 = nil, nil, nil, nil
        		--set all shapes back to visible and isbodyactive to true
        		for i = 1, shapeGroup.numChildren do 
        			local childShape = shapeGroup[i] 
        			if childShape.type == 'circle' and not childShape.isFocus then								
						childShape.isBodyActive = true
						childShape.isVisible = true 
					end 
				end			 
        	end --ends if phase==moved elseif phase==ended condition
    	end --ends if phase==began elseif self.isFocus condition
 
    return true
	end --ends shapeTouchListener function

	local function shapeTeleport( _shape, _portalEntrance )
		local portalEntrance = _portalEntrance
		local shape = _shape
		local portalExit
		local exitPortalFound = false 
		
		local function fadeIn( obj )
			transition.fadeIn( obj, {time=600, onComplete = function() 
																obj.isBodyActive = true 
																obj.touchJoint:setTarget(obj.x, obj.y)																
																--obj.collision = circleCollisionListener
																--obj:addEventListener('collision')																
															end} )			
		end

		local function teleport( obj )
							
			if portalGroup.numChildren ~= nil then			
				for i = 1, portalGroup.numChildren do
					local childPortal = portalGroup[i] ;print('portal', i)
					if childPortal.tag == portalEntrance.tag and childPortal.id ~= portalEntrance.id then 
						portalExit = childPortal ;print('teleporting shape')
						if shape.isBodyActive then shape.isBodyActive = false end --final check that physics of circle is disabled before moving																
						transition.moveTo( shape, {time=50, x = portalExit.x, y = portalExit.y, onComplete=fadeIn} )
						portalExit.containsShape = true	
						exitPortalFound = true 										
					end

					if exitPortalFound then break end
				end
			end
			--reset portal variables
			portalExit = nil 
			exitPortalFound = false
			portalEntrance.containsShape = false 
		end

		transition.fadeOut( shape, {time=500, onComplete=teleport} )
			
	end

	local function moveObjOffScreen( obj )
		timer.performWithDelay(1, function() physics.removeBody(obj) end)
		if obj.y > halfH then --object in lower half of screen
			obj.y = screenH + 200
		else --object in upper half of screen
			obj.y = -200
		end
		obj.isSaved = true
		print('obj alpha value:', obj.alpha)
	end

	local function fadeOutCircle( circle )
		transition.fadeOut(circle, {time=800, onComplete=function()					
 					timer.performWithDelay(1, physics.removeBody(circle))
 					circle.isSaved = false
 					circle.isActive = false
 				end	} )
	end

	local function circleCollisionListener( self, event )
		local distance, pair_Of_walls_opened

		if ( event.phase == "began" ) then
        	print( self.type .. self.id, ": collision began with " .. event.other.type .. event.other.id  )
 			if self.type == 'circle' and event.other.type == 'wall' then
 				print( 'wall group', event.other.parent.id)
 				--transitionParams = { startColour = event.other.colour, endColour = self.colour, time = 800, transition = easing.inQuad }
 				--colourTrans(event.other, transitionParams)
 				--self.touchJoint:setTarget(self.x, self.y)
 				local circleRedval, circleGreenval, circleBlueval = unpack(self.colour)
 				event.other:setFillColor(circleRedval, circleGreenval, circleBlueval)
 				event.other.colour = self.colour 				
 				pair_Of_walls_opened = findColourMatches(event.other, wallGroup)	
 				if pair_Of_walls_opened then 
 					currentLevel.shapeDetails.no_of_opened_pairs_of_walls = currentLevel.shapeDetails.no_of_opened_pairs_of_walls + 1
 					print('no_of_opened_pairs_of_walls:', currentLevel.shapeDetails.no_of_opened_pairs_of_walls)
 				end
 			elseif self.type == 'circle' and event.other.type == 'portal' then
 				print(tostring(event.other.containsShape))
 				if not event.other.containsShape then
 					self.touchJoint:setTarget(self.x, self.y)
 					event.other.containsShape = true
 					--check if circle enters the portal completely 	
 					distance = gamemath.find_distance(self, event.other); print('distance between circle and portal:', distance)
 					if distance < 100 then 				
 						print('running teleporting process')
 										
 						timer.performWithDelay( 10, 
 							function() --self:removeEventListener( 'collision', circleCollisionListener )
 										self.isBodyActive = false	
 										shapeTeleport(self, event.other)
 							end )
 					end
 				end

 			elseif self.type == 'circle' and event.other.type == 'exit sensor' then
 				transition.fadeOut(self, {time=800, onComplete=moveObjOffScreen})

 			elseif self.type == 'circle' and event.other.type == 'spike' then
 				fadeOutCircle(self)

 			elseif self.type == 'circle' and event.other.type == 'swinging spike trap' then
 				fadeOutCircle(self)	

 			elseif self.type == 'circle' and event.other.type == 'asteroid trap' then
 				fadeOutCircle(self)
 			elseif self.type == 'circle' and event.other.type == 'boomerang trap' then
 				fadeOutCircle(self)

 			elseif self.type == 'circle' and event.other.type == 'circle' then
 				self.touchJoint:setTarget(self.x, self.y)
 				event.other.touchJoint:setTarget(event.other.x, event.other.y)

 			--elseif self.type == 'circle' and event.other.type == 'triggerZone' then
 				--this triggers the event where the wall starts to close in, set triggerflag to true once triggered, as this event is only triggered once				
 			--	if not movingwallTrigger then
 			--		movingwallTrigger = true
 			--		movingwalltimer = timer.performWithDelay(currentLevel.movingSpikedWallDetails.timer, 
 			--		function()						
 			--			local leftwall = spikedwallTbl[1]
 			--			local rightwall = spikedwallTbl[2]
 			--			local leftspike = spikesTbl[1]
 			--			local rightspike = spikesTbl[2]
 			--			transition.to(leftwall, {timer=500, delta=true, x=currentLevel.movingSpikedWallDetails.distancetoMove})
 			--			transition.to(rightwall, {timer=500, delta=true, x=-currentLevel.movingSpikedWallDetails.distancetoMove})
 			--			transition.to(leftspike, {timer=500, delta=true, x=currentLevel.movingSpikedWallDetails.distancetoMove})
 			--			transition.to(rightspike, {timer=500, delta=true, x=-currentLevel.movingSpikedWallDetails.distancetoMove})
 			--		end, 
 			--		currentLevel.movingSpikedWallDetails.iterations)
 			--	end

 			end
    	elseif ( event.phase == "ended" ) then
        	print( self.type .. ": collision ended with " .. event.other.type .. event.other.id )
        	if event.other.type == 'portal' then
        		event.other.containsShape = false
        	end
    	end
	end

	--generate background rects, that change colour to the shapes that are saved, in the endgamestate.
    local backgroundHeight, backgroundPosition = screenH/currentLevel.no_ofshapes.circles, 0  
	for i = 1, currentLevel.no_ofshapes.circles do        
        local background = display.newRect( halfW, (0.5*backgroundHeight)+(backgroundHeight*backgroundPosition), screenW, backgroundHeight)
        background:setFillColor(0,0,0)
        shapeGroup:insert(background)
		background.colour = {0,0,0}      
        background.type = 'background'
        background.id = i 
        background.alpha = 0.6
        backgroundPosition = backgroundPosition + 1
    end

	--generate shapes, add physics, assign listeners
	for i = 1, currentLevel.no_ofshapes.circles do 
		--local circleMovementGroup = display.newGroup()
		--circleMovementGroup.id = i 
		--circleMovementGroup.type = 'movement'	
		newcircle = display.newCircle( currentLevel.shapeDetails.circle_coordinates[i].x, currentLevel.shapeDetails.circle_coordinates[i].y, currentLevel.shapeDetails.circle_radius )		
		RedColourVal, GreenColourVal, BlueColourVal = unpack(currentLevel.shapeDetails.circle_colours[i])
		newcircle:setFillColor(RedColourVal, GreenColourVal, BlueColourVal) 
		newcircle.colour = currentLevel.shapeDetails.circle_colours[i] 
		newcircle.type = 'circle'
		newcircle.id = i 
		newcircle.hasBlockerPower = false
		newcircle.isActive = true --this flag is to help differentiate the circles that are still in play and those not in play, i.e. destroyed
		physics.addBody(newcircle, {density=0.1, bounce=0, friction=0.5, radius=newcircle.path.radius})		
		newcircle.isFixedRotation = true
		newcircle.linearDamping = 1
		newcircle.touchJoint = physics.newJoint( "touch", newcircle, newcircle.x, newcircle.y )
		newcircle.touchJoint.frequency = 5000
		newcircle.touchJoint.dampingRatio = 1
		newcircle.touchJoint.maxForce = 10000
		newcircle.touch = circleTouchListener
		newcircle:addEventListener('touch')
		newcircle.collision = circleCollisionListener
		newcircle:addEventListener('collision')
		--newcircle.movementEnabled = true 
		--newcircle.movementGroup = circleMovementGroup
		--newcircle.activeGroup = shapeGroup
		shapeGroup:insert(newcircle)
	end 

	--generate walls
	local no_ofwalls_perGroup, no_ofwallGroups, tagText, wall_vertices	 
	wallGroupTbl = currentLevel.wallGroupsTbl
	wall_width = currentLevel.shapeDetails.wall_width
	wall_height = currentLevel.shapeDetails.wall_height
	wall_vertices = {-wall_width/2,-wall_height/2, wall_width/2,-wall_height/2, (wall_width/2)-wall_height,wall_height/2, (-wall_width/2)+wall_height,wall_height/2}	
	
	for i = 1, currentLevel.no_ofshapes.wall_arrangement_types do
		no_ofwallGroups = currentLevel.shapeDetails.no_of_groups_for_each_arrangement[i]
		no_ofwalls_perGroup = currentLevel.shapeDetails.no_of_walls_in_arrangement[i]				
		for j = 1, no_ofwallGroups do 	
			currentWallGroup = display.newGroup() 
			wallGroupTbl[#wallGroupTbl+1] = currentWallGroup
			wallGroupId = wallGroupId + 1
			for k = 1, no_ofwalls_perGroup do		
				newwall = display.newPolygon(0, 0, wall_vertices)				
				RedColourVal, GreenColourVal, BlueColourVal = unpack(currentLevel.shapeDetails.wall_colours[wallGroupId][k])
				newwall:setFillColor(RedColourVal, GreenColourVal, BlueColourVal)
				newwall.colour = currentLevel.shapeDetails.wall_colours[wallGroupId][k]
				newwall.rotation = currentLevel.shapeDetails.wall_rotations[i][k] 

				if newwall.rotation == 0 then
					newwall.orientation = 'horizontal'
				elseif newwall.rotation == 180 then
					newwall.orientation = 'horizontal'
				elseif newwall.rotation == 90 then
					newwall.orientation = 'vertical'
				elseif newwall.rotation == 270 then
					newwall.orientation = 'vertical'
				end
				
				newwall.id = k	
				newwall.type = 'wall'		
				newwall:translate(currentLevel.shapeDetails.wall_translations[i][k][1], currentLevel.shapeDetails.wall_translations[i][k][2])
				--tagText = display.newText( tostring(j), newpolygon.x, newpolygon.y, myApp.fontBold, 40 )
				--tagText:translate(currentLevel.shapeDetails.bar_translation[j][1], currentLevel.shapeDetails.bar_translation[j][2])
				--local dx = currentLevel.shapeDetails.circle_coordinates[i].x - newpolygon.x 
				--local dy = currentLevel.shapeDetails.circle_coordinates[i].y - newpolygon.y 
				--tagText:translate(dx, dy)
				currentWallGroup:insert(newwall)				
			end			
			currentWallGroup.x, currentWallGroup.y = currentLevel.shapeDetails.wall_group_coordinates[wallGroupId].x, currentLevel.shapeDetails.wall_group_coordinates[wallGroupId].y			
			currentWallGroup.id = wallGroupId
			currentWallGroup.anchorChildren = true
			wallGroup:insert(currentWallGroup)

			--newtile = display.newRect(0, 0, wall_width, wall_width)
			--newtile.x, newtile.y = currentWallGroup.x, currentWallGroup.y
			--newtile.fill = colours.pearl.colour  
			--newtile.id = i 
			--newtile.strokeWidth = 5
			--newtile:setStrokeColor(unpack(colours.red.colour))
			--tileGroup:insert(newtile)
		end		
	end

	--count total no of walls and move wall.x and wall.y to their localtocontent coordinates, thus when physics body is added, its accurate
	local no_of_walls = 0 
	for i = 1, wallGroup.numChildren do
		local childWallGroup = wallGroup[i] --sub wall group
		for j = 1, childWallGroup.numChildren do
			local childWall = childWallGroup[j] --wall in sub wall group		
			no_of_walls = no_of_walls + 1
			childWall.actualX, childWall.actualY = childWall:localToContent(0,0)		
			--print( 'wall group', i, 'wall actual coordinates on stage', childWall.id, childWall.actualX, childWall.actualY )
			childWall.x, childWall.y = childWall.actualX, childWall.actualY
			--print( 'wall centre point after adjustment', childWall.id, childWall.x, childWall.y )
			physics.addBody(childWall, 'static', {density=1.5, bounce=0.1, friction=1, shape=wall_vertices})			
		end
	end
	print('total no_of_walls:', no_of_walls)
	
	--check if there are any moving spiked walls, if yes, assign special id to them, add spiked walls to a separate table for easier retrieval later
	local movingwallGrpId, ShortenWallId, MovingWallId 
	local movingSpikeWallFound = false
	if currentLevel.movingSpikedWallDetails then
		movingwallGrpId = currentLevel.movingSpikedWallDetails.wallGrpId --this identifies which group of walls is the movingspikedwall trap
		ShortenWallId = currentLevel.movingSpikedWallDetails.shortenwallId --this table contains which walls within the movingwallGrp will shorten when trap is triggered
		MovingWallId = currentLevel.movingSpikedWallDetails.movingwallId --similarly, contains which wall that will move
		for i = 1, wallGroup.numChildren do
			local childWallGroup = wallGroup[i]
			if childWallGroup.id == movingwallGrpId then 
				for j = 1, childWallGroup.numChildren do
					local childWall = childWallGroup[j] --wall in sub wall group
					for k = 1, #MovingWallId do 
						if childWall.id == MovingWallId[k] then
							childWall.specialId = 'spiked wall'
							spikedwallTbl[#spikedwallTbl+1] = childWall
						end
					end
					for h = 1, #ShortenWallId do
						if childWall.id == ShortenWallId[h] then				
							childWall.specialId = 'shorten wall'
						end 
					end
				end 
				movingSpikeWallFound = true
			end
			if movingSpikeWallFound then break end
		end 	
	end

	--check for rapid kinematic moving spikes and add to spikesTbl
	if currentLevel.spikeGroup.numChildren ~= 0 then
		for i = 1, currentLevel.spikeGroup.numChildren do
 		local childSpike = currentLevel.spikeGroup[i]
 			if childSpike.type == 'moving spike' then
 				spikesTbl[#spikesTbl+1] = childSpike
 			end
 		end
 	end

 	--check if blocker boulders exists
 	if currentLevel.no_ofshapes.blocker ~= nil then 
 		local blocker, blocker_vertices, blocker_texture
 		for i = 1, currentLevel.no_ofshapes.blocker do
 			blocker_vertices = currentLevel.shapeDetails.blocker_vertices
 			blocker_texture = currentLevel.shapeDetails.blockerTexture
 			--blocker = display.newPolygon(0,0, blocker_vertices)
 			blocker = display.newCircle(0,0, currentLevel.shapeDetails.circle_radius*1.5)
 			blocker.x, blocker.y = currentLevel.shapeDetails.blocker_coordinates.x, currentLevel.shapeDetails.blocker_coordinates.y 
 			blocker.id = i 
 			blocker.type = 'blocker'
 			blocker.fill = { type="image", filename = blocker_texture.filename, baseDir = blocker_texture.baseDir }
 			physics.addBody(blocker, "dynamic", {density=2, friction=0.5, bounce=0, radius=blocker.path.radius}) --shape=blocker_vertices
 			blocker.linearDamping = 1
 			blocker.angularDamping = 1
 			shapeGroup:insert(blocker)
 		end
 	end

	--generate portals
	if currentLevel.no_ofshapes.portals ~= 0 then
	for i = 1, currentLevel.no_ofshapes.portals do 
		newportal = display.newCircle( currentLevel.shapeDetails.portal_coordinates[i].x, currentLevel.shapeDetails.portal_coordinates[i].y, currentLevel.shapeDetails.circle_radius*1.1 )
		newportal.fill = colours.pearl.colour 
		newportal.type = 'portal'
		newportal.id = i 
		newportal.tag = currentLevel.portalTags[i]
		newportal.containsShape = false --default state for newportal doesnt contain any shape to teleport
		transition.blink(newportal, {time=1800})
		physics.addBody(newportal, 'static', {density=1, friction=0.5})
		newportal.isSensor = true
		portalGroup:insert(newportal)
	end	
	end
	
	--generate exit sensor
	for i = 1, currentLevel.no_ofshapes.exit_sensor do
		newexit = display.newRect(0,0, currentLevel.shapeDetails.wall_width, currentLevel.shapeDetails.wall_height*2)
		newexit.x = currentLevel.shapeDetails.exit_coordinates[i].x
		newexit.y = currentLevel.shapeDetails.exit_coordinates[i].y
		newexit.alpha = 0.05  
		newexit.type = 'exit sensor'
		newexit.id = i 
		newexit.rotation = currentLevel.shapeDetails.exit_coordinates[i].rotation or 0
		shapeGroup:insert(newexit)
		physics.addBody(newexit, 'static', {density=1, friction=0.2})
		newexit.isSensor = true
		newexit.Text = display.newText( 'Exit', newexit.x, newexit.y, myApp.font, 40)
		newexit.Text.fill = colours.pearl.colour
		newexit.Text.rotation = currentLevel.shapeDetails.exit_coordinates[i].rotation or 0 
		textGroup:insert(newexit.Text) 
	end

	--release textures to prevent memory leaks
	graphics.releaseTextures( { type="image" } )

	return shapeGroup, portalGroup, wallGroup, textGroup, tileGroup
end

return class 