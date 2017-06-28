local class = {}

function class.TransitionColour(displayObj, params)
	if displayObj and params and params.startColour and params.endColour then
	    local length = params.time or 300
	    local startTime = system.getTimer()
	    local redval, greenval, blueval
	    local easingFunc = params.transition or easing.linear

	    local function colourInterpolate(a,b,i,t)
	        colourTable = {
				easingFunc(i,t,a[1],b[1]-a[1]),
				easingFunc(i,t,a[2],b[2]-a[2]),
				easingFunc(i,t,a[3],b[3]-a[3]),
			}
			if(b[4] and a[4]) then
				easingFunc(i,t,a[4],b[4]-a[4])
			end
			
			return colourTable
	    end
	    
	    function runTransFunc(event)
			local runTime = system.getTimer()
	        if(startTime + length > runTime) then
	        	redval, greenval, blueval = unpack(colourInterpolate(params.startColour, params.endColour, runTime-startTime, length))
	        	if redval ~= nil and greenval ~= nil and blueval ~= nil and displayObj ~= nil then
	            	displayObj:setFillColor(redval, greenval, blueval)	            	
	      		end
	            -- do it one last time to make sure we have the correct final color
	            --displayObj:setFillColor(unpack(params.endColour)) 
	            
	        end
	    end
	    
	    Runtime:addEventListener("enterFrame", runTransFunc)
		--currentlevel.runTransFunc = runTransFunc
	end


end
return class