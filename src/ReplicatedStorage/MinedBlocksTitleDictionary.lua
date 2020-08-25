local tbl = {
    {
        Name = "Beginner",
        OreCount = 0,
        TextColor3 = Color3.fromRGB(236, 204, 104),
        TextStrokeColor3 = Color3.fromRGB(236, 204, 104)
    },
    {
        Name = "Apprentice",
        OreCount = 25,
        TextColor3 = Color3.fromRGB(236, 204, 104),
        TextStrokeColor3 = Color3.fromRGB(236, 204, 104)
    },
    {
        Name = "Experienced",
        OreCount = 75,
        TextColor3 = Color3.fromRGB(236, 204, 104),
        TextStrokeColor3 = Color3.fromRGB(236, 204, 104)
    },
    {
        Name = "Advanced",
        OreCount = 175,
        TextColor3 = Color3.fromRGB(236, 204, 104),
        TextStrokeColor3 = Color3.fromRGB(236, 204, 104)
    }
}

table.sort(
    tbl,
    function(a, b)
        return a.OreCount < b.OreCount
    end
)

return tbl