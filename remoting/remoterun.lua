local remote_file = ...
local modem = peripheral.find("modem")
local file = fs.open(remote_file, "r")
local text = file.readAll()

modem.transmit(33, 1, {
    type="write",
    fname=remote_file,
    data=text,
})
modem.transmit(33, 1, {
    type="run",
    command=remote_file,
})