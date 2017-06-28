local class = {}
local screenSize = require( "libs.screenSize" )
local gameMath = require( "classes.gameMath")
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.checkGameOverState( _wallGroup, _shapeGroup, levelParams )
	local wallGroup, shapeGroup, currentLevel = _wallGroup, _shapeGroup, levelParams
	local no_of_pairs_of_walls_toOpen = currentLevel.shapeDetails.no_of_pairs_of_walls_toOpen
	--local no_of_opened_pairs_of_walls = currentLevel.shapeDetails.no_of_opened_pairs_of_walls
	local doublewallsConnectionTbl = {} --this table saves and stores the pairs of parallel walls that are adjacent to each other.
	local duplicateCirclesTbl = {} --this stores the duplicates of the circles in shapeGroup for the simulation.
	local childwallGroupA, childwallGroupB, childWallA, childWallB, childShape, RedVal_A, GreenVal_A, BlueVal_A, RedVal_B, GreenVal_B, BlueVal_B 
	local duplicateCircle, distanceAB, distance 
	local isGameOver = false --default flag for isGameOver
	
	local function checkforDuplicateDoubleWalls( wallAToCheck, wallBToCheck )
		local duplicateWallAExists, duplicateWallBExists, duplicatePairOfWallsExists = false
		if #doublewallsConnectionTbl ~= 0 then --check if table has existing entries that alrd contain wall A and wall B, to prevent duplicates
			for i = 1, #doublewallsConnectionTbl do
				local doubleWall = doublewallsConnectionTbl[i]			
				if doubleWall[1].parent.id == wallAToCheck.parent.id and doubleWall[1].id == wallAToCheck.id then 
					duplicateWallAExists = true 
				elseif doubleWall[2].parent.id == wallAToCheck.parent.id and doubleWall[2].id == wallAToCheck.id then 
					duplicateWallAExists = true
				end

				if doubleWall[1].parent.id == wallBToCheck.parent.id and doubleWall[1].id == wallBToCheck.id then 
					duplicateWallBExists = true 
				elseif doubleWall[2].parent.id == wallBToCheck.parent.id and doubleWall[2].id == wallBToCheck.id then 
					duplicateWallBExists = true
				end
			end
		end

		if duplicateWallAExists and duplicateWallBExists then duplicatePairOfWallsExists = true end

		return duplicatePairOfWallsExists
	end

	-- find out where all the double walls are at and add them to a table, these double walls are where the cells/nodes are connected to each other
	for i = 1, wallGroup.numChildren do
		childwallGroupA = wallGroup[i] 
		for j = 1, childwallGroupA.numChildren do
			childWallA = childwallGroupA[j] 
			for k = 1, wallGroup.numChildren do
				childwallGroupB = wallGroup[k]
				for l = 1, childwallGroupB.numChildren do					
					childWallB = childwallGroupB[l] 	
					if childWallA.id ~= childWallB.id and childWallA.parent.id ~= childWallB.parent.id then --ensure the wall isn't compared with itself
						distance = gameMath.find_distance(childWallA, childWallB) --this is distance using the formulae, sqrt[(x2-x1)^2 + (y2-y1)^2]				
						if childWallA.orientation == 'horizontal' then --wall A and B are horizontal, so take difference in y coordinates and compare it to contentHeight
							--distanceAB = math.abs(childWallA.y - childWallB.y) --take only magnitude 					
							if distance < 1.5*childWallA.contentHeight then 								
								local duplicatePairOfWallsExists = checkforDuplicateDoubleWalls( childWallA, childWallB )
								if not duplicatePairOfWallsExists then 
									print('wall A', childwallGroupA.id, childWallA.id, 'and wall B', childwallGroupB.id, childWallB.id, 'are parallel and adjacent')
									doublewallsConnectionTbl[#doublewallsConnectionTbl+1] = {childWallA, childWallB, canBeOpened = false} 
								end								
							end

						elseif childWallA.orientation == 'vertical' then --wall A and B are vertical, so take difference in x coordinates and compare it to contentWidth
							--distanceAB = math.abs(childWallA.x - childWallB.x) --take only magnitude 
							if distance < 1.5*childWallA.contentWidth then 
								print('wall A', childwallGroupA.id, childWallA.id, 'and wall B', childwallGroupB.id, childWallB.id, 'are parallel and adjacent')
								local duplicatePairOfWallsExists = checkforDuplicateDoubleWalls( childWallA, childWallB )
								if not duplicatePairOfWallsExists then 
									print('wall A', childwallGroupA.id, childWallA.id, 'and wall B', childwallGroupB.id, childWallB.id, 'are parallel and adjacent')
									doublewallsConnectionTbl[#doublewallsConnectionTbl+1] = {childWallA, childWallB, canBeOpened = false} 
								end		
							end
						end
					end
				end
			end
		end
	end

	if #doublewallsConnectionTbl ~= 0 then --this is to ensure there are parallel and adjacent walls to compare, because if there are none, it means all the paths have been opened up and this loop is no longer required
		print('no of pairs of parallel and adjacent walls:', #doublewallsConnectionTbl) 
		--create a duplicate circle for each circle in shapeGroup, calculate the distance between the duplicate circle and all the walls in the doublewallConnectionTbl
		for i = 1, shapeGroup.numChildren do
			childShape = shapeGroup[i]
			if childShape.type == 'circle' then
				if childShape.isActive and childShape.alpha ~= 0 then 
					RedVal_A, GreenVal_A, BlueVal_A = unpack(childShape.colour) 
					duplicateCircle = display.newCircle( childShape.x, childShape.y, childShape.path.radius )
					duplicateCircle:setFillColor(RedVal_A, GreenVal_A, BlueVal_A )
					duplicateCircle.colour = childShape.colour 
					duplicateCircle.id = childShape.id 
					duplicateCircle.isVisible = false 
					duplicateCircle.distancesToDoubleWalls = {}	
					--compare duplicate circle's colours with all the walls' colours in doublewallstbl and find their distances				
					for j = 1, #doublewallsConnectionTbl do 
						local doublewall = doublewallsConnectionTbl[j] --doublewall refers to the table that stores the pair of tables that are parallel and adjacent				
						local firstwall = doublewall[1] --first wall of the pair
						local secondwall = doublewall[2] --second wall of the pair
						--calculate distance between circles and walls
						duplicateCircle.distancesToDoubleWalls[j] = {distA = gameMath.find_distance(duplicateCircle, firstwall), distB = gameMath.find_distance(duplicateCircle, secondwall), 
															 doubleWallId = j, wallA = firstwall, wallB = secondwall}			
					end	
				duplicateCirclesTbl[#duplicateCirclesTbl+1] = duplicateCircle 							
				end
			end		
		end

		
		--compare the distances within the distancestodoublewalls table for each duplicated circle
		for i = 1, #duplicateCirclesTbl do
			local duplicate_circle = duplicateCirclesTbl[i] 
			local closestDistanceToWall		
			for j = 1, #duplicate_circle.distancesToDoubleWalls do --loop through all the distancetoDoublewalls and find the shortest distance, using distancetodoublewall[j].distA for comparison	
				if closestDistanceToWall == nil then
					closestDistanceToWall = duplicate_circle.distancesToDoubleWalls[j].distA 
					duplicate_circle.closestDoubleWallId = duplicate_circle.distancesToDoubleWalls[j].doubleWallId
				else
					if duplicate_circle.distancesToDoubleWalls[j].distA < closestDistanceToWall then
						closestDistanceToWall = duplicate_circle.distancesToDoubleWalls[j].distA
						duplicate_circle.closestDoubleWallId = duplicate_circle.distancesToDoubleWalls[j].doubleWallId
					elseif duplicate_circle.distancesToDoubleWalls[j].distA == closestDistanceToWall then --if there is another pair of walls that is equidistant, store it
						secondPairOfWallClosest_toCircle = duplicate_circle.distancesToDoubleWalls[j].distA
						duplicate_circle.secondPairOf_ClosestWallId = duplicate_circle.distancesToDoubleWalls[j].doubleWallId
					end
				end	
					
				--print('closest distance to wall:', math.floor(closestDistanceToWall))		
			end
			closestDistanceToWall = nil 

			for k = 1, #doublewallsConnectionTbl do
				if duplicate_circle.closestDoubleWallId == k then 
					print('duplicate circle #'..i, 'closestDoubleWallId:', duplicate_circle.closestDoubleWallId)
					RedVal_A, GreenVal_A, BlueVal_A = unpack(duplicate_circle.colour)
					--doublewall K is the closest double wall to the circle, compare distA and distB, and compare the further wall colour with the circle
					print(duplicate_circle.distancesToDoubleWalls[k].distA, duplicate_circle.distancesToDoubleWalls[k].distB)
					if duplicate_circle.distancesToDoubleWalls[k].distA > duplicate_circle.distancesToDoubleWalls[k].distB then						
						RedVal_B, GreenVal_B, BlueVal_B = unpack(duplicate_circle.distancesToDoubleWalls[k].wallA.colour)								
					else
						RedVal_B, GreenVal_B, BlueVal_B = unpack(duplicate_circle.distancesToDoubleWalls[k].wallB.colour)	
					end
					print('duplicate RGB values:', RedVal_A, GreenVal_A, BlueVal_A, 'wall RGB values:', RedVal_B, GreenVal_B, BlueVal_B )
					if RedVal_A == RedVal_B and GreenVal_A == GreenVal_B and BlueVal_A == BlueVal_B then
						print('circle', duplicate_circle.id, 'is able to open double wall', k )
						doublewallsConnectionTbl[k].canBeOpened = true 			
					end
				end 

				if duplicate_circle.secondPairOf_ClosestWallId ~= nil then --a second pair of walls that is equidistant to the circle exists
					if duplicate_circle.secondPairOf_ClosestWallId == k then 
						print('duplicate circle #'..i, 'secondPairOf_ClosestWallId:', duplicate_circle.secondPairOf_ClosestWallId)
						RedVal_A, GreenVal_A, BlueVal_A = unpack(duplicate_circle.colour)
						--doublewall K is the closest double wall to the circle, compare distA and distB, and compare the further wall colour with the circle
						print(duplicate_circle.distancesToDoubleWalls[k].distA, duplicate_circle.distancesToDoubleWalls[k].distB)
						if duplicate_circle.distancesToDoubleWalls[k].distA > duplicate_circle.distancesToDoubleWalls[k].distB then						
							RedVal_B, GreenVal_B, BlueVal_B = unpack(duplicate_circle.distancesToDoubleWalls[k].wallA.colour)								
						else
							RedVal_B, GreenVal_B, BlueVal_B = unpack(duplicate_circle.distancesToDoubleWalls[k].wallB.colour)	
						end
						print('duplicate RGB values:', RedVal_A, GreenVal_A, BlueVal_A, 'wall RGB values:', RedVal_B, GreenVal_B, BlueVal_B )
						if RedVal_A == RedVal_B and GreenVal_A == GreenVal_B and BlueVal_A == BlueVal_B then
							print('circle', duplicate_circle.id, 'is able to open double wall', k )
							doublewallsConnectionTbl[k].canBeOpened = true 					
						end
					end 
				end
			end
			
		end	--end of for i=1, duplicateCirclesTbl loop					
	end --end of if #doublewallsConnectionTbl ~= nil

	local no_of_walls_that_can_be_opened = 0
	local all_parallel_and_adjacent_walls_are_opened = false
	--once the above loops are completed, update the value of no of walls that can be opened, check if doublewallsConnectionTbl is not empty
	if #doublewallsConnectionTbl ~= 0 then
		for i = 1, #doublewallsConnectionTbl do 
			local doublewall = doublewallsConnectionTbl[i]		
			if doublewall.canBeOpened then 
				no_of_walls_that_can_be_opened = no_of_walls_that_can_be_opened + 1					
			end		
		end
		print('no_of_walls_that_can_be_opened', no_of_walls_that_can_be_opened)
	else --no parallel and adjacent walls found
		all_parallel_and_adjacent_walls_are_opened = true 
	end
	--this part needs to be updated, especially for levels where the situation where all the circles are in the last segment of the maze with 
	--no more walls to break but just obstacles to overcome. Thus a new variable that stores the no of pairs of walls that have been broken. if this variable
	--is equal to the no of pairs of walls that needs to be broken(a variable that can be set in the levels table since its fixed by design), it means the player has
	--successfully made a path to the exit
	if no_of_walls_that_can_be_opened > 0 and not all_parallel_and_adjacent_walls_are_opened then 
		print('path can be created')
	elseif no_of_walls_that_can_be_opened == 0 and all_parallel_and_adjacent_walls_are_opened then 
		print('all paths has been opened')
	elseif no_of_walls_that_can_be_opened == 0 and not all_parallel_and_adjacent_walls_are_opened then 
		isGameOver = true		
	end

	return isGameOver
end

return class 