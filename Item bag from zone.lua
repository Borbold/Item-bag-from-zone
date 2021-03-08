function updateSave()
    local data_to_save = {["ml"]=memoryList}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function onload(saved_data)
    buttonWidth = 1350 buttonHeight = 450 buttonFontSize = 250 buttonPositionY = 4.17

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        memoryList = loaded_data.ml
    else
        memoryList = {}
    end

    if next(memoryList) == nil then
        createMemoryActionButtons(true)
    else
        createMemoryActionButtons(false)
    end
end

function buttonClick_setup()
    memoryListBackup = duplicateTable(memoryList)
    memoryList = {}
    self.clearButtons()
    createSetupActionButtons()
end

function TakeObjectsInZone()
  if(self.getGMNotes() ~= nil) then
	  local zone = getObjectFromGUID(self.getGMNotes())
    for i,item in pairs(zone.getObjects()) do
      if(not item.getGMNotes():find("NotPutObjectBag") and item.interactable) then
        Selection(i, item)
      end
    end
  else
    printToAll("Вы не выбрали зону для приема предметов!", "Red")
  end
end

function Selection(index, obj)
  local color = {0,1,0,0.6}
  if memoryList[obj.getGUID()] == nil then
    local pos, rot = obj.getPosition(), obj.getRotation()
    memoryList[obj.getGUID()] = {
      pos={x=round(pos.x,4), y=round(pos.y,4), z=round(pos.z,4)},
      rot={x=round(rot.x,4), y=round(rot.y,4), z=round(rot.z,4)},
      lock=obj.getLock()
    }
    obj.highlightOn({0, 1, 0})
  end
end

function buttonClick_cancel()
  memoryList = memoryListBackup
  self.clearButtons()
  if next(memoryList) == nil then
    createMemoryActionButtons(true)
  else
    createMemoryActionButtons(false)
  end
end

function buttonClick_submit()
    TakeObjectsInZone()
    if next(memoryList) == nil then
        return
    else
        self.clearButtons()
        createMemoryActionButtons(false)
        updateSave()
    end
end

function buttonClick_reset()
    memoryList = {}
    self.clearButtons()
    createMemoryActionButtons(true)
    updateSave()
end

function createSetupActionButtons()
    self.createButton({
        label="Отмена", click_function="buttonClick_cancel", function_owner=self,
        position={0, buttonPositionY, 0}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })
    self.createButton({
        label="Выбрать", click_function="buttonClick_submit", function_owner=self,
        position={0, buttonPositionY, -1}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })
    self.createButton({
        label="Сбросить", click_function="buttonClick_reset", function_owner=self,
        position={0, buttonPositionY, 1}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })
end

function createMemoryActionButtons(showOnlySelection)
    self.createButton({
        label="Выбрать", click_function="buttonClick_setup", function_owner=self,
        position={0, buttonPositionY, -1}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })

    if(showOnlySelection == true) then return end

    self.createButton({
        label="Разложить", click_function="buttonClick_place", function_owner=self,
        position={0, buttonPositionY, 1}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })
    self.createButton({
        label="Сложить", click_function="buttonClick_recall", function_owner=self,
        position={0, buttonPositionY, 0}, height=buttonHeight, width=buttonWidth,
        font_size=buttonFontSize, color={0,0,0}, font_color={1,1,1}
    })
end

function buttonClick_place()
    local bagObjList = self.getObjects()
    for guid, entry in pairs(memoryList) do
        local obj = getObjectFromGUID(guid)
        if obj ~= nil then
            obj.setPositionSmooth(entry.pos)
            obj.setRotationSmooth(entry.rot)
            obj.setLock(entry.lock)
        else
            for _, bagObj in ipairs(bagObjList) do
                if bagObj.guid == guid then
                    local item = self.takeObject({
                        guid=guid, position=entry.pos, rotation=entry.rot,
                    })
                    item.setLock(entry.lock)
                    break
                end
            end
        end
    end
end

function buttonClick_recall()
    for guid, entry in pairs(memoryList) do
        local obj = getObjectFromGUID(guid)
        if obj ~= nil then self.putObject(obj) end
    end
end

function findOffsetDistance(p1, p2, obj)
    local deltaPos = {}
    local bounds = obj.getBounds()
    deltaPos.x = (p2.x-p1.x)
    deltaPos.y = (p2.y-p1.y) + (bounds.size.y - bounds.offset.y)
    deltaPos.z = (p2.z-p1.z)
    return deltaPos
end

function rotateLocalCoordinates(desiredPos, obj)
	local objPos, objRot = obj.getPosition(), obj.getRotation()
    local angle = math.rad(objRot.y)
	local x = desiredPos.x * math.cos(angle) - desiredPos.z * math.sin(angle)
	local z = desiredPos.x * math.sin(angle) + desiredPos.z * math.cos(angle)
    return {x=x, y=desiredPos.y, z=z}
end

function wait(time)
    local start = os.time()
    repeat coroutine.yield(0) until os.time() > start + time
end

function duplicateTable(oldTable)
    local newTable = {}
    for k, v in pairs(oldTable) do
        newTable[k] = v
    end
    return newTable
end

function round(num, dec)
  local mult = 10^(dec or 0)
  return math.floor(num * mult + 0.5) / mult
end
