--this class contains various math functions that is used throughout the game
local class = {}
-- required libs to be loaded
local myApp = require( "libs.myapp" )
--local newRandNum = require( "classes.GenerateRandNum" ).generateRandNum

local function find_midPoint( x1, y1, x2, y2 )
	local midpt
	if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
		local midpt_x = math.floor( (x1+x2)/2 ) 
		local midpt_y = math.floor( (y1+y2)/2 )
		midpt = {x = midpt_x, y = midpt_y}
	else
		print('nil values found in paramters')
	end
	return midpt
end

function class.roundNum(num, idp)
  		local mult = 10^(idp or 0)
  	return math.floor(num * mult + 0.5) / mult
end

function class.find_distance( point1, point2 )
	local distance
	if point1.x ~= nil and point1.y ~= nil and point2.x ~= nil and point2.y ~= nil then
		local dx = point2.x - point1.x
		local dy = point2.y - point1.y 
		distance = math.floor( math.sqrt((dx*dx) + (dy*dy)) )
		--print('dx', dx, 'dy', dy, distance)
	else
		print('nil values found in paramters')	
	end
	return distance
end

function class.convertAngle( angle )
	--this converts angles in radians to degrees	
	local conversionFactor = 180/math.pi 
	local convertedAngle = angle*conversionFactor
	return convertedAngle
end

return class