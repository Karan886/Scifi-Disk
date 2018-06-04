local composer = require "composer"
local sceneName = ...
local scene = composer.newScene(sceneName)

local w = display.contentCenterX
local h = display.contentCenterY
local w_ = display.contentWidth
local h_ = display.contentHeight

local physics = require("physics")
physics.start()
physics.setDrawMode("normal")

--table stores graphics for different elements of the game - allows for randomization of elements
local platforms_big = {"images/platform_01.png"}
local platforms_small = {"images/platform_03.png"}
local bricks = {"images/platform_02.png"}
local props = {"images/medicalKit.png"}

--bin collects elements to remove during screen cleanup
local bin = {}
local t

--bounce mechanism
local bounceCount = 0
local bounceTimer = 4
local bounceState = false 

--ground boundary that detects when disk falls offscreen on the bottom
local bottomWall

local shift = 20

--cleans up/ removes elements on the screen
function cleanUp()
	for i=1,#bin do
		display.remove(bin[i])
	end
end

function gameOver()
	composer.gotoScene("gameOver",{effect = "fade", time = 300})
end



function resetBounceState()
	bounceTimer = 4
	bounceState = false
	bounceCount = 0
	shift = 20
	bounceTimer_text.alpha = 0
	bounceCount_text.alpha = 0
end

--function controls bounce mechanism
function bounce()
	if(bounceState)then
		if(bounceTimer == 0 and bounceState)then
			resetBounceState()
		else
			bounceTimer = bounceTimer - 1
			bounceTimer_text.alpha = 0.7
			bounceTimer_text.text = "0:0"..bounceTimer
		end
	end
end

--function handles collision between different game objects/elements
function coll(event)
	if(event.phase == "began")then
		--all platforms remove itself once it hits offscreen wall
		if((event.target.name == "platform" or "collRect" or "floater" or "medical") and event.other.name == "wall")then
			display.remove(event.target)
		--game over state
		elseif(event.target.name == "player" and (event.other.name == "collRect" or event.other.name == "bottomwall"))then
			physics.pause()
			timer.cancel(startBounce)
		    t = timer.performWithDelay(2000,gameOver,1)

		elseif(event.target.name == "player" and event.other.name == "platform")then
			vx,vy = event.target:getLinearVelocity()
			if(vy>80.0 and bounceState == false)then
				bounceState = true
			end
			if(bounceState and bounceCount <= 3)then
				bounceCount = bounceCount+1
				bounceCount_text.alpha = 0.5
				if(shift < -10)then
					shift = -20
				else
					shift = shift - 10
				end

				if(bounceCount == 3)then
					transition.to(force,{time = 200, width = 29*4})
					resetBounceState()
				end
			end
		elseif(event.target.name == "player" and event.other.name == "medical")then
			if(force.width > 29*3)then
				transition.to(force,{time = 200, width = 29*4})
			else
				transition.to(force,{time = 200, width = force.width+29})
			end
			display.remove(event.other)
		end
	end
end
--paralax scroll
function scroll(object,speed,limit)
	local max = (object.width/2)*-1
	if(object.x < max+limit)then
		object.x = w_*2
	else
		object.x = object.x - speed
	end
end

function createPlatforms()

	local alphaValue = 0
	local offset = 4.5
	local velocity = -65.0

	local platform = display.newImage(platforms_big[math.random(1,#platforms_big)],w_+150,h_-20)
	platform.name = "platform"
	physics.addBody(platform,"kinematic", {density = 0.5, bounce = 1.0})
	platform.isFixedRotation = true
	platform:setLinearVelocity(velocity,0)

	local collRect = display.newRect(platform.x - (platform.width/2),platform.y + offset,3,platform.height)
	collRect.name = "collRect"
	collRect.isFixedRotation = true
	physics.addBody(collRect,"kinematic", {density = 0.5})
	collRect:setLinearVelocity(velocity,0)
	collRect.alpha = alphaValue
	collRect:addEventListener("collision",coll)

	local platform2 = display.newImage(platforms_small[math.random(1,#platforms_small)],platform.x+math.random(150,450),h_-20)
	platform2.name = "platform"
	physics.addBody(platform2,"kinematic", {density = 0.5, bounce = 1.0})
	platform2.isFixedRotation = true
	platform2:setLinearVelocity(velocity,0)

	local collRect2 = display.newRect(platform2.x - (platform2.width/2),platform2.y + offset,3,platform2.height)
	collRect2.name = "collRect"
	collRect2.isFixedRotation = true
	physics.addBody(collRect2,"kinematic", {density = 0.5})
	collRect2:setLinearVelocity(velocity,0)
	collRect2.alpha = alphaValue
	collRect2:addEventListener("collision",coll)

	local brick = display.newImage(bricks[math.random(1,#bricks)],platform2.x + 200, h_-20)
	brick.name = "platform"
	physics.addBody(brick, "kinematic", {density = 0.5, bounce = 1.0})
	brick.isFixedRotation = true
	brick:setLinearVelocity(velocity,0)

	local collRect3 = display.newRect(brick.x - (brick.width/2),brick.y + offset,3,brick.height)
	collRect3.name = "collRect"
	collRect3.isFixedRotation = true
	physics.addBody(collRect3,"kinematic", {density = 0.5})
	collRect3:setLinearVelocity(velocity,0)
	collRect3.alpha = alphaValue
	collRect3:addEventListener("collision",coll)

	local weldJoint = physics.newJoint("weld",platform,platform2,platform.x,platform.y)
	local weldJoint2 = physics.newJoint("weld",platform2,brick,platform2.x,platform2.y)

	bin[#bin+1] = platform2
	bin[#bin+1] = platform
	bin[#bin+1] = brick
	bin[#bin+1] = collRect
	bin[#bin+1] = collRect2
	bin[#bin+1] = collRect3
	bin[#bin+1] = weldJoint
	bin[#bin+1] = weldJoint2

	platform2:addEventListener("collision",coll)
	platform:addEventListener("collision",coll)
	brick:addEventListener("collision",coll)
end
--floaters are floating platforms
function createFloaters()
	local width = 26
	local velocity = -50.0
	local currSize = math.random(1,3)
	local first
	local floater
	local pos = math.random(120,200)
	for i=0,currSize do

		floater = display.newImage("images/floatingBrick.png",(w_+57)+(width*i),pos)
		floater.name = "floater"
		physics.addBody(floater, "kinematic", {density = 0.5, bounce = 0.8})
		floater:setLinearVelocity(velocity,0)
		floater:addEventListener("collision",coll)

		if(i == 0)then
			first = floater
		end

		bin[#bin+1] = floater
	end

	local frontColl = display.newRect(first.x - (first.width/2) - 0.5,first.y,2,first.height-4.0)
	frontColl.alpha = 0
	frontColl.name = "collRect"
	physics.addBody(frontColl, "kinematic", {density = 0.5})
	frontColl:setLinearVelocity(velocity,0)
	bin[#bin+1] = frontColl

	local rand = math.random(1,2)
	local item

	if(rand == 2 )then
	    item = display.newImage(props[1],floater.x,floater.y - 18)
	    physics.addBody(item, "kinematic", {density = 0.5, isSenspr = true})
		item.name = "medical"
		item:setLinearVelocity(velocity,0)
		bin[#bin+1] = item
	end
end

function playerTouch(e)
	if(force.width > 0)then
		player:applyLinearImpulse(0,-3.0)
		transition.to(force,{time = 100, width = force.width - (29/2)})
		if(force.width < (29/2))then
			force.width = 0
		end
	else
		force.width = 0
	end
end


function scene:create(event)
	local sceneGroup = self.view
	local sky = display.newImage("images/sky.png",w,h)

	cloud1 = display.newImage("images/sky_01.png",w,h)
	cloud2 = display.newImage("images/sky_03.png",w_*2,h)

	bg1 = display.newImage("images/bg1.png",w,h+20)
	bg2 = display.newImage("images/bg2.png",w_+70,h+20)
	bg3 = display.newImage("images/bg3.png",(w_+70)*2,h+20)

	player = display.newImage("images/disk.png",w,h)
	player.name = "player"

	wall = display.newRect(-210,h,10,h_)
	wall.name = "wall"

	bounceTimer_text = display.newText("0:03",w,h,"AbrilFatface-Regular",16)
	bounceTimer_text:setFillColor(1,0,0)
	bounceTimer_text.alpha = 0

	bounceCount_text = display.newCircle(w-2,player.y+50,5)
	bounceCount_text:setFillColor(0,1,0)
	bounceCount_text.alpha = 0
    
    --detect player falling offscreen
	bottomWall = display.newRect(w,h_+45,w_+45,5);
	bottomWall.name = "bottomwall"
	
	createPlatforms()

	--force is the fuel/health of the disk
	force = display.newRect(w-256,h-145,29*4,10)
	force:setFillColor(0,0,1,0.5)
	force.anchorX = 0

	sceneGroup:insert(sky)
	sceneGroup:insert(cloud1)
	sceneGroup:insert(cloud2)
	sceneGroup:insert(bg1)
	sceneGroup:insert(bg2)
	sceneGroup:insert(bg3)
	sceneGroup:insert(player)
	sceneGroup:insert(wall)
	sceneGroup:insert(bounceTimer_text)
	sceneGroup:insert(bounceCount_text)
	sceneGroup:insert(force)
	sceneGroup:insert(bottomWall)

	for i=1,4 do
		--force bar is the frame that holds force.
		local forceBar = display.newImage("images/forceBar.png",(w-270)+(29*i),h-145)
		sceneGroup:insert(forceBar)
	end
	

end
--this function is called iteratively every few frames
function checkFrame()
	scroll(cloud1,2,-50)
	scroll(cloud2,2,-50)
	scroll(bg1,1,-10)
	scroll(bg2,1,-10)
	scroll(bg3,1,-10)
	--fix player at center of screen
	player.x = w
	bounceTimer_text.y = player.y - 50
	bounceCount_text.y, bounceCount_text.x = player.y + 30,player.x-shift
end

function scene:show(event)
	local sceneGroup = self.view
	if(event.phase == "will")then
		spawnPlatforms = timer.performWithDelay(18000,createPlatforms,0)
		spawnFloaters = timer.performWithDelay(10000,createFloaters,0)
		startBounce = timer.performWithDelay(1000,bounce,0)

		physics.addBody(wall, {isSensor = true})
		wall.gravityScale = 0

		physics.addBody(player, {density = 0.2, radius = 21})
		physics.addBody(bottomWall,"static")

	elseif(event.phase == "did")then
		Runtime:addEventListener("enterFrame",checkFrame)
		Runtime:addEventListener("tap",playerTouch)
		player:addEventListener("collision", coll)
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	if(event.phase == "will")then
		timer.cancel(spawnPlatforms)
		timer.cancel(spawnFloaters)
		timer.cancel(t)
		cleanUp()
	elseif(event.phase == "did")then
		Runtime:removeEventListener("enterFrame",checkFrame)
		Runtime:removeEventListener("tap",playerTouch)
		player:removeEventListener("collision", coll)
		composer.removeHidden()
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