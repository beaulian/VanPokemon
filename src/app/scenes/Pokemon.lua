
local Pokemon = class("Pokemon", function(x, y, id, pokemonIndex)
	pokemonIndex = pokemonIndex or math.round(math.random() * 1000) % 8 + 1

	local sprite = display.newSprite("#fruit"  .. pokemonIndex .. '_1.png')
	sprite.pokemonIndex = pokemonIndex or 1
	sprite.x = x
	sprite.y = y
    sprite.begx = -1
    sprite.begy = -1
    sprite.id = id
	sprite.isActive = false
	return sprite
end)

function Pokemon:ctor()
end
-- 当前函数无用
-- function Pokemon:setActive(active)
--     self.isActive = active

--     local frame
--     if (active) then
--         frame = display.newSpriteFrame("fruit"  .. self.pokemonIndex .. '_2.png')
--     else
--         frame = display.newSpriteFrame("fruit"  .. self.pokemonIndex .. '_1.png')
--     end

--     self:setSpriteFrame(frame)

--     if (active) then
--         self:stopAllActions()
--         local scaleTo1 = cc.ScaleTo:create(0.1, 1.1)
--         local scaleTo2 = cc.ScaleTo:create(0.05, 1.0)
--         self:runAction(cc.Sequence:create(scaleTo1, scaleTo2))
--     end
-- end
-- 获得图片宽度
function Pokemon.getWidth()
    g_fruitWidth = 0
    if (0 == g_fruitWidth) then
        local sprite = display.newSprite("#fruit1_1.png")
        g_fruitWidth = sprite:getContentSize().width
    end
    return g_fruitWidth
end

return Pokemon
