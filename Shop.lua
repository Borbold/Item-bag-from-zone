function onLoad(savedData)
    previousBag = nil
    Wait.frames(RebuildAssets, 10)
end

function SearchBoxByName(player, guid)
    if(guid == "") then printToAll(guid .. " не найден.", "Red") return end
    if(previousBag ~= nil) then
        previousBag.UI.setAttribute("nameTransfer", "color", "#000000")
        previousBag.UI.setAttribute("nameTransfer", "textColor", "#ffffff")
    end
    local itemBag = getObjectFromGUID(guid) previousBag = itemBag
    broadcastToAll("Выбран " .. itemBag.getName())
    itemBag.UI.setAttribute("nameTransfer", "color", "#008000")
    itemBag.UI.setAttribute("nameTransfer", "textColor", "#ffffff")
    self.setDescription(itemBag.getName())
    OverhaulButton(guid)
end

function OverhaulButton(guid)
    local place = guid .. "/TakeObjectBag"
    local recall = guid .. "/PutObjectBag"
    self.UI.setAttribute("upload", "onClick", place) self.UI.setAttribute("upload", "textColor", "#ffffff")
    self.UI.setAttribute("fold", "onClick", recall) self.UI.setAttribute("fold", "textColor", "#ffffff")
end

function RebuildAssets()
    local root1 = "https://sun9-56.userapi.com/c857528/v857528763/1e9624/NzPonxwy6h0.jpg"
    local root2 = "https://sun9-71.userapi.com/c857528/v857528763/1e962b/AiDs8ktIsQA.jpg"
    local assets = {
        {name = "upload", url = root1},
        {name = "fold", url = root2}
    }
    self.UI.setCustomAssets(assets)
end