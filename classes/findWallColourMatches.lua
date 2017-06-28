local class = {}
local physics = require( "physics" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" )
local gameMath = require( "classes.gameMath" )

local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH
--this class handles all the events when a shape collides with a wall, if walls do not have the specialId 'shorten wall', then it's a regular fadeout if walls' colours matches
function class.findColourMatches(collidedWall, _wallGroup)
	local childGroupB, childWallB, RedVal_B, GreenVal_B, BlueVal_B, distanceAB, distance
	local wallGroup = _wallGroup
	local childWallA = collidedWall
	local childGroupA = childWallA.parent
	local RedVal_A, GreenVal_A, BlueVal_A = unpack(childWallA.colour)

	local function removeObj (obj)		
		display.remove(obj)
		obj = nil 
	end

	local function resetWall( obj )
		-- resets the wall's physics and anchor properties after transition	
		obj.anchorX = 0.5	
		obj.anchorY = 0.5
		physics.addBody(obj, 'static', {density=1.5, bounce=0.1, friction=1})
	end

	local function FadeOutWallsAndCleanup( WallA, WallB )
		timer.performWithDelay(1, function() physics.removeBody(WallA) ; physics.removeBody(WallB) end )	
		--WallA.isBodyActive, WallB.isBodyActive = false, false	
		print('wall A group and id:', WallA.parent.id, WallA.id) ;print('wall B group and id:', WallB.parent.id, WallB.id)	
		transition.fadeOut(WallA, {time=800, onComplete=removeObj}) 
		transition.fadeOut(WallB, {time=800, onComplete=removeObj}) 
	end

	local function create_adjacentWall( objWall )
		-- this creates an adjacent wall to objWall
		
		local wall_width, wall_height = objWall.contentWidth, objWall.contentHeight
		local adjWallWidth, adjWallHeight = wall_width/4, wall_height/4
		local adjWall_x, adjWall_y = objWall.x + adjWallWidth, objWall.y + adjWallHeight
		local adjwall_vertices = {-adjWallWidth/2,-wall_height/2, adjWallWidth/2,-wall_height/2, (adjWallWidth/2)-wall_height,wall_height/2, (-adjWallWidth/2)+wall_height,wall_height/2}
		local adjWall = display.newPolygon( objWall.parent, objWall.x, objWall.y, adjwall_vertices )
		
		if objWall.orientation == 'horizontal' then --adjwall is horizontal	
			adjWall.x = adjWall_x			
			--adjWall.anchorX = 1
		elseif objWall.orientation == 'vertical' then --adjwall is vertical					
			adjWall.y = adjWall_y		
			--adjWall.anchorY = 1
		end

		local RedVal, GreenVal, BlueVal = unpack(objWall.colour)
		adjWall:setFillColor(RedVal, GreenVal, BlueVal)
		adjWall.colour = objWall.colour 
		adjWall.type = 'wall'
		adjWall.id = objWall.id 
		adjWall.rotation = objWall.rotation
		adjWall.orientation = objWall.orientation
		return adjWall
	end

	local function shorteningWallTrans( wallA, wallB )
		--for shorten wall trans, the sequence is 1. change childwall's anchorX or Y, 2. half childwall's width, 3. create adjacent wall, 4. transition of both walls
		local adjWallA, adjWallB
		local wallA, wallB = wallA, wallB 
		if wallA.orientation == 'horizontal' then
			--wallA.anchorX = 0 
			--wallA.width = wallA.width/2 
			--wallB.anchorX = 0 
			--wallB.width = wallB.width/2 
			adjWallA = create_adjacentWall(wallA)
			adjWallB = create_adjacentWall(wallB)
			transition.to( wallA, {time=1200, delta=true, x=-wallA.width, onComplete=resetWall} ) --width=0.5*wallA.width
			transition.to( adjWallA, {time=1200, delta=true, x=0.75*adjWallA.width, onComplete=resetWall} )
			transition.to( wallB, {time=1200, delta=true, x=-wallB.width, onComplete=resetWall} ) --width=0.5*wallB.width
			transition.to( adjWallB, {time=1200, delta=true, x=0.75*adjWallB.width, onComplete=resetWall} )
		elseif wallA.orientation == 'vertical' then 
			--wallA.anchorY = 0 
			--wallA.height = wallA.height/2 
			--wallB.anchorY = 0 
			--wallB.height = wallB.height/2 
			adjWallA = create_adjacentWall(wallA)
			adjWallB = create_adjacentWall(wallB)
			transition.to( wallA, {time=1200, delta=true, x=-wallA.height, onComplete=resetWall} )
			transition.to( adjWallA, {time=1200, delta=true, x=0.75*adjWallA.height, onComplete=resetWall} )
			transition.to( wallB, {time=1200, delta=true, x=-wallB.height, onComplete=resetWall} )
			transition.to( adjWallB, {time=1200, delta=true, x=0.75*adjWallB.height, onComplete=resetWall} )
		end

	end

	--compare the wall that collided with the circle with all the other walls
	for i = 1, wallGroup.numChildren do
		childGroupB = wallGroup[i] 
		for j = 1, childGroupB.numChildren do
			childWallB = childGroupB[j] 
			
			if childWallA.parent.id == childWallB.parent.id then --if wall A and B are from the same group, ensure that wall ids are different
				if childWallA.id == childWallB.id then					
					childWallB = nil 		
				end			
			end
			if childWallB ~= nil then --ensure this variable contains a wall
				RedVal_B, GreenVal_B, BlueVal_B = unpack(childWallB.colour)
				--print( RedVal_A, GreenVal_A, BlueVal_A, RedVal_B, GreenVal_B, BlueVal_B )
				--compare colours and orientation and ensure childWallB is a valid wall
				if RedVal_A == RedVal_B and GreenVal_A == GreenVal_B and BlueVal_A == BlueVal_B and childWallA.orientation == childWallB.orientation then
					--if colour is the same, calculate distance
					distance = gameMath.find_distance(childWallA, childWallB)
					
					if childWallA.orientation == 'horizontal' then --wall A and B are horizontal, so take difference in y coordinates(distanceAB) and compare it to contentHeight, the actual distance, is also needed				
						distanceAB = math.abs(childWallA.y - childWallB.y) --take only magnitude 
						if distanceAB <= 1.2*childWallA.contentHeight and distance <= 1.5*childWallA.contentHeight then --give some buffer to find out if the two walls are adjacent to each other	
							--if no specialid found, nil is returned, hence do normal fadeout transitions
							if childWallA.specialId == nil and childWallB.specialId == nil then													 
								FadeOutWallsAndCleanup(childWallA, childWallB)
							elseif childWallA.specialId == 'shorten wall' then	
								print('running shorten wall A transition')											
								timer.performWithDelay(1, function() physics.removeBody(childWallA) end)				
								shorteningWallTrans(childWallA, childWallB)
							elseif childWallB.specialId == 'shorten wall' then	
								print('running shorten wall B transition')											
								timer.performWithDelay(1, function() physics.removeBody(childWallB) end)				
								shorteningWallTrans(childWallA, childWallB)
							end --end of specialid condition checking
						end	
					elseif childWallA.orientation == 'vertical' then --wall A and B are vertical, so take difference in x coordinates(distanceAB) and compare it to contentWidth, the actual distance, is also needed
						distanceAB = math.abs(childWallA.x - childWallB.x) --take only magnitude 
						if distanceAB <= 1.2*childWallA.contentWidth and distance <= 1.5*childWallA.contentWidth then --this is if walls are vertical, hence the contentWidth is the shorter side
							if childWallA.specialId == nil and childWallB.specialId == nil then
								FadeOutWallsAndCleanup(childWallA, childWallB)
							elseif childWallA.specialId == 'shorten wall' then	
								print('running shorten wall A transition')											
								timer.performWithDelay(1, function() physics.removeBody(childWallA) end)				
								shorteningWallTrans(childWallA, childWallB)
							elseif childWallB.specialId == 'shorten wall' then	
								print('running shorten wall B transition')											
								timer.performWithDelay(1, function() physics.removeBody(childWallB) end)				
								shorteningWallTrans(childWallA, childWallB)
							end --end of specialid condition checking
						end					
					end						 					
				end	--end of comparing colours and orientation
			end --end of checking if childWallB exists
		end --end of for j = 1 loop
	end --end of i = 1 loop

	return pair_Of_walls_opened --flag to indicate if a pair of walls have been opened
end
return class 