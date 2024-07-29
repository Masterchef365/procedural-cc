ENDERCHEST_SLOT = 1

turtle.up()
turtle.select(ENDERCHEST_SLOT)
turtle.placeDown()
for i=2,16 do
    turtle.select(i)
    turtle.dropDown()
end
turtle.select(ENDERCHEST_SLOT)
turtle.digDown()
turtle.down()