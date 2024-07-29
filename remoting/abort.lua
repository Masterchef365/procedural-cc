local modem = peripheral.find("modem")
while true do
    modem.transmit(9, 1, "abort")
    sleep(0.5)
end