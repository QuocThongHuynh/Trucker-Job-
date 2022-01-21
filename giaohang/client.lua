ESX = nil
CurrentBlip = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    TriggerEvent('esx:registerMarker', 17, Config.RentVehicle)
    for k,v in pairs(Config.TakeItemLocation) do 
        TriggerEvent('esx:registerMarker', 14, v)
    end 
    TriggerEvent('esx:registerMarker', 17, Config.StopDelivery)
    local blip = AddBlipForCoord(Config.RentVehicle)
    SetBlipSprite(blip, 477)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('[~y~Lái xe tải~s~] Nơi Làm Việc')
    EndTextCommandSetBlipName(blip)
end)

local uiOpen = false
local CurrentData = {}
local TakeItem = false
function OpenUI()
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'display',
        show = true,
        vehicle = Config.VehicleData
    })
end

function CloseUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'display',
        show = false,
    })
end

RegisterNUICallback('escape', function(data, cb)
    CloseUI()
end)

RegisterNUICallback('rentveh', function(name)
    TakeItem = false
    local playerPed = PlayerPedId()
    for k,v in pairs(Config.SpawnVehicleLocation) do
        if ESX.Game.IsSpawnPointClear(v.coords, 4.0) then 
            ESX.Game.SpawnVehicle(name, v.coords, v.heading ,function(vehicle)
                exports['qt-vehiclekeys']:SetVehicleKey(GetVehicleNumberPlateText(vehicle), true)
                CurrentData = {vehicle = vehicle, vehname = name}
                SetNewWaypoint(v.coords)
                ESX.ShowNotification('hãy ra bãi để nhận xe')
                CloseUI()
                while true do 
                    Wait(1)
                    local PlayerPed = PlayerPedId()
                    if IsPedInVehicle(PlayerPed, CurrentData.vehicle, true) then
                        SetNewWaypoint(Config.TakeItemLocation[1])
                        break
                    else
                        local VehicleCoords = GetEntityCoords(CurrentData.vehicle)
                        DrawMarker(0, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z + 5.0, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(2.0, 2.0, 2.0), 0, 255, 0, 150, true, true, 2, false, false, false)
                    end
                end
            end)
            return
        end
    end
    ESX.ShowNotification('Khu vực đỗ xe đang quá tải')
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        if uiOpen then 
            SetNuiFocus(false, false)
        end
    end
end)

function StartDelivery(type, count)
    TriggerServerEvent('GiaoHang:SetDeliveryVehicle', GetVehicleNumberPlateText(CurrentData.vehicle), type)
    CurrentData.CountDelivery = count
    CurrentData.MaxCountDelivery = count
    local tablecoords = Config.DeliveryLocation[type].coords
    local randomcoords = math.random(1, #tablecoords)
    CurrentData.CurrentDelivery = tablecoords[randomcoords]
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end
    CurrentBlip = AddBlipForCoord(CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z)
	SetBlipRoute(CurrentBlip, 1)
    local breaked = true
    local Waiting = false
    while breaked do 
        Wait(1)
        local MyCoords = GetEntityCoords(PlayerPedId())
        local Distance = GetDistanceBetweenCoords(MyCoords, CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z, true)
        if Distance < 50 then
            DrawMarker(1, CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(2.0, 2.0, 2.0), 0, 255, 0, 150, true, true, 2, false, false, false)
            if Distance < 2 then
                ESX.ShowHelpNotification('Nhấn [~g~E~s~] để giao hàng')
                if IsControlJustPressed(0, 38) and not Waiting then
                    Waiting = true
                    DeliveryItem(tablecoords, function(done)
                        Waiting = false
                        if done then
                            breaked = false
                        end
                    end)
                end
            end
        else
            Wait(500)
        end
    end
end

function NextDelivery(tablecoords)
    local randomcoords = math.random(1, #tablecoords)
    while tablecoords[randomcoords].x == CurrentData.CurrentDelivery.x do 
        randomcoords = math.random(1, #tablecoords)
        Wait(0)
    end
    CurrentData.CurrentDelivery = tablecoords[randomcoords]
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end
    CurrentBlip = AddBlipForCoord(CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z)
	SetBlipRoute(CurrentBlip, 1)
    local breaked = true
    local Waiting = false
    while breaked do 
        Wait(1)
        local MyCoords = GetEntityCoords(PlayerPedId())
        local Distance = GetDistanceBetweenCoords(MyCoords, CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z, true)
        if Distance < 50 and not Waiting then
            DrawMarker(1, CurrentData.CurrentDelivery.x, CurrentData.CurrentDelivery.y, CurrentData.CurrentDelivery.z, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(2.0, 2.0, 2.0), 0, 255, 0, 150, true, true, 2, false, false, false)
            if Distance < 2 then
                ESX.ShowHelpNotification('Nhấn [~g~E~s~] để giao hàng')
                if IsControlJustPressed(0, 38) then
                    Waiting = true
                    DeliveryItem(tablecoords, function(done)
                        Waiting = false
                        if done then 
                            breaked = false
                        end
                    end)
                end
            end
        else
            Wait(500)
        end
    end
end

function DeliveryItem(tablecoords, cb)
    if CurrentData.CountDelivery > 0 then 
        local PlayerPed = PlayerPedId()
        local Vehicle = GetVehiclePedIsIn(PlayerPed, false)
        if Vehicle == CurrentData.vehicle then 
            CurrentData.CountDelivery = CurrentData.CountDelivery - 1
            FreezeEntityPosition(CurrentData.vehicle, true)
            TriggerEvent("mythic_progbar:client:progress", {
                name = "takeiteminlocation",
                duration = 10000,
                label = "Đang giao hàng",
                useWhileDead = false,
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                },
                animation = {
                    animDict = "",
                    anim = "",
                },
                prop = {
                    model = "",
                }
            }, function(status)
                FreezeEntityPosition(CurrentData.vehicle, false)
                cb(true)
                if CurrentData.CountDelivery > 0 then
                    NextDelivery(tablecoords)
                else
                    StopDelivery()
                end
            end)
        else
            ESX.ShowNotification('Bạn phải đi xe của bạn để thực hiện việc này')
            cb(false)
        end
    else
        ESX.ShowNotification('Bạn đã giao hết hàng, hãy về trả xe')
    end
end

function StopDelivery()
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end
    SetNewWaypoint(Config.StopDelivery)
    local breaked = true
    while breaked do 
        Wait(1)
        local PlayerPed = PlayerPedId()
        local MyCoords = GetEntityCoords(PlayerPed)
        local Distance = GetDistanceBetweenCoords(MyCoords, Config.StopDelivery.x, Config.StopDelivery.y, Config.StopDelivery.z, true)    
        if Distance < 2 then
            ESX.ShowHelpNotification('Nhấn [~g~E~s~] để trả xe')
            if IsControlJustPressed(0, 38) then 
                local Vehicle = GetVehiclePedIsIn(PlayerPed, false)
                local VehicleHeath = GetEntityHealth(Vehicle)/10
                if Vehicle == CurrentData.vehicle then 
                    local MoneyMinus = math.floor((100 - VehicleHeath)*500)
                    DeleteEntity(Vehicle)
                    TriggerServerEvent('GiaoHang:DoneJob', MoneyMinus, CurrentData.MaxCountDelivery, CurrentData.DeliveryType)
                    breaked = false
                else
                    ESX.ShowNotification('Đây không phải xe của bạn')
                end
            end
        else
            Wait(500)
        end
    end
end

function SelectTypeItem(vehicle)
    for k,v in pairs(Config.VehicleData) do 
        if v.name == vehicle then 
            local elements = {}
            for k2, v2 in pairs(Config.DeliveryLocation) do
                table.insert(elements, {label = v2.label, value = k2, time = v2.time})
            end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), '', {
                title    = 'Chọn loại hàng hóa bạn muốn vận chuyển',
                align    = 'right',
                elements = elements
            }, function(data, menu)
                if data.current.value == 'hangcam' then
                    menu.close()
                    ESX.TriggerServerCallback('api:countjob', function(cb)
                        if cb >= 0 then
                            TakeItem = true
                            FreezeEntityPosition(CurrentData.vehicle, true)
                            TriggerEvent("mythic_progbar:client:progress", {
                                name = "takeitem-giaohang",
                                duration = v.time,
                                label = "Đang lấy hàng",
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = {
                                    disableMovement = false,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = false,
                                },
                                animation = {
                                    animDict = "",
                                    anim = "",
                                },
                                prop = {
                                    model = "",
                                }
                            }, function(status)
                                FreezeEntityPosition(CurrentData.vehicle, false)
                                ESX.ShowNotification('Lấy hàng ~g~thành công~s~. Hãy đi giao hàng đến những vị trí được giao')
                                CurrentData.DeliveryType = data.current.value
                                
                                if CurrentData.DeliveryType == 'hangcam' then
                                    StartDelivery(CurrentData.DeliveryType, v.counthc)
                                else
                                    StartDelivery(CurrentData.DeliveryType, v.countbt)
                                end
                            end)
                        else
                            ESX.ShowNotification('Yêu cầu 3 cảnh sát Online để làm việc này')
                        end
                    end, 'police')
                else
                    TakeItem = true
                    menu.close()
                    FreezeEntityPosition(CurrentData.vehicle, true)
                    TriggerEvent("mythic_progbar:client:progress", {
                        name = "takeitem-giaohang",
                        duration = v.time,
                        label = "Đang lấy hàng",
                        useWhileDead = false,
                        canCancel = false,
                        controlDisables = {
                            disableMovement = false,
                            disableCarMovement = false,
                            disableMouse = false,
                            disableCombat = false,
                        },
                        animation = {
                            animDict = "",
                            anim = "",
                        },
                        prop = {
                            model = "",
                        }
                    }, function(status)
                        FreezeEntityPosition(CurrentData.vehicle, false)
                        ESX.ShowNotification('Lấy hàng ~g~thành công~s~. Hãy đi giao hàng đến những vị trí được giao')
                        CurrentData.DeliveryType = data.current.value
                        
                        if CurrentData.DeliveryType == 'hangcam' then
                            StartDelivery(CurrentData.DeliveryType, v.counthc)
                        else
                            StartDelivery(CurrentData.DeliveryType, v.countbt)
                        end
                    end)
                end
                
            end, function(data, menu)
                menu.close()
            end)
            return
        end
    end
end

Citizen.CreateThread(function()
    while true do 
        Wait(1)
        local MyCoords = GetEntityCoords(PlayerPedId())
        if CurrentData ~= nil and CurrentData.vehicle ~= nil and not TakeItem then 
            for k,v in pairs(Config.TakeItemLocation) do 
                local Distance2 = GetDistanceBetweenCoords(MyCoords, v, true)
                if Distance2 < 3 then 
                    ESX.ShowHelpNotification('Nhấn [~g~E~s~] để lấy hàng')
                    if IsControlJustPressed(0, 38) then 
                        SelectTypeItem(CurrentData.vehname)
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(1)
        local MyCoords = GetEntityCoords(PlayerPedId())
        local Distance = GetDistanceBetweenCoords(MyCoords, Config.RentVehicle, true)
        if Distance < 1.5 then 
            ESX.ShowHelpNotification('Nhấn [E] để thuê xe')
            if IsControlJustPressed(0, 38) then
                ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
                    -- if hasDriversLicense then
                        OpenUI()
                    -- else
                    --     ESX.ShowNotification('Hãy đi thi bằng lái xe để làm công việc này')
                    -- end
                end, GetPlayerServerId(PlayerId()), 'drive_truck')
            end
        else
            Wait(500)
        end
    end
end)