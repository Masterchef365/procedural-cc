modem = peripheral.find("modem")

local remote_file = "temp.lua"

while true do
    local command = read()
    local modem = peripheral.find("modem")
    modem.transmit(33, 1, {
        type="write",
        fname=remote_file,
        data=command,
    })
    modem.transmit(33, 1, {
        type="run",
        command=remote_file,
    })
end