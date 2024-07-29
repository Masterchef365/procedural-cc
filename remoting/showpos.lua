local file = fs.open("position.txt", "r")
local pos = vector.new(
    tonumber(file.readLine()),
    tonumber(file.readLine()),
    tonumber(file.readLine())
)
local num = tonumber(file.readLine())
print(pos.x, pos.y, pos.z)
print("Number of bots: ", num)