local class = {}
local screenSize = require( "libs.screenSize" )
local colours = require( "libs.colours" )
local gamemath = require( "classes.gameMath" )
local generateLaser = require( "classes.fireLaser" ).newlaser
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.newPrismPuzzle( levelparams )
	local currentlevel = levelparams
	local prismGroup = display.newGroup()
	local prismCoordinates = currentlevel.prismPuzzleDetails.prismCoordinates
	local prismVertices = currentlevel.prismPuzzleDetails.prismVertices
	local firing_prismId = currentlevel.prismPuzzleDetails.firingPrismId

	local function fireLaser()
		for i = 1, prismGroup.numChildren do
			if prismGroup[i].id == firing_prismId then
				generateLaser( prismGroup[i] )
			end 
		end 
	end

	local function prismCollisionListener( self, event )
		-- body
		local phase = event.phase

		if phase == 'began' then
			
			if event.other.type == 'circle' then
				print('prism has collided with circle', event.other.id)
				timer.performWithDelay(200, function() self.rotation = self.rotation + 90; print('prism current rotation:', self.rotation) end) 
				self.fill = event.other.colour 
				self.colour = event.other.colour 
				timer.performWithDelay(50, fireLaser() )
			end
		elseif phase == 'ended' then
			print('circle has ended collision with', event.other.type, event.other.id)
		end

	end

	for i = 1, currentlevel.prismPuzzleDetails.no_of_prisms do
		local prism = display.newPolygon(prismCoordinates[i].x, prismCoordinates[i].y, prismVertices)
		prism.id = i 
		prism.type = 'prism'
		prism.fill = colours.pearl.colour 
		prism.colour = colours.pearl.colour
		prismGroup:insert(prism)
		physics.addBody(prism, 'static', {density=0.3, bounce=0, friction=0.3, shape=prismVertices})
		prism.collision = prismCollisionListener
		prism:addEventListener('collision')
	end

	return prismGroup
end
return class 