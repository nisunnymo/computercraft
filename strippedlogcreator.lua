function chopper ()
    a, b = turtle.inspect()

    if not a then
        print("nothing to chop")
    end

    if string.find(b.name, 'stripped') then
        turtle.dig()
    end

    for i=1,4 do
        ItemCount = turtle.getItemCount(i)

        if ItemCount > 0 then
            turtle.select(i)
            turtle.dropUp(i)
            turtle.select(1)
        end
    end
end

while true do
    chopper()
    sleep 1
end