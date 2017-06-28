--load libs and classes
local class = {}
local screenSize = require( "libs.screenSize" )
local myApp = require( "libs.myapp" ) 
local colours = require( "libs.colours" )
-- forward declarations and other locals
local screenW, screenH, halfW, halfH = screenSize.screenW, screenSize.screenH, screenSize.halfW, screenSize.halfH

function class.loadText( guideTextTbl )
	-- body
	local textTbl = guideTextTbl
	local no_of_text, newText, continueText, textDisplayId
	local guideTextGroup = display.newGroup()
	local fontSize = 35
	--assign total no of guide text to a variale
	no_of_text = table.maxn(textTbl)
	--set first text to display to textTbl[1]
	textDisplayId = 1  
	newGuideText = display.newText( textTbl[textDisplayId].text, halfW, 0.065*screenH, 0.8*screenW, 0, myApp.fontBold, fontSize) ; print(newGuideText.text)
	newGuideText.fill = colours.pearl.colour 

	if no_of_text > 1 then
		--create a text that informs user that tapping on text will generate the next text
		continueText = display.newText( 'tap to continue', halfW-50, newGuideText.y+60, myApp.fontBold, fontSize)
		--continueText.isVisible = false
	else
		continueText = display.newText( '', halfW-50, newGuideText.y+60, myApp.fontBold, fontSize)
	end
	continueText.fill = colours.pearl.colour 

	function newGuideText:touch(event)
		local phase = event.phase
		local stage = display.getCurrentStage()

		if phase == "began" then
			stage:setFocus(self)
			self.isFocus = true
		elseif self.isFocus then
			if phase == "ended" then
				if no_of_text > 1 then 
					if textDisplayId < no_of_text then --ensure if textdisplayid is pointing to last set of text, this code will not run
						textDisplayId = textDisplayId + 1
						newGuideText.text = textTbl[textDisplayId].text
					elseif textDisplayId == no_of_text then
						print('text displayed is last set of guide text')
																		
					end 
				else
							
				end
				stage:setFocus(nil)
        		self.isFocus = false
        	end
        end   
        return true     
	end

	newGuideText:addEventListener( "touch", newGuideText )

	guideTextGroup:insert(newGuideText)
	guideTextGroup:insert(continueText)

	return guideTextGroup
end
return class 