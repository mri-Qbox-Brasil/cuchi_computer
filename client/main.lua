Framework = nil
CurrentResourceName = GetCurrentResourceName()
local duiObj = nil

SetTimeout(0, function()
    local success, result
    if Config.Framework == "esx" then
        success, result = pcall(function()
            if Config.FrameworkOptionalExportName ~= "" then
                return exports[Config.FrameworkResourceName][Config.FrameworkOptionalExportName]()
            end
            return exports[Config.FrameworkResourceName]:getSharedObject()
        end)
    elseif Config.Framework == "qbcore" then
        success, result = pcall(function()
            if Config.FrameworkOptionalExportName ~= "" then
                return exports[Config.FrameworkResourceName][Config.FrameworkOptionalExportName]()
            end
            return exports[Config.FrameworkResourceName]:GetCoreObject()
        end)
    end

    if success then
        Framework = result

        if Config.Framework == "qbcore" then -- standardization of framework functions
            Framework.TriggerServerCallback = Framework.Functions.TriggerCallback
        end
    else
        print("^1Error loading the framework.\n-> Check if you entered the good framework value and its resource name in ^7"..CurrentResourceName.."/config.lua")
    end

    TriggerServerEvent("cuchi_computer:getIdentifier")
end)

if Config.UseItem and Config.UseItem ~= "" then
    CreateThread(function()
        Wait(10000) -- needed wait (todo: find a better way..)
        local txd = CreateRuntimeTxd("cuchi_computer")
        duiObj = CreateDui("https://cfx-nui-"..CurrentResourceName.."/assets/screen.gif", 256, 256)

        while not IsDuiAvailable(duiObj) do
            Wait(0)
        end

        local dui = GetDuiHandle(duiObj)
        CreateRuntimeTextureFromDuiHandle(txd, "screen", dui)
        AddReplaceTexture("prop_laptop_lester2", "script_rt_tvscreen", "cuchi_computer", "screen")
    end)
end

if #Config.UsablePositions > 0 then
    CreateThread(function()
        while true do
            if UIOpen then
                Wait(500)
                goto skip
            end

            local playerPedId = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPedId)

            local nearestDistance
            local nearestIndex = 0
            for i = 1, #Config.UsablePositions, 1 do
                local currentDistance = #(playerCoords - Config.UsablePositions[i])
                if not nearestDistance or currentDistance < nearestDistance then
                    nearestDistance = currentDistance
                    nearestIndex = i
                end
            end

            if nearestDistance and nearestDistance < 2.0 then
                CustomDrawMarker(Config.UsablePositions[nearestIndex])
                CustomHelpNotification(GetLocale("start_computer"))

                if IsControlJustPressed(0, 51) then
                    OpenUI(Config.UsablePositions[nearestIndex])
                end
                Wait(0)
            else
                Wait(500)
            end

            ::skip::
        end
    end)
end

RegisterNetEvent("cuchi_computer:getIdentifier", function(identifier)
    SendNUIMessage({
        type = "identifier",
        identifier = identifier
    })
end)

local computerDict = "anim@scripted@ulp_missions@computerhack@heeled@"
local computerpName = "hacking_loop"

local laptopDict = "missfam6leadinoutfam_6_mcs_1"
local laptopName = "leadin_loop_c_laptop_girl"
local laptopPropName = joaat("prop_laptop_lester2")
local laptopProp = 0

local shouldStop = false

---Start animation and loop to check coords
---@param laptop boolean
---@param openCoords vector3
function StartAnimationAndCheck(laptop, openCoords)
    shouldStop = false
    local dict = computerDict
    local anim = computerpName

    if laptop then
        dict = laptopDict
        anim = laptopName

        RequestModel(laptopPropName)
        while not HasModelLoaded(laptopPropName) do
            Wait(0)
        end

        laptopProp = CreateObject(laptopPropName, 0, 0, 0, true, true, true)
        SetModelAsNoLongerNeeded(laptopPropName)
        AttachEntityToEntity(laptopProp, PlayerPedId(), 11816, 0.0, 0.42, 0.26, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    local it = 10
    while not shouldStop do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local distance = #(coords - openCoords)
        -- max distance of 2m for computers and 10m for laptops
        if (not laptop and distance > 2) or distance > 10 then
            SendNUIMessage({
                type = "force-close"
            })
        end

        if it >= 10 then -- only each 2000ms
            TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 17, 0, false, false, false)
            it = 0
        end

        it += 1
        Wait(200)
    end

    RemoveAnimDict(dict)
end

function StopAnimation(laptop)
    shouldStop = true
    local dict = computerDict
    local anim = computerpName

    if laptop then
        dict = laptopDict
        anim = laptopName

        DeleteObject(laptopProp)
        laptopProp = 0
    end

    StopEntityAnim(PlayerPedId(), anim, dict, 0)
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == CurrentResourceName then
        if laptopProp ~= 0 then
            DeleteObject(laptopProp)
            ClearPedTasks(PlayerPedId())

            if duiObj then
                DestroyDui(duiObj)
            end
        end
    end
end)
