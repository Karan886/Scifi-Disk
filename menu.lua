local composer = require "composer"
local scene = composer.newScene(...)
local background = require "background"


local w = display.contentCenterX
local h = display.contentCenterY
local w_ = display.contentWidth
local h_ = display.contentHeight

local flashTimer
local text

function scene:create(event)
	local sceneGroup = self.view
	--images
	sky_bg = display.newImage("images/sky.png",w,h)
	cloud1_bg = display.newImage("images/sky_01.png",w,h)
	cloud2_bg = display.newImage("images/sky_03.png",w_*2,h)
	
	text = display.newText("tap anywhere to start",w,h-10,"AbrilFatface-Regular",25)
	text:setFillColor(0.21,0.20,0.38)
	
	--add elements to scene group

	
	sceneGroup:insert(sky_bg)
	sceneGroup:insert(cloud1_bg)
	sceneGroup:insert(cloud2_bg)
	sceneGroup:insert(text)

end
function checkEveryFrame()
	background.scroll(cloud1_bg,2,-50)
	background.scroll(cloud2_bg,2,-50)
	
end

function onScreenTapped()
	composer.gotoScene("game",{effect = "fade",time = 300})
end

function flashText(object)
	flashTimer = timer.performWithDelay(500,function()
		if(object.isVisible == false )then
			object.isVisible = true
		else
			object.isVisible = false 
		end
	end,0)
end
function scene:show(event)
	local sceneGroup = self.view
	if(event.phase == "will")then

	elseif(event.phase == "did")then
		flashText(text)
		Runtime:addEventListener("tap",onScreenTapped)
		Runtime:addEventListener("enterFrame",checkEveryFrame)
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	if(event.phase == "will")then
		timer.cancel(flashTimer)
		Runtime:removeEventListener("tap",onScreenTapped)
		Runtime:removeEventListener("enterFrame",checkEveryFrame)
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