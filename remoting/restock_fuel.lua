turtle.select(2)
turtle.turnLeft()
if not(peripheral.getType("front") == "turtle") then
    print("I'm first")
    for i=2,16 do
        turtle.suck()
    end
else
    local timeout = 400
    while not turtle.refuel() and timeout > 0 do
        sleep(0.1)
        timeout = timeout - 1
    end
end
turtle.refuel()
turtle.turnRight()
turtle.turnRight()
for i=2,16 do
    turtle.select(i)
    turtle.drop()
end
turtle.turnLeft()

-- Test
turtle.forward()
turtle.back()
