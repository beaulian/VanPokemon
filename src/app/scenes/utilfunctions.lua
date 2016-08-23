
-- 存放一些公用函数的地方

-- 求得x,y点对, id互逆运算
function getID(x, y)
	return (y - 1) * 5 + x
	-- body
end

function getXY(id)
	local y = math.modf((id + 4) / 5)
	local x = id - (y - 1) * 5
	return cc.p(x, y)
	-- body
end
