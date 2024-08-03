local modem = peripheral.find("modem")
modem.open(9)

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
THRESHOLD = 1.0
DENSITY = 4/(24*24*24)
N = 2
LENGTH = WIDTH*N
HEIGHT = WIDTH*N
WIDTH_REPEATS = N
ENDERCHEST_SLOT = 1
BLOCK_SLOT = 2
math.randomseed(5)

-- Determine # of points
VOLUME = LENGTH * WIDTH * HEIGHT * WIDTH_REPEATS
N_POINTS = math.floor(DENSITY * VOLUME)
N_POINTS = math.max(N_POINTS, 3)
print("# of points:", N_POINTS)

-- Utils
function rand_point()
    return vector.new(
        math.random(-WIDTH * (WIDTH_REPEATS-1), WIDTH),
        math.random(0, HEIGHT),
        math.random(0, LENGTH)
    )    
end

function distance(a, b)
    local d = b - a
    return math.sqrt(d.x*d.x + d.y*d.y + d.z*d.z)
    --return math.sqrt(diff.dot(diff))
end

-- Set up random points
local points = {}
for i = 1,N_POINTS do
    points[i] = rand_point()
    print(points[i].x, points[i].y, points[i].z)
end

function voronoi(pos)
    local min_dist = 999999.0
    local min_index = 0
    local prev_min_dist = min_dist
    for i = 1,N_POINTS do
        local dist = distance(pos, points[i])
        if dist < min_dist then
            prev_min_dist = min_dist
            min_dist = dist
            min_index = i
        elseif dist < prev_min_dist then
            prev_min_dist = dist
        end
    end
    if min_index > 0 then
        return {
            min_dist=min_dist,
            min_index=min_index,
            prev_min_dist=prev_min_dist,
        }
    end
end

function walltest(pos)
    return true
    --local v = voronoi(pos)
    --return v.prev_min_dist - v.min_dist < THRESHOLD
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
local aborting = false
for rep=1,WIDTH_REPEATS do
    for y=1,HEIGHT do
        -- Check for abort
        os.startTimer(1)
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
        if event == "modem_message" and message == "abort" then
            aborting = true
        end

        -- Do a run through one length
        if not aborting then
            for z=1,LENGTH do
                if walltest(cur_pos) then
                    placer()
                end
                if not(z == LENGTH) then
                    turtle.forward()
                    cur_pos.z = cur_pos.z + z_dir
                end
            end
        end

        -- If at the top, travel over to the next rep
        if y == HEIGHT and not(rep == WIDTH_REPEATS) then
            -- First go backwards
            -- Go up one block if travelling right, two if left
            -- Then travel horizontally
            -- Then undo
            local y_dir = 1
            if y % 2 == 0 then
                y_dir = -1
            end
            local direction = z_dir * y_dir

            for i=1,initial_pos.x do
                turtle.back()
            end
            turtle.up()
            if direction == 1 then
                turtle.up()
            end

            turndir(direction)
            for x=1,WIDTH do
                turtle.forward()
            end
            turndir(-direction)

            -- Undo uppies
            turtle.down()
            if direction == 1 then
                turtle.down()
            end
            for i=1,initial_pos.x do
                turtle.forward()
            end
            z_dir = -z_dir
            cur_pos.x = cur_pos.x + WIDTH

            -- Go down
            for yy=1,HEIGHT-1 do
                turtle.down()
                cur_pos.y = cur_pos.y - 1
            end
        else
            turtle.up()
            cur_pos.y = cur_pos.y + 1
        end

        turtle.turnRight()
        turtle.turnRight()
    end
end

print("Done!")


