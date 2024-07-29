modem = peripheral.find("modem")
modem.open(99)

turtle.turnRight()
turtle.select(1)

if peripheral.getType("front") == "turtle" then
    local turt = peripheral.wrap("front")
    turt.shutdown()
    turt.turnOn()
    if turtle.getItemCount() > 1 then
        turtle.drop(turtle.getItemCount() - 1)
    end

    local remote_file = "remoting/prep.lua"
    local modem = peripheral.find("modem")
    local file = fs.open(remote_file, "r")
    local text = file.readAll()
    
    -- Tell the next turtle what to do
    sleep(1)
    modem.transmit(33, 1, {
        type="write",
        fname=remote_file,
        data=text,
    })
    modem.transmit(33, 1, {
        type="run",
        command=remote_file,
    })
    
    os.startTimer(500)
    print("Waiting...")
    repeat
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
        print(event)
    until event == "timer" or (event == "modem_message" and senderChannel == 99)
    print("Got event")
else
    print("Done!")
    modem.transmit(99, 1, "Done")
end

turtle.turnLeft()