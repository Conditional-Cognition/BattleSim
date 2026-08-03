nameplate.ENTITY:setOutline(true)

--// "TABBED OUT" / "IN AN INVENTORY" //--
skullTexture = 1

function events.RENDER()
    models.notifierSkull.Skull:setPrimaryTexture("Custom", textures["Skull"..skullTexture])
end

local statusTabbedOut = false
local statusInInventory = false
local lastFocused = true
local lastContainer = false

local statusRoot = models:newPart("StatusRoot", "Billboard")
local statusText = statusRoot:newText("StatusText")
    :setPos(0, 80, 0)
    :setOutline(true)
    :setLight(15, 15)
    :setVisible(false)
    :setScale(0.5, 0.5, 0.5)
    :setAlignment("CENTER")

local statusSkullAnchor = models:newPart("StatusSkullAnchor", "Skull")
local statusBillboard = statusSkullAnchor:newPart("StatusBillboard", "Camera")

local skullNameText = statusBillboard:newText("SkullNameText")
    :setPos(0, 16, 0)
    :setOutline(true)
    :setLight(15, 15)
    :setScale(0.5, 0.5, 0.5)
    :setAlignment("CENTER")
    :setVisible(true)

local skullStatusText = statusBillboard:newText("SkullStatusText")
    :setPos(0, 28, 0)
    :setOutline(true)
    :setLight(15, 15)
    :setScale(0.5, 0.5, 0.5)
    :setAlignment("CENTER")
    :setVisible(false)

function events.ENTITY_INIT()
    skullNameText:setText(player:getName())
end

local function updateStatusDisplay()
    local lines = {}
    if statusTabbedOut then table.insert(lines, "§7(tabbed out)") end
    if statusInInventory then table.insert(lines, "§7(in an inventory)") end

    if #lines > 0 then
        local text = table.concat(lines, "\n")
        statusText:setText(text):setVisible(true)
        skullStatusText:setText(text):setVisible(true)
    else
        statusText:setVisible(false)
        skullStatusText:setVisible(false)
    end

    if statusTabbedOut then
        nameplate.LIST:setText(player:getName() .. " §7(tabbed out)")
    else
        nameplate.LIST:setText(nil)
    end
end

function pings.updateStatus(tabbedOut, inInventory)
    statusTabbedOut = tabbedOut
    statusInInventory = inInventory
    updateStatusDisplay()
end

function events.TICK()
    if not host:isHost() then return end

    local focused = client.isWindowFocused()
    local container = host:isContainerOpen()

    if focused ~= lastFocused or container ~= lastContainer then
        lastFocused = focused
        lastContainer = container
        pings.updateStatus(not focused, container)
    end

    if world:exists() and world:getTime() % 4 == 0 then
        skullTexture = 3 - skullTexture
    end
end
--// MADE BY Cdtnl_Cognition //--