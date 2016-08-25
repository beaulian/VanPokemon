Pokemon = import(".Pokemon")
MatrixMap = import(".matrixmap")
import(".setting")

-- 实例化地图
map = MatrixMap.new()

local PlayScene = class("PlayScene", function()
	return display.newScene("PlayScene")
end)

-- 返回true表示可以消除
function PlayScene:isValidAndSame(...)
	local vecs = {...}
	for i = 2, #vecs do
		-- print( "vecs = " .. vecs[i])
		if self.matrix[vecs[i]].pokemonIndex ~= self.matrix[vecs[1]].pokemonIndex then 
			return false
		end
	end
	return true
	-- body
end

-- 返回true表示可以消除（不合法）
function PlayScene:isValidAndSameForTemp(...)
	local vecs = {...}
	if map.tempMatrix[vecs[1]] == nil then return false end
	for i = 2, #vecs do
		if map.tempMatrix[vecs[i]] == nil then return false end
		if map.tempMatrix[vecs[i]] ~= map.tempMatrix[vecs[1]] then 
			return false
		end
	end
	return true
	-- body
end
-- 判断是否有可消除的情况
function PlayScene:checkAvailableVan(id, isinitial)
	local isinitial = isinitial
	local id = id

	-- 闭包函数
	local check = function(id_1, id_2)
		-- 如果是Pokemon最开始掉落的时候
		if(isinitial) then
			return map.tempMatrix[id_1] and map.tempMatrix[id_2] and self:isValidAndSameForTemp(id, id_1, id_2)
		-- 否则
		else
			return map.availPos[id_1] and map.availPos[id_2] and self:isValidAndSame(id, id_1, id_2)
		end
	end

	-- 检测圆
	local check_circle = function(id_1, id_2, id_3, id_4, id_5, id_6)
		if(isinitial) then
			return map.tempMatrix[id_1] and map.tempMatrix[id_2] and 
			       map.tempMatrix[id_3] and map.tempMatrix[id_4] and
			       map.tempMatrix[id_5] and map.tempMatrix[id_6] and 
			       self:isValidAndSameForTemp(id_1, id_2, id_3, id_4, id_5, id_6)
		else
			return map.availPos[id_1] and map.availPos[id_2] and 
			       map.availPos[id_3] and map.availPos[id_4] and
			       map.availPos[id_5] and map.availPos[id_6] and
			       self:isValidAndSame(id_1, id_2, id_3, id_4, id_5, id_6)
		end
	end

	return {
		-- 斜率为负
		checkLS = check(map.neighbor.leftTop[id], map.neighbor.rightBottom[id]),
		-- 斜率为正
		checkRS = check(map.neighbor.rightTop[id], map.neighbor.leftBottom[id]),
		checkCol = check(map.neighbor.top[id], map.neighbor.bottom[id]),
		checkCircle = check_circle(map.neighbor.top[id], map.neighbor.rightTop[id],
							map.neighbor.rightBottom[id], map.neighbor.bottom[id],
							map.neighbor.leftBottom[id], map.neighbor.leftTop[id]) 
	}
end


-- 检测以id开始的正斜线是否可以消除
function PlayScene:checkPosLine(id)
	local cnt, max = 0, 0
	local startid, endid = id, id
	while map.availPos[endid] do
		if self.matrix[endid].pokemonIndex == self.matrix[startid].pokemonIndex then
			cnt = cnt + 1
		else 
			cnt, startid = 1, endid
		end
		endid = map.neighbor.rightTop[endid]
		max = math.max(max, cnt)
		--todo
	end
	return max > 3
	-- body
end
-- 检测以id开始的负斜线是否可以消除
function PlayScene:checkNegLine(id)
	local cnt, max = 0, 0
	local startid, endid = id, id
	while map.availPos[endid] do
		if self.matrix[endid].pokemonIndex == self.matrix[startid].pokemonIndex then
			cnt = cnt + 1
		else 
			cnt, startid = 1, endid
		end
		endid = map.neighbor.leftTop[endid]
		max = math.max(max, cnt)
		--todo
	end
	return max > 3
	-- body
end
-- 检测以id开始的竖线是否可以消除
function PlayScene:checkColLine(id)
	local cnt, max = 0, 0
	local startid, endid = id, id
	while map.availPos[endid] do
		if self.matrix[endid].pokemonIndex == self.matrix[startid].pokemonIndex then
			cnt = cnt + 1
		else 
			cnt, startid = 1, endid
		end
		endid = map.neighbor.top[endid]
		max = math.max(max, cnt)
		--todo
	end
	return max > 3
	-- body
end
-- 添加以id开始的正斜线到消除列表
function PlayScene:addRemovePosLine(id)
	repeat
		self.actives[id] = true
		id = map.neighbor.rightTop[id]
		--todo
	until not map.availPos[id]
	-- body
end
-- 添加以id开始的负斜线到消除列表
function PlayScene:addRemoveNegLine(id)
	repeat
		self.actives[id] = true
		id = map.neighbor.leftTop[id]
		--todo
	until not map.availPos[id]
	-- body
end
-- 添加以id开始的竖线到消除列表
function PlayScene:addRemoveColLine(id)
	repeat
		self.actives[id] = true
		id = map.neighbor.top[id]
		--todo
	until not map.availPos[id]
	-- body
end
-- 扫描该点是否可以消除
function PlayScene:scanItem(id, isinitial)
	if(map.availPos[id] == nil) then return false end
	local f = false
	-- 初始化判断
	local check = self:checkAvailableVan(id, isinitial)

	-- 判断斜率为负的斜线
	if check.checkLS then 
		if not isinitial then 
			self.actives[id] = true
			self.actives[map.neighbor.leftTop[id]] = true
			self.actives[map.neighbor.rightBottom[id]] = true
		end
		f = true
	end
	-- 判断斜率为正的斜线
	if check.checkRS then 
		if not isinitial then 
			self.actives[id] = true 
			self.actives[map.neighbor.rightTop[id]] = true 
			self.actives[map.neighbor.leftBottom[id]] = true
		end
		f = true
	end
	-- 判断竖线
	if check.checkCol then 
		if not isinitial then 
			self.actives[id] = true
			self.actives[map.neighbor.top[id]] = true 
			self.actives[map.neighbor.bottom[id]] = true
		end
		f = true
	end
	-- 判断一个圆环
	if check.checkCircle then
		if not isinitial then
			self.actives[map.neighbor.top[id]] = true
			self.actives[map.neighbor.rightTop[id]] = true
			self.actives[map.neighbor.rightBottom[id]] = true
			self.actives[map.neighbor.bottom[id]] = true
			self.actives[map.neighbor.leftBottom[id]] = true
			self.actives[map.neighbor.leftTop[id]] = true
		end
		f = true
	end
	return f
	-- body
end

-- 扫描全部是否可以消除
function PlayScene:scanAll()
	local f = false
	for i, _ in pairs(map.availPos) do
		if self:scanItem(i) then
			f = true 
		end
	end
	-- 超过4个消一条直线
	if f then
		local removePos, removeNeg, removeCol = {}, {}, {}
		-- 检测
		-- 斜率为正的斜线
		for _, id in pairs(map.startLB) do
			if self:checkPosLine(id) then removePos[id] = true end
		end
		-- 斜率为负的斜线
		for _, id in pairs(map.startRB) do
			if self:checkNegLine(id) then removeNeg[id] = true end
		end
		-- 竖线
		for _, id in pairs(map.startB) do
			if self:checkColLine(id) then removeCol[id] = true end
		end
		-- 添加消除列表
		-- 斜率为正的斜线
		for id, _ in pairs(removePos) do
			self:addRemovePosLine(id)
		end
		-- 斜率为负的斜线
		for id, _ in pairs(removeNeg) do
			self:addRemoveNegLine(id)
		end
		-- 竖线
		for id, _ in pairs(removeCol) do
			self:addRemoveColLine(id)
		end
	end
	return f
end

function PlayScene:ctor()

	-- 初始化地图
	map:init()

	-- 注册事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    	self.allActionEnded = true
    	-- print(self.allActionEnded)
    	for id, _ in pairs(map.availPos) do
    		if self.matrix[id]:getNumberOfRunningActions() > 0 then 
    			self.allActionEnded = false
    			break
    		end
    	end
    	if self.allActionEnded then
	 		self.actives = {}
			self:scanAll()
    		self:removeActivedPokemons()
	 		self:dropPokemons()
    	end
    end)

	-- init value
	self.highSorce = cc.UserDefault:getInstance():getIntegerForKey("HighScore") -- 最高分数
	self.stage = cc.UserDefault:getInstance():getIntegerForKey("Stage") -- 当前关卡
	if self.stage == 0 then self.stage = 1 end
	self.target = self.stage * 200 -- 通关分数

	self.allActionEnded = true
	self.curSorce = 0 -- 当前分数
	self.xCount = 5 -- 水平方向水果数
	self.yCount = 13 -- 垂直方向水果数
	self.PokemonGap = 10 -- 水果间距
	self.scoreStart = 5 -- 水果基分
	self.scoreStep = 10 -- 加成分数
	self.activeScore = 0 -- 当前高亮的水果得分
	self.callInterval = false

	self.swapx = -1
	self.swapy = -1
	self:initUI()

	-- 初始化随机数
	math.newrandomseed()

	--  计算水果矩阵左下角的x、y坐标：以矩阵中点对齐屏幕中点来计算，然后再做Y轴修正。
	self.matrixLBX = (display.width - Pokemon.getWidth() * self.xCount - (self.yCount - 1) * self.PokemonGap) / 2 - 40
	self.matrixLBY = (display.height - Pokemon.getWidth() * self.yCount - (self.xCount - 1) * self.PokemonGap) / 2 + 167

	-- 等待转场特效结束后再加载矩阵
	self:addNodeEventListener(cc.NODE_EVENT, function(event)
		if event.name == "enterTransitionFinish" then
			self:initMartix()
		end
	end)

	audio.playMusic("music/mainbg.mp3", true)
end

function PlayScene:initUI()
	-- 背景图片
	display.newSprite("playBG.png")
		:pos(display.cx, display.cy)
		:addTo(self)

	-- high sorce
	display.newSprite("#high_score.png")
		:align(display.LEFT_CENTER, display.left + 15, display.top - 30)
		:addTo(self)

	display.newSprite("#highscore_part.png")
		:align(display.LEFT_CENTER, display.cx + 10, display.top - 26)
		:addTo(self)

	self.highSorceLabel = cc.ui.UILabel.new({UILabelType = 1, text = tostring(self.highSorce), font = "font/earth38.fnt"})
		:align(display.CENTER, display.cx + 105, display.top - 24)
		:addTo(self)
	
	-- 声音
	display.newSprite("#sound.png")
		:align(display.CENTER, display.right - 60, display.top - 30)
		:addTo(self)

	-- stage
	display.newSprite("#stage.png")
		:align(display.LEFT_CENTER, display.left + 15, display.top - 80)
		:addTo(self)

	display.newSprite("#stage_part.png")
		:align(display.LEFT_CENTER, display.left + 170, display.top - 80)
		:addTo(self)

	self.highStageLabel = cc.ui.UILabel.new({UILabelType = 1, text = tostring(self.stage), font = "font/earth32.fnt"})
		:align(display.CENTER, display.left + 214, display.top - 78)
        :addTo(self)
	
	-- target
	display.newSprite("#tarcet.png")
		:align(display.LEFT_CENTER, display.cx - 50, display.top - 80)
		:addTo(self)

	display.newSprite("#tarcet_part.png")
		:align(display.LEFT_CENTER, display.cx + 130, display.top - 78)
		:addTo(self)

	self.highTargetLabel = cc.ui.UILabel.new({UILabelType = 1, text = tostring(self.target), font = "font/earth32.fnt"})
		:align(display.CENTER, display.cx + 195, display.top - 76)
        :addTo(self)

	-- current sorce
	display.newSprite("#score_now.png")
		:align(display.CENTER, display.cx, display.top - 150)
		:addTo(self)

	self.curSorceLabel = cc.ui.UILabel.new({UILabelType = 1, text = tostring(self.curSorce), font = "font/earth48.fnt"})
		:align(display.CENTER, display.cx, display.top - 150)
        :addTo(self)
	
	-- 选中水果分数
	self.activeScoreLabel = display.newTTFLabel({text = "", size = 30})
		:pos(display.width / 2, 120)
		:addTo(self)
	self.activeScoreLabel:setColor(display.COLOR_WHITE)

	-- 进度条
	local sliderImages = {
        bar = "#The_time_axis_Tunnel.png",
        button = "#The_time_axis_Trolley.png",
    }

 --    self.silderBar = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, sliderImages, {scale9 = false})
 --        :setSliderSize(display.width, 125) -- 设置滑动条大小
 --        :setSliderValue(0) --设置滑动控件的取值
 --        :align(display.LEFT_BOTTOM, 0, 0) -- 指定对齐方式和坐标
 --        :addTo(self)
	-- self.silderBar:setTouchEnabled(false)
end


function PlayScene:initMartix()
	-- 创建空矩阵
	self.matrix = {}
	-- 高亮水果
	self.actives = {}
	-- 初始化水果，一开始不能直接消除
	for id, _ in pairs(map.availPos) do

		-- 先尝试随机生成一个Pokemon
		local value = math.round(math.random() * 1000) % 5 + 1
		repeat
			map.tempMatrix[id] = value
			value = value + 1
			if value > 5 then value = value - 5 end
		-- 判断是否这个Pokemeon对整个地图合法
		until not self:scanItem(map.neighbor.leftBottom[id], 1) 
			  and not self:scanItem(map.neighbor.bottom[id], 1) 
			  and not self:scanItem(map.neighbor.rightBottom[id], 1)
	end
	-- 根据tempMatrix创建真正的Pokemon地图
	for id, _ in pairs(map.availPos) do
		local Point = getXY(id)
		self:createAndDropPokemon(Point.x, Point.y, map.tempMatrix[id])
	end
	-- 启用帧事件
	self:scheduleUpdate()
end

function PlayScene:createAndDropPokemon(x, y, pokemonIndex)
	-- print('x = ' .. x, 'y = ' .. y, 'id = ' .. getID(x, y))
    local newPokemon = Pokemon.new(x, y, getID(x, y), pokemonIndex)
    local endPosition = self:positionOfPokemon(x, y)
    local startPosition = cc.p(endPosition.x, endPosition.y + display.height / 2)
    newPokemon:setPosition(startPosition)
    self.matrix[getID(x, y)] = newPokemon
    self:addChild(newPokemon)

	local speed = startPosition.y / (2 * display.height) + 0.5
    newPokemon:runAction(cc.MoveTo:create(speed, endPosition))

	-- 绑定触摸事件
	newPokemon:setTouchEnabled(true)
	newPokemon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

		if event.name == "ended" then
			if self.swapx == -1 and self.swapy == -1 then 
				self.actives = {}
				return false
			end
			newPokemon.begx = -1
			newPokemon.begy = -1
			print('ended')

			self:checkNextStage()
			self.swapx, self.swapy = -1, -1
		end

		if event.name == 'moved' then
			if newPokemon.begx ~= -1 then
				local mx = event.x - newPokemon.begx
				local my = event.y - newPokemon.begy
				local d = math.atan2(my,mx)
				if mx^2 + my^2 > 1600 then
					if d >= 0 and d < PI/3 then
						if not map.availPos[map.neighbor.rightTop[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.rightTop[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.rightTop[newPokemon.id]].y
					elseif d >= PI/3 and d < 2*PI/3 then
						if not map.availPos[map.neighbor.top[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.top[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.top[newPokemon.id]].y
					elseif d >= 2*PI/3 and d <= PI then
						if not map.availPos[map.neighbor.leftTop[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.leftTop[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.leftTop[newPokemon.id]].y
					elseif d < 0 and d >= -PI/3 then
						if not map.availPos[map.neighbor.rightBottom[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.rightBottom[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.rightBottom[newPokemon.id]].y
					elseif d < -PI/3 and d >= -PI*2/3 then
						if not map.availPos[map.neighbor.bottom[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.bottom[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.bottom[newPokemon.id]].y
					elseif d < -PI*2/3 and d >= -PI then
						if not map.availPos[map.neighbor.leftBottom[newPokemon.id]] then
							return false
						end
						self.swapx = self.matrix[map.neighbor.leftBottom[newPokemon.id]].x
						self.swapy = self.matrix[map.neighbor.leftBottom[newPokemon.id]].y
					end
					print('swap:', newPokemon.x,newPokemon.y,self.swapx,self.swapy)
					self:itemSwap(newPokemon.x,newPokemon.y,self.swapx,self.swapy)
					if self:scanAll() then
						print('swap')
						self:swapAction(newPokemon.x,newPokemon.y,self.swapx,self.swapy)
					else
						print('reswap:',newPokemon.x,newPokemon.y,self.swapx,self.swapy)
						self:itemSwap(newPokemon.x,newPokemon.y,self.swapx,self.swapy)

						print('aft_reswap:',newPokemon.x,newPokemon.y,self.swapx,self.swapy)
						self:reswapAction(newPokemon.x,newPokemon.y,self.swapx,self.swapy)
					end
					newPokemon.begx = -1
					newPokemon.begy = -1
					return false
				else
					return true
				end
			end
		end

		if event.name == "began" and self.allActionEnded then
			newPokemon.begx = event.x
			newPokemon.begy = event.y
			return true
		end
	end)
end

function PlayScene:removeActivedPokemons()
	local PokemonScore = self.scoreStart
	for idx in pairs(self.actives) do
		local temp = self.matrix[idx]
		if (temp) then
			-- 从矩阵中移除
			self.matrix[idx] = nil

			local time = 0.1;
			-- 爆炸圈
			local circleSprite = display.newSprite("circle.png")
				:pos(temp:getPosition())
				:addTo(self)
			circleSprite:setScale(0)
			circleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(time, 0.2),
					cc.CallFunc:create(function() circleSprite:removeFromParent() end)))
			
			-- 爆炸碎片
			local emitter = cc.ParticleSystemQuad:create("stars.plist")
			emitter:setPosition(temp:getPosition())
			local batch = cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
			batch:addChild(emitter)
			self:addChild(batch)

			-- 分数特效
			self:scorePopupEffect(PokemonScore, temp:getPosition())
			PokemonScore = PokemonScore + self.scoreStep

			-- 移除水果
			temp:removeFromParent()
		end
	end


	-- 更新当前得分
	self.curSorce = self.curSorce + self.activeScore
	self.curSorceLabel:setString(tostring(self.curSorce))

	-- 更新进度条
	-- local silderValue = self.curSorce / self.target * 100
	-- if silderValue > 100 then silderValue = 100 end
	-- self.silderBar:setSliderValue(silderValue)

	-- 清空高亮水果分数统计
	self.activeScoreLabel:setString("")
	self.activeScore = 0
end

function PlayScene:checkNextStage()
	if self.curSorce < self.target then
		return
	end
	
	audio.playSound("music/wow.mp3")

	-- resultLayer 半透明展示信息
	local resultLayer = display.newColorLayer(cc.c4b(0,0,0,150))
	resultLayer:addTo(self)
	-- 吞噬事件
	resultLayer:setTouchEnabled(true)
	resultLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			return true
		end
	end)

	-- 更新数据
	if self.curSorce >= self.highSorce then
		self.highSorce = self.curSorce
	end
	self.stage = self.stage + 1
	self.target = self.stage * 200
	-- 存储到文件
	cc.UserDefault:getInstance():setIntegerForKey("HighScore", self.highSorce)
	cc.UserDefault:getInstance():setIntegerForKey("Stage", self.stage)

	-- 通关信息
	display.newTTFLabel({text = string.format("恭喜过关！\n最高得分：%d", self.highSorce), size = 60})
		:pos(display.cx, display.cy + 140)
		:addTo(resultLayer)

	-- 开始按钮
	local startBtnImages = {
		normal = "#startBtn_N.png",
		pressed = "#startBtn_S.png",
	}
    cc.ui.UIPushButton.new(startBtnImages, {scale9 = false})
		:onButtonClicked(function(event)
			audio.stopMusic()

			local mainScene = import("app.scenes.MainScene"):new()
			display.replaceScene(mainScene, "flipX", 0.5)
		end)
		:align(display.CENTER, display.cx, display.cy - 80)
		:addTo(resultLayer)	
end

function PlayScene:scorePopupEffect(score, px, py)
	local labelScore = cc.ui.UILabel.new({UILabelType = 1, text = tostring(score), font = "font/earth32.fnt"})

	local move = cc.MoveBy:create(0.8, cc.p(0, 80))
	local fadeOut = cc.FadeOut:create(0.8)
	local action = transition.sequence({
		cc.Spawn:create(move,fadeOut),
		-- 动画结束移除 Label
		cc.CallFunc:create(function() labelScore:removeFromParent() end)
	})

	labelScore:pos(px, py)
		:addTo(self)
		:runAction(action)
end

function PlayScene:dropPokemons()
	-- 1. 掉落已存在的水果
	-- 一列一列的处理
	for _, id in pairs(map.startB) do
		local removedPokemons = 0
		local newY = 0
		while map.availPos[id] do
			local temp = self.matrix[id]
			if(temp == nil) then
				removedPokemons = removedPokemons + 1
				-- print("removed " .. removedPokemons)
			else 
				if removedPokemons > 0 then 
					local Point = getXY(id)
					-- print("id = " .. id)
					-- print("Point x = " .. Point.x .. " y = " .. Point.y)
					newY = Point.y - removedPokemons * 2
					-- print("ID " .. getID(Point.x, newY))
					temp.y = newY
					temp.id = getID(temp.x, temp.y)
					self.matrix[id - 10 * removedPokemons] = temp
					self.matrix[id] = nil
					local endPosition = self:positionOfPokemon(Point.x, newY)
					local speed = (temp:getPositionY() - endPosition.y) / display.height + 0.5
					temp:stopAllActions() --停止之前的动画
					temp:runAction(cc.MoveTo:create(speed, endPosition))
				end
			end
			id = id + 10
		end
	end
	for _, id in pairs(map.startT) do
		-- print("id = " .. id)
		while map.availPos[id] and self.matrix[id] == nil do
			-- print("visid = " .. id)
			local Point = getXY(id)
			self:createAndDropPokemon(Point.x, Point.y)
			id = id - 10
		end
	end
end

function PlayScene:positionOfPokemon(x, y)
	local dx = Pokemon.getWidth() / 2
	dx = dx + self.PokemonGap
	local dy = SRT / 2 * dx
    local px = self.matrixLBX + dx * 3  * (x - 1)
    local py = self.matrixLBY + dy * (y - 1)
    if y % 2 == 0 then px = px + 1.5 * dx end
    return cc.p(px, py)
end
-- 初始测试用代码
-- function PlayScene:activeNeighbor(Pokemon)
-- 	-- 高亮Pokemon
-- 	-- 6连通域
-- 	self.matrix[Pokemon.id]:setActive(true)
-- 	self.actives[Pokemon.id] = true
-- 	for i = 1, 6 do
-- 		local nid = Pokemon.id + map:getDirectArray(Pokemon)
-- 		if vis[nid] and Pokemon.pokemonIndex == self.matrix[nid].pokemonIndex then
-- 			local neighbor = self.matrix[nid]
-- 			if neighbor.isActive == false then
-- 				self.actives[neighbor.id] = true
-- 				self:activeNeighbor(neighbor)
-- 			end
-- 		end
-- 	end
-- end

function PlayScene:itemSwap(x1,y1,x2,y2)
	self.swapx,self.swapy = x1,y1
	self.matrix[getID(x1,y1)],self.matrix[getID(x2,y2)] = self.matrix[getID(x2,y2)],self.matrix[getID(x1,y1)]
	self.matrix[getID(x1,y1)].x,self.matrix[getID(x2,y2)].x = self.matrix[getID(x2,y2)].x,self.matrix[getID(x1,y1)].x
	self.matrix[getID(x1,y1)].y,self.matrix[getID(x2,y2)].y = self.matrix[getID(x2,y2)].y,self.matrix[getID(x1,y1)].y
	self.matrix[getID(x1,y1)].id,self.matrix[getID(x2,y2)].id = self.matrix[getID(x2,y2)].id,self.matrix[getID(x1,y1)].id
  
end

-- 交换成功的动画效果，并行
function PlayScene:swapAction(x1,y1,x2,y2)
	local speed = 0.15
    self.matrix[getID(x1,y1)]:stopAllActions()
    self.matrix[getID(x2,y2)]:stopAllActions()
    self.matrix[getID(x1,y1)]:runAction(cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x1,y1)].x,self.matrix[getID(x1,y1)].y)))
    self.matrix[getID(x2,y2)]:runAction(cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x2,y2)].x,self.matrix[getID(x2,y2)].y)))
    return 
end

-- 交换失败的动画效果，串行
function PlayScene:reswapAction(x1,y1,x2,y2)   
	local speed = 0.15
    self.matrix[getID(x1,y1)]:stopAllActions()
    self.matrix[getID(x2,y2)]:stopAllActions()
    local seqa = cc.Sequence:create(cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x2,y2)].x,self.matrix[getID(x2,y2)].y)),
    			cc.DelayTime:create(0.15),
    			cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x1,y1)].x,self.matrix[getID(x1,y1)].y))					)
	self.matrix[getID(x1,y1)]:runAction(seqa)

    local seqb = cc.Sequence:create(cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x1,y1)].x,self.matrix[getID(x1,y1)].y)),
    			cc.DelayTime:create(0.15),
    			cc.MoveTo:create(speed, self:positionOfPokemon(self.matrix[getID(x2,y2)].x,self.matrix[getID(x2,y2)].y))					)
	self.matrix[getID(x2,y2)]:runAction(seqb)
end
-- 初始测试用代码
-- function PlayScene:inactive()
--     for _ in pairs(self.actives) do
    	
--         if self.matrix[_] then
--             self.matrix[_]:setActive(false)
--         end
--     end
-- 	self.actives = {}
-- end
-- 初始测试用代码
-- function PlayScene:showActivesScore()
	-- 只有一个高亮，取消高亮并返回
	-- local cnt = 0
	-- for i, k in pairs(self.actives) do
	-- 	cnt = cnt + 1
	-- end
	-- if 1 >= cnt then
	-- 	self:inactive()
	-- 	self.activeScoreLabel:setString("")
	-- 	self.activeScore = 0
	-- 	return
	-- end
	-- print("cnt = " .. cnt)
	-- 水果分数依次为5、15、25、35... ，求它们的和
-- 	self.activeScore = (self.scoreStart * 2 + self.scoreStep * (cnt - 1)) * cnt / 2
-- 	self.activeScoreLabel:setString(string.format("%d 连消，得分 %d", cnt, self.activeScore))
-- end

function PlayScene:onEnter()
end

function PlayScene:onExit()
end

return PlayScene
