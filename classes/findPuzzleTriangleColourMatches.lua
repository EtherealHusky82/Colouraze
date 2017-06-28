local class = {}
local physics = require( "physics" )
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local myApp = require( "libs.myapp" )
local gameMath = require( "classes.gameMath" )

local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.findColourMatches( _puzzleTrianglesGroup )
	local puzzleTrianglesGroup = _puzzleTrianglesGroup
	local RedVal1, GreenVal1, BlueVal1, RedVal2, GreenVal2, BlueVal2, distance_between_triangles

	local function fadeOutObj(obj1, obj2)
		local function removeObjs()
			transition.fadeOut(obj1, {time=800, onComplete=function() display.remove(obj1);  obj1 = nil; print('object1 removed') end })
			transition.fadeOut(obj2, {time=800, onComplete=function() display.remove(obj2);  obj2 = nil; print('object2 removed') end })			 
		end	

		timer.performWithDelay(650, removeObjs)
	end

	for i = 1, puzzleTrianglesGroup.numChildren do
		local childTriangle1 = puzzleTrianglesGroup[i]
		for j = 1, puzzleTrianglesGroup.numChildren do 
			local childTriangle2 = puzzleTrianglesGroup[j]
			if childTriangle1.tag == childTriangle2.tag and childTriangle1.id ~= childTriangle2.id then --this pair of triangles are opposite each other
				RedVal1, GreenVal1, BlueVal1 = unpack(childTriangle1.colour)
				RedVal2, GreenVal2, BlueVal2 = unpack(childTriangle2.colour)
				if RedVal1 == RedVal2 and GreenVal1 == GreenVal2 and BlueVal1 == BlueVal2 then 
					timer.performWithDelay(1, function()
						physics.removeBody(childTriangle1); physics.removeBody(childTriangle2)
					end)
					distance_between_triangles = math.floor(gameMath.find_distance(childTriangle1, childTriangle2))
					if childTriangle1.id == 'A' then 					
						transition.moveBy(childTriangle1, {time=500, y=distance_between_triangles, onComplete=fadeOutObj(childTriangle1, childTriangle2)})					
					elseif childTriangle2.id == 'A' then 
						transition.moveBy(childTriangle2, {time=500, y=distance_between_triangles, onComplete=fadeOutObj(childTriangle1, childTriangle2)})
					end
				end
			end
		end
	end

end

return class 