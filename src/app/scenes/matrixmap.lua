-- 地图模块

import(".utilfunctions")

local MatrixMap = class("MatrixMap")

function MatrixMap:ctor()
	self.tempMatrix = {}  -- 用于初始化矩矩阵的预判
	self.availPos = {}  -- 可以放精灵的位置
	self.startB  = {31, 16,  2,  7,  3,  8,  4, 19, 35} -- 每一列最低点精灵位置
	self.startLB = {62, 46, 31, 26, 16, 12,  2,  3, 4}  -- 每一左斜线最低点精灵位置
	self.startRB = {64, 49, 35, 29, 19, 14,  4,  3, 2}  -- 每一右斜线最低点精灵位置
	self.startT  = {31, 46, 62, 57, 63, 58, 64, 49, 35} -- 每一列最高点精灵位置
	self.oddDirectArray = {10, 5, -5, -10, -6, 4}    -- 奇数方向数组
	self.evenDirectArray = {10, 6, -4, -10, -5, 5}   -- 偶数方向数组

	-- 记录每个Pokemon的六个方位的Id
	self.neighbor = {
		top         = {},
		rightTop    = {},
		rightBottom = {},
		bottom      = {},
		leftBottom  = {},
		leftTop     = {}
		
	}
end

function MatrixMap:init()
	self.availPos[31], self.availPos[35] = true, true
	for i = 2, 8, 1 do
		for j = self.startB[i], 65, 10 do
			self.availPos[j] = true
		end
	end
	self.availPos[56], self.availPos[59] = nil, nil

	for id, _ in pairs(self.availPos) do
		-- 初始化所有可利用的点的六个方位
		local directionArray = self:getDirectArray(getXY(id))
		self.neighbor.top[id] = directionArray[1] + id
		self.neighbor.rightTop[id] = directionArray[2] + id
		self.neighbor.rightBottom[id] = directionArray[3] + id
		self.neighbor.bottom[id] = directionArray[4] + id
		self.neighbor.leftBottom[id] = directionArray[5] + id
		self.neighbor.leftTop[id] = directionArray[6] + id
	end
	-- body
end

-- 根据y坐标的奇偶性获取方向数组
function MatrixMap:getDirectArray(P)
	if (P.y % 2 == 0) then return self.evenDirectArray
	else return self.oddDirectArray end
end

return MatrixMap