-- Read initial position from file
local file = fs.open("position.txt", "r")
local initial_pos = vector.new(
    tonumber(file.readLine()),
    tonumber(file.readLine()),
    tonumber(file.readLine())
)
local WIDTH = tonumber(file.readLine())
print("Pos:", initial_pos.x, initial_pos.y, initial_pos.z)
print("Width:", WIDTH)

-- Configuration
n = math.floor(120/WIDTH)
LENGTH = WIDTH * n
WIDTH_REPEATS = n

ENDERCHEST_SLOT = 1
BLOCK_SLOT = 2

function walltest(pos)
    local uv = (pos / LENGTH) * 2 - vector.new(1,1,1);

    local zoomout = 40 -- LENGTH / 10
    uv = uv * zoomout

    local l2 = uv.z*uv.z + uv.x*uv.x

    local k = LENGTH / math.max(l2, 1.0)

    local a = math.floor(uv.x * k)
    local b = math.floor(uv.z * k)

    local nnn = bit.bxor(a, b) % 3
    return nnn == 1
end

function placer()
    turtle.select(BLOCK_SLOT)   
    if turtle.getItemCount() == 0 then
        turtle.select(ENDERCHEST_SLOT)
        turtle.placeDown()
        turtle.select(BLOCK_SLOT)
        while not (turtle.suckDown() or turtle.getItemCount() > 0) do
            print("Waiting for enderchest ...")
            sleep(1)
        end
        turtle.select(ENDERCHEST_SLOT)
        turtle.digDown()
        turtle.select(BLOCK_SLOT)   
    end
    turtle.placeDown()
end

function turndir(direction)
    if direction > 0 then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
end

local cur_pos = vector.new(initial_pos.x, initial_pos.y, initial_pos.z)

-- Thingy
local z_dir = 1
for rep=1,WIDTH_REPEATS do
    -- Do a run through one width
    for z=1,LENGTH do
        if walltest(cur_pos) then
            placer()
        end
        if not(z == LENGTH) then
            turtle.forward()
            cur_pos.z = cur_pos.z + z_dir
        end
    end

    if not(rep == WIDTH_REPEATS) then
        -- First go backwards
        -- Go up one block if travelling right, two if left
        -- Then travel horizontally
        -- Then undo

        for i=1,initial_pos.x do
            turtle.back()
        end
        turtle.up()
        if z_dir == 1 then
            turtle.up()
        end

        turndir(z_dir)
        for x=1,WIDTH do
            turtle.forward()
        end
        turndir(-z_dir)
        
        -- Undo uppies
        turtle.down()
        if z_dir == 1 then
            turtle.down()
        end
        for i=1,initial_pos.x do
            turtle.forward()
        end
        z_dir = -z_dir
        cur_pos.x = cur_pos.x + WIDTH
    end

    turtle.turnRight()
    turtle.turnRight()
end

print("Done!")
