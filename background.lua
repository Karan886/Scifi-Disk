local table = {}

--measurements
local w = display.contentCenterX
local h = display.contentCenterY
local w_ = display.contentWidth
local h_ = display.contentHeight

function table.scroll(object,speed,limit)
	local max = (object.width/2)*-1
	if(object.x < max+limit)then
		object.x = w_*2
	else
		object.x = object.x - speed
	end
end


return table