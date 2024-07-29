turtle.select(1)
turtle.turnLeft()

timeout = 10 * 10
while timeout > 0 do
    turtle.suck()
    sleep(0.1)
    timeout = timeout - 1
end

turtle.turnRight()