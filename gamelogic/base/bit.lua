local bit = {}

bit.MAXLEN = 64

function bit._toarr(num,base)
	assert(math.floor(num) == num)  -- need int
	-- double类型>2^52g以上的数计算已经丢失精度,如:(2^54-1)%16 == 0,而(2^52-1)%16== 15
	-- 第三方库luabit当定义LUA_NUMBER_DOUBLE宏时允许最大的数也是2^52
	-- 因此自己用纯lua想支持64位整型位运算是不可能
	assert(num <= 2^52)		
	local bitarr = {}  -- 64bit
	while math.floor(num / base) ~= 0 do
		table.insert(bitarr,num % base)
		num = math.floor(num / base)
	end
	table.insert(bitarr,num)
	return bitarr
end

function bit.toarr(num)
	local bitarr = bit._toarr(num,2)
	local len = #bitarr
	assert(len <= bit.MAXLEN)
	for i=len+1,bit.MAXLEN do
		table.insert(bitarr,0)
	end
	return bitarr
end

-- to decimal
function bit.tonum(bitarr,base)
	base = base or 2
	local num = 0
	for i=1,#bitarr do
		local bit = bitarr[i]
		num = num + bit * base ^ (i-1)
	end
	return num
end

function bit.band(num,...)
	local args = {...}
	if #args == 0 then
		return num
	end
	local bitarr = bit.toarr(num)
	for i,v in ipairs(args) do
		local bitarr2 = bit.toarr(v)
		for i = 1,bit.MAXLEN do
			if bitarr[i] == 1 and bitarr2[i] == 1 then
				bitarr[i] = 1
			else
				bitarr[i] = 0
			end
		end
	end
	return bit.tonum(bitarr)
end

function bit.bor(num,...)
	local args = {...}
	if #args == 0 then
		return num
	end
	local bitarr = bit.toarr(num)
	for i,v in ipairs(args) do
		local bitarr2 = bit.toarr(v)
		for i = 1,bit.MAXLEN do
			if bitarr[i] == 0 and bitarr2[i] == 0 then
				bitarr[i] = 0
			else
				bitarr[i] = 1
			end
		end
	end
	return bit.tonum(bitarr)
end

function bit.bxor(num,...)
	local args = {...}
	if #args == 0 then
		return num
	end
	local bitarr = bit.toarr(num)
	for i,v in ipairs(args) do
		local bitarr2 = bit.toarr(v)
		for i = 1,bit.MAXLEN do
			if bitarr[i] ~= bitarr2[i] then
				bitarr[i] = 1
			else
				bitarr[i] = 0
			end
		end
	end
	return bit.tonum(bitarr)
end


function bit.bnot(num)
	local bitarr = bit.toarr(num)
	for i = 1,bit.MAXLEN do
		if bitarr[i] == 1 then
			bitarr[i] = 0
		else
			assert(bitarr[i] == 0)
			bitarr[i] = 1
		end
	end
	return bit.tonum(bitarr)
end

function bit.lshift(num,shift)
	local bitarr = bit.toarr(num)
	if shift >= #bitarr then
		return 0
	end
	while shift > 0 do
		shift = shift - 1
		table.remove(bitarr)
		table.insert(bitarr,1,0)
	end
	return bit.tonum(bitarr)
end

function bit.rshift(num,shift)
	local bitarr = bit.toarr(num)
	if shift >= #bitarr then
		return 0
	end
	while shift > 0 do
		shift = shift - 1
		table.remove(bitarr,1)
		table.insert(bitarr,0)
	end
	return bit.tonum(bitarr)
end

function bit.arshift(num,shift)
	local bitarr = bit.toarr(num)
	if shift >= #bitarr then
		return 0
	end
	local sign = bitarr[#bitarr]
	while shift > 0 do
		shift = shift - 1
		table.remove(bitarr,1)
		table.insert(bitarr,sign)
	end
	return bit.tonum(bitarr)
end

function bit.rol(num,rotate)
	assert(rotate <= bit.MAXLEN)
	return bit.bor(bit.lshift(num,rotate),bit.rshift(num,bit.MAXLEN-rotate))
end

function bit.ror(num,rotate)
	assert(rotate <= bit.MAXLEN)
	return bit.bor(bit.lshift(num,bit.MAXLEN-rotate),bit.rshift(num,rotate))
end

function bit.bswap(num)
	local num1 = bit.rshift(num,56)
	local num2 = bit.lshift(bit.band(bit.rshift(num,48),0xff),8)
	local num3 = bit.lshift(bit.band(bit.rshift(num,40),0xff),16)
	local num4 = bit.lshift(bit.band(bit.rshift(num,32),0xff),24)
	local num5 = bit.lshift(bit.band(bit.rshift(num,24),0xff),32)
	local num6 = bit.lshift(bit.band(bit.rshift(num,16),0xff),40)
	local num7 = bit.lshift(bit.band(bit.rshift(num,8),0xff),48)
	local num8 = bit.lshift(bit.band(num,0xff),56)
	return bit.bor(num1,num2,num3,num4,num5,num6,num7,num8)
end

function bit.tobit(num)
	return tonumber(num)
end

local HEX = {}
for i=0,15 do
	if i < 10 then
		HEX[i] = tostring(i)
	else
		HEX[i] = string.char(97+i-10)
	end
end

function bit.tohex(num,n)
	n = n or 16
	local bitarr = bit._toarr(num,16)
	local chararr = {}
	for i,bit in ipairs(bitarr) do
		chararr[i] = HEX[bit]
	end
	for i = #chararr+1,n do
		chararr[i] = HEX[0]
	end
	return string.reverse(table.concat(chararr,""))
end

return bit
