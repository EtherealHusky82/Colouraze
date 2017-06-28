local class = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local gamemath = require( "classes.gameMath" )
local findMatchingColourTriangles = require("classes.findPuzzleTriangleColourMatches").findColourMatches

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.newTriangularPuzzle( levelparams )
	local currentlevel = levelparams
	local puzzleTrianglesGroup = display.newGroup()
	
	local function puzzleTriangleCollisionListener( self, event )
		-- body
		local phase = event.phase

		if phase == 'began' then			
			if event.other.type == 'circle' then
 				print( 'triangle id:', self.id)				
 				self.fill = event.other.colour
 				self.colour = event.other.colour
 				findMatchingColourTriangles(puzzleTrianglesGroup)
 			end
		elseif phase == 'ended' then
			print('end of collision between puzzle triangles and circle')
		end

	end

		
	for i = 1, currentlevel.puzzleDetails.no_of_pairs_of_triangles do
		local puzzleTriangle1 = display.newPolygon(0,0, currentlevel.puzzleDetails.triangle_vertices)	
		--for each triangle, there is an oppossite triangle, that is rotated 180
		local puzzleTriangle2 = display.newPolygon(0,0, currentlevel.puzzleDetails.triangle_vertices)
		puzzleTriangle1.x, puzzleTriangle1.y = currentlevel.puzzleDetails.triangle_coordinates[i][1].x, currentlevel.puzzleDetails.triangle_coordinates[i][1].y 
		puzzleTriangle1.id = 'A' 
		puzzleTriangle1.tag = i 
		puzzleTriangle1.type = 'puzzle triangle'
		puzzleTriangle2.x , puzzleTriangle2.y = currentlevel.puzzleDetails.triangle_coordinates[i][2].x, currentlevel.puzzleDetails.triangle_coordinates[i][2].y 
		puzzleTriangle2.id = 'B' 
		puzzleTriangle2.tag = i 
		puzzleTriangle2.type = 'puzzle triangle'				
		puzzleTriangle1.rotation = currentlevel.puzzleDetails.rotations[1]
		puzzleTriangle2.rotation = currentlevel.puzzleDetails.rotations[2]
		--check the horizontal_flip table, if a pair of triangles need to be flipped
		if currentlevel.puzzleDetails.horizontal_flip[i] then
			puzzleTriangle1.xScale = -1 
			puzzleTriangle2.xScale = -1 
		end 
		puzzleTriangle1.fill = currentlevel.puzzleDetails.triangle_colours[i][1]
		puzzleTriangle2.fill = currentlevel.puzzleDetails.triangle_colours[i][2]
		puzzleTriangle1.colour = currentlevel.puzzleDetails.triangle_colours[i][1]
		puzzleTriangle2.colour = currentlevel.puzzleDetails.triangle_colours[i][2]
		physics.addBody(puzzleTriangle1, 'static', {density=0.3, bounce=0,friction=0.3, shape=currentlevel.puzzleDetails.triangle_vertices})
		physics.addBody(puzzleTriangle2, 'static', {density=0.3, bounce=0,friction=0.3, shape=currentlevel.puzzleDetails.triangle_vertices})
		puzzleTrianglesGroup:insert(puzzleTriangle1)
		puzzleTrianglesGroup:insert(puzzleTriangle2)
		puzzleTriangle1.collision = puzzleTriangleCollisionListener
		puzzleTriangle1:addEventListener("collision")
		puzzleTriangle2.collision = puzzleTriangleCollisionListener
		puzzleTriangle2:addEventListener("collision")
	end 

	return puzzleTrianglesGroup
end
return class 