local modem = peripheral.find("modem");
modem.open(4)

-- Tell the workers to identify themselves
modem.transmit(3, 4, {
    type="start_identify"
})

-- Set a timeout for workers to respond
os.startTimer(3)

function tableHasKey(table,key)
    return table[key] ~= nil
end

-- Wait for workers to identify themselves
local root = nil
local assignments = {}
print("Begin identifying")
while true do
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
    if event == "timer" then
        print("Finished identifying")
        break
    elseif event == "modem_message" then
        if message.type == "identify" then
            if message.neighbor_id then
                print(message.neighbor_id, message.our_id)
                assignments[message.neighbor_id] = message.our_id
            else
                root = message.our_id
            end
        end
    end
end

-- Work out which position each computer is at
local cur_node = root
local seq = {cur_node}
while tableHasKey(assignments, cur_node) do
    cur_node = assignments[cur_node]
    seq[#seq+1] = cur_node
end

-- Create a table of computer id -> assigned position
local positions = {}

print("Sequence")
print("Root", root)
for i,v in ipairs(seq) do
    positions[v] = vector.new(i-1, 0, 0)
    print(v, positions[v])
end

-- Send the sequence to the bots
print("Number of workers: ", #seq)
modem.transmit(3, 4, {
    type="assignment",
    positions=positions,
    num=#seq
})
