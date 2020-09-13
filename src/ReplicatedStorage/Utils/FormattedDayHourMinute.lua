return function(num)
    num = math.floor(num)
    local minutes = math.floor(num / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours/24)
    minutes = minutes % 60
    hours = hours % 60
    if days > 0 then
        return string.format("%dD %dH %dMin.", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%dH %dMin.", hours, minutes)
    else
        return string.format("%dMin.", minutes)
    end
end