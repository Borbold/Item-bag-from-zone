function UpdateSave()
    local dataToSave = {["memoryList"] = memoryList, ["itemsSelected"] = itemsSelected}
    savedData = JSON.encode(dataToSave)
    self.script_state = savedData
end

function onLoad(savedData)
    memoryList = {} itemsSelected = false
    if(savedData ~= "") then
        local loadedData = JSON.decode(savedData)
        memoryList = loadedData.memoryList or {}
        itemsSelected = loadedData.itemsSelected or false
    end
    Wait.frames(SetButtonFunction, 20)
    Wait.frames(ShowMemoryActionButtons, 40)
end

function Setup()
    memoryListBackup = memoryList
    memoryList = {}
    ShowSetupActionButtons()
end

function Cancel()
    if(CheckName() == false) then return end
    memoryList = memoryListBackup
    ShowMemoryActionButtons()
    RemoveAllHighlights()
end

function TakeObjectsInZone()
    local checkItem = false
    if(self.getDescription() ~= "") then
	    local zone = getObjectFromGUID(self.getDescription())
        for _,item in pairs(zone.getObjects()) do
            if(item.interactable == true) then
                Selection(item)
                checkItem = true
                itemsSelected = true
            end
        end
    else
        printToAll("Вы не выбрали зону для приема предметов!", "Red")
        checkItem = true
    end
    if(checkItem == false) then printToAll("В выбранной зоне нет никаких вещей", "Red") end
end

function Selection(obj)
    local pos, rot = obj.getPosition(), obj.getRotation()
    memoryList[obj.getGUID()] = {
        pos = {pos.x, pos.y, pos.z},
        rot = {rot.x, rot.y, rot.z},
        lock = obj.getLock()
    }
    obj.setGMNotes("Товар из магазина: " .. self.getName())
    obj.highlightOn({0, 1, 0})
end

function Apply()
    if(CheckName() == false) then return end
    TakeObjectsInZone()
    if(next(memoryList) ~= nil) then
        ShowMemoryActionButtons()
        UpdateSave()
    else
        return
    end
end

function CheckName()
	if(self.getName() == "") then
        broadcastToAll("Укажите название")
        return false
    end
end

function Reset()
    itemsSelected = false memoryList = {}
    if(#self.getObjects() ~= 0) then
        broadcastToAll("Опустошите мешок!", "Red")
        return
    end
    ShowMemoryActionButtons()
    RemoveAllHighlights()
    UpdateSave()
end

function ShowSetupActionButtons()
    self.UI.hide("memoryAction")
    self.UI.show("setupAction")
    if(itemsSelected == false) then
        self.UI.show("apply")
    else
        self.UI.hide("apply")
    end
    self.UI.setAttribute("inputGuid", "text", self.getDescription())
    self.UI.setAttribute("inputName", "text", self.getName())
end

function SetGUID(player, value)
	self.setDescription(value)
end

function SetName(player, value)
    self.setName(value)
end

function SetButtonFunction()
    local GUIDShop = "1222c9"
	self.UI.setAttribute("nameTransfer", "onClick", GUIDShop .. "/SearchBoxByName(" .. self.getGUID() .. ")")
end

function ShowMemoryActionButtons()
    self.UI.hide("setupAction")
    self.UI.show("memoryAction")
    if(self.getName() ~= "") then
        self.UI.show("nameTransfer")
        self.UI.setAttribute("nameTransfer", "text", self.getName())
        self.UI.setAttribute("nameTransfer", "textColor", "#ffffff")
        self.UI.setAttribute("memoryAction", "height", "250")
    else
        self.UI.hide("nameTransfer")
        self.UI.setAttribute("memoryAction", "height", "125")
    end
end

function PutObjectBag()
    if(#self.getObjects() == 0) then
        for guid,_ in pairs(memoryList) do
            if(getObjectFromGUID(guid) ~= nil) then
                if(getObjectFromGUID(guid).getGMNotes() == "Товар из магазина: " .. self.getName()) then
                    self.putObject(getObjectFromGUID(guid))
                else
                    memoryList[guid] = nil
                end
            else
                memoryList[guid] = nil
            end
        end
    end
end

function TakeObjectBag()
    if(#self.getObjects() ~= 0) then
        for guid,entry in pairs(memoryList) do
            self.takeObject({
                position = entry.pos, rotation = entry.rot,
                lock = entry.lock, guid = guid
		    })
        end
    end
end

function RemoveAllHighlights()
    for _,obj in ipairs(memoryList) do
        obj.highlightOff()
    end
end