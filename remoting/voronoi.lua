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
DENSITY = 8/(24*24*24)
LENGTH = 24*5
HEIGHT = 4
WIDTH_REPEATS = 5
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
    local v = voronoi(pos)
    return v.prev_min_dist - v.min_dist < THRESHOLD
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

function horiz_travel(direction, times)
    -- Pick out our own Y and Z values
    turtle.up()
    for y=1,initial_pos.x do
        turtle.up()
    end
    for y=1,initial_pos.x do
        turtle.forward()
    end


    -- Travel horizontally
    turndir(direction)
    for time=1,times do
        for x=1,WIDTH do
            turtle.forward()
        end
    end
    turndir(-direction)

    -- Go back down
    cur_pos.x = cur_pos.x - WIDTH
    for y=1,initial_pos.x do
        turtle.back()
    end

    for y=1,initial_pos.x do
        turtle.down()
    end
end

-- Thingy
turtle.up()

local do_abort = false
for rep=1,WIDTH_REPEATS do
    turtle.forward() -- Begin rep

    -- Do a run through one width
    local z_dir = 1
    for y=1,HEIGHT do
        local abort_round = do_abort and (z_dir == 1)
        if not(abort_round) then
            for z=1,LENGTH do
                if walltest(cur_pos) then
                    placer()
                end
                if not (z == LENGTH) then
                    turtle.forward()
                    cur_pos.z = cur_pos.z + z_dir
                end
            end
        end

        turtle.up()
        cur_pos.y = cur_pos.y + 1

        if not(abort_round) then
            turtle.turnRight()
            turtle.turnRight()
            z_dir = -z_dir
        end

        os.startTimer(1)
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
        if event == "modem_message" and message == "abort" then
            print("Aborting")
            do_abort = true
        end
    end

    -- Return to the beginning
    if z_dir == -1 then
        for z=1,LENGTH-1 do
            turtle.forward()
        end
        turtle.turnRight()
        turtle.turnRight()
    end

    turtle.back() -- End rep

    -- Travel to next width part
    if (rep == WIDTH_REPEATS) then
        --turtle.back()
        --horiz_travel(1, WIDTH_REPEATS-1)
        --turtle.forward()
    else
        horiz_travel(-1, 1)
    end

    -- Go back down
    turtle.down()
    for y=1,HEIGHT do
        turtle.down()
    end
    cur_pos.y = 0
end

print("Done!")