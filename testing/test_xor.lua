local vector = require("vector").vector
local bit = require "bit32"

function walltest(pos)
    local uv = (pos / LENGTH) * 2 - vector.new(1,1,1);

    local zoomout = 40 -- LENGTH / 10
    uv = uv * zoomout

    local l2 = uv.z*uv.z + uv.x*uv.x

    local k = LENGTH / math.max(l2, 1.0)

    local a = math.floor(uv.x * k)
    local b = math.floor(uv.z * k)

    local nnn = bit.bxor(a, b) % 3
    return nnn == 2
end

NUM_TURTLES = 19
n = math.floor(120/NUM_TURTLES)

LENGTH = NUM_TURTLES * n
WIDTH = LENGTH

print("P1")
print(WIDTH)
print(LENGTH)

for z=1,LENGTH do
    for x=1,WIDTH do
        local b = walltest(vector.new(x, 0, z))
        if b then
            io.write('1')
        else
            io.write('0')
        end
        io.write(' ')
    end
    print()
end