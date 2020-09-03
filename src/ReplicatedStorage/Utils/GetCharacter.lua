local f
f = function(p)
    if not p or p == workspace or p == game then
        return
    end
    if p:FindFirstChild("Humanoid") then
        return p
    end
    return f(p.Parent)
end

return f
