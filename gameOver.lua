local composer = require "composer"
local sceneName = ...
local scene = composer.newScene(sceneName)

local widget = require "widget"

local w = display.contentCenterX
local h = display.contentCenterY
local w_ = display.contentWidth
local h_ = display.contentHeight

function buttonHandler(event)
	if(event.phase == "began")then
		composer.gotoScene("game", {effect = "fade", time = 300})
	end
end

function scene:create(event)
	local sceneGroup = self.view
	local againButton = widget.newButton{
         label = "Again",
         font = "AbrilFatface-Regular",
         fontSize = 20,
         labelColor = {default = {1,0,0}, over = {1,0,0,0.5}},
         onEvent = buttonHandler
    }
   

    againButton.x = w_- 25
    againButton.y = h_-25

    sceneGroup:insert(againButton)
end
function scene:show(event)
	local sceneGroup = self.view
	if(event.phase == "will")then

	elseif(event.phase == "did")then

	end
end
function scene:hide(event)
	local sceneGroup = self.view
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