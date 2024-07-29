turtle.turnLeft()

timeout = 10 * 10
index = 1
while timeout > 0 do
    turtle.select(index)
    turtle.drop()
    sleep(0.1)
    timeout = timeout - 1
    index = index + 1
    if index > 16 then
        index = 1
    end
end

turtle.turnRight()