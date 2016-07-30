local bit = require "gamelogic.base.bit"
local bitc = require "bit"

local function test()
	print(bitc.tohex(bitc.tobit(0xffffffff)),bit.tohex(bit.tobit(0xffffffff),8))
	assert(bitc.tohex(bitc.tobit(0xffffffff)) == bit.tohex(bit.tobit(0xffffffff),8))
	print(bitc.tohex(1),bit.tohex(1,8))
	assert(bitc.tohex(1) == bit.tohex(1,8))
	print(bitc.tohex(bitc.bnot(0)),bit.tohex(bit.bnot(0),8))
	--assert(bitc.tohex(bitc.bnot(0)) == bit.tohex(bit.bnot(0),8))
	print(bitc.bor(1,2,4,8),bit.bor(1,2,4,8))
	assert(bitc.bor(1,2,4,8) == bit.bor(1,2,4,8))
	print(bitc.band(1,2,4,8),bit.band(1,2,4,8))
	assert(bitc.band(1,2,4,8) == bit.band(1,2,4,8))
	print(bitc.bxor(1,2,4,8),bit.bxor(1,2,4,8))
	assert(bitc.bxor(1,2,4,8) == bit.bxor(1,2,4,8))
	print(bitc.lshift(1,0),bit.lshift(1,0))
	assert(bitc.lshift(1,0) == bit.lshift(1,0))
	print(bitc.lshift(1,8),bit.lshift(1,8))
	assert(bitc.lshift(1,8) == bit.lshift(1,8))
	print(bitc.rshift(256,8),bit.rshift(256,8))
	assert(bitc.rshift(256,8) == bit.rshift(256,8))
	print(bitc.arshift(256,8),bit.arshift(256,8))
	assert(bitc.arshift(256,8) == bit.arshift(256,8))
	print(bitc.arshift(-256,8),bit.arshift(-256,8))
	assert(bitc.arshift(-256,8) == bit.arshift(-256,8))
end

return test
