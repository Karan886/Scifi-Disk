local composer = require "composer"
local scene = composer.newScene()

local w = display.contentCenterX
local h = display.contentCenterY
local w_ = display.contentWidth
local h_ = display.contentHeight

function scene:create(event)
	local sceneGroup = self.view
end
function scene:show(event)
	local sceneGroup = display.newScene()
	if(event.phase == "will")then

	elseif(event.phase == "did")then

	end
end
function scene:hide(event)
	local sceneGroup = display.newScene()
	if(event.phase == "will")then

	elseif(event.phase == "did")then

	end
end
function scene:destroy(event)
	local sceneGroup = self.view
end
scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
scene:addEventListener("destroy",scene)
return scene