local modem = peripheral.find("modem");
modem.open(3)

-- Get the ID of your neighbor
turtle.turnLeft()
local neighbor = peripheral.wrap("front")
local neighbor_id = nil
if peripheral.getType("front") == "turtle" then
    neighbor_id = neighbor.getID()
end
print("Our ID is", os.getComputerID())
print("Neighbor is", neighbor_id)

-- Wait for the "start_identify" message
repeat
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
until message.type == "start_identify"
print("Received start-identify")

sleep(1)
turtle.turnRight()

-- Send our own ID and our neighbor's 
print("Transmitting ID")
modem.transmit(4, 3, {
    type="identify",
    neighbor_id=neighbor_id,
    our_id=os.getComputerID(),
})

-- Wait to receive the position assignment
local pos = nil
local event, modemSide, senderChannel, replyChannel, message, senderDistance
repeat
    event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
until message.type == "assignment"
pos = message.positions[os.getComputerID()]

-- Write it to a file
if pos then
    print("Writing", pos.x, pos.y, pos.z, num)
    local num = message.num
    local file = fs.open("position.txt", "w")
    file.writeLine(tostring(pos.x))
    file.writeLine(tostring(pos.y))
    file.writeLine(tostring(pos.z))
    file.writeLine(tostring(num))
    file.close()
end
