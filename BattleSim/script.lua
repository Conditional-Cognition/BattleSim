vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)

--// RESPIRATOR //--
-- grid keyed [pitch][yaw], all hand-verified connected poses
local grid = {
	[-45] = {
		[-45] = { seg1={42.5,0,0},  seg2={-27.5,0,-10}, seg3={-7.5,15,-27.5}, seg4={-27.5,-57.5,25} },
		[0]   = { seg1={40,0,0},    seg2={0,0,0},        seg3={0,0,0},         seg4={0,-15,0} },
		[45]  = { seg1={42.5,0,0},  seg2={12.5,0,27.5},  seg3={30,-35,-60},    seg4={-17.5,-32.5,25} }
	},
	[0] = {
		[-45] = { seg1={0,0,0}, seg2={-27.5,0,-10}, seg3={20,15,-27.5}, seg4={-27.5,5,5} },
		[0]   = { seg1={0,0,0}, seg2={0,0,0},        seg3={0,0,0},       seg4={0,0,0} },
		[45]  = { seg1={0,0,0}, seg2={20,0,17.5},    seg3={0,-22.5,0},   seg4={-15,2.5,0} }
	},
	[45] = {
		[-45] = { seg1={0,0,0},   seg2={-55,-12.5,-10}, seg3={20,15,-27.5}, seg4={-7.5,5,5} },
		[0]   = { seg1={-5,0,0},  seg2={-40,0,0},       seg3={37.5,0,0},    seg4={-25,-25,0} },
		[45]  = { seg1={0,0,0},   seg2={0,0,0},         seg3={0,-22.5,0},   seg4={0,25,-32.5} }
	}
}

-- pure pitch=90 extension (yaw ignored beyond here, fades out approaching straight up)
local pose90 = { seg1={-5,0,0}, seg2={-62.5,0,-12.5}, seg3={75,17.5,-75}, seg4={-12.5,-27.5,0} }

local pBands = {-45, 0, 45}
local yBands = {-45, 0, 45}
local PITCH_MIN = -45

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerpPose(a, b, t)
	local r = {}
	for _, name in ipairs({"seg1", "seg2", "seg3", "seg4"}) do
		r[name] = {
			lerp(a[name][1], b[name][1], t),
			lerp(a[name][2], b[name][2], t),
			lerp(a[name][3], b[name][3], t)
		}
	end
	return r
end

local function findBand(bands, v)
	for i = 1, #bands - 1 do
		if v >= bands[i] and v <= bands[i + 1] then
			return bands[i], bands[i + 1]
		end
	end
	return bands[1], bands[2]
end

local function bilinear(p, y)
	local p0, p1 = findBand(pBands, p)
	local y0, y1 = findBand(yBands, y)
	local fx = (p - p0) / (p1 - p0)
	local fy = (y - y0) / (y1 - y0)

	local c00, c10 = grid[p0][y0], grid[p1][y0]
	local c01, c11 = grid[p0][y1], grid[p1][y1]

	local top = lerpPose(c00, c10, fx)
	local bottom = lerpPose(c01, c11, fx)
	return lerpPose(top, bottom, fy)
end

function events.render()
	headRot = (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
	local x = headRot.x
	local y = math.max(-45, math.min(45, headRot.y))

	local visible = x >= PITCH_MIN
	models.model.Waist.Head.segment1.segment2:setVisible(visible)
	if not visible then
		return
	end

	local pose
	if x <= 45 then
		pose = bilinear(x, y)
	else
		-- beyond the grid's top edge: fade from the pitch=45 row toward the
		-- pure straight-up pose, since yaw stops mattering as you approach 90
		local row45 = bilinear(45, y)
		local t = math.min(1, (x - 45) / (90 - 45))
		pose = lerpPose(row45, pose90, t)
	end
	if InBattle == false then
		models.model.Waist.Head.segment1:setOffsetRot(pose.seg1[1], pose.seg1[2], pose.seg1[3])
		models.model.Waist.Head.segment1.segment2:setOffsetRot(pose.seg2[1], pose.seg2[2], pose.seg2[3])
		models.model.Waist.Head.segment1.segment2.segment3:setOffsetRot(pose.seg3[1], pose.seg3[2], pose.seg3[3])
		models.model.Waist.Head.segment1.segment2.segment3.segment4:setOffsetRot(pose.seg4[1], pose.seg4[2], pose.seg4[3])
	end
end
function events.render()
	local headRot = (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
	--host:setActionbar(string.format("pitch: %.1f  yaw: %.1f", headRot.x, headRot.y))
end