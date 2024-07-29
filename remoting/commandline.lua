modem = peripheral.find("modem")

while true do
    command = read()
    modem.transmit(33, 1, {
        type="run",
        command=command,
    })
end