ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Delivery = {}

RegisterServerEvent('GiaoHang:DoneJob')
AddEventHandler('GiaoHang:DoneJob', function(MoneyMinus, MaxJob, type)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local Money = Config.MoneyDelivery*MaxJob - MoneyMinus
	if type == 'hangcam' then
		local roll = math.random(3,4)
		xPlayer.addExp(2000)
		Money = Money*roll
		xPlayer.addInventoryItem(GetCurrentResourceName(), 'star', 2)
		xPlayer.addAccountMoney(GetCurrentResourceName(), 'black_money', Money)
		if MaxJob == 4 then
			local NhanPham = math.random(0, 100)
			if NhanPham > 95 then
				xPlayer.addInventoryItem(GetCurrentResourceName(), 'star', 2)
				xPlayer.showNotification('Bạn nhận được ~g~2 ngôi sao')
			end
			if NhanPham > 70 then
				xPlayer.addInventoryItem(GetCurrentResourceName(), 'bulletproof', 1)
			elseif NhanPham > 30 then 
				xPlayer.addInventoryItem(GetCurrentResourceName(), 'medikit', 2)
			else
				xPlayer.addInventoryItem(GetCurrentResourceName(), 'bandage', 5)
			end
		end
	else
		local NhanPham = math.random(0, 100)
		if NhanPham > 95 then
			xPlayer.addInventoryItem(GetCurrentResourceName(), 'star', 1)
			xPlayer.showNotification('Bạn nhận được ~g~1 ngôi sao')
		end
		xPlayer.addExp(1500)
		xPlayer.addMoney(GetCurrentResourceName(), Money)
	end
	xPlayer.showNotification('Bạn bị trừ ~r~$~g~'.. MoneyMinus .. '~s~ để sửa xe')
end)
	

RegisterServerEvent('GiaoHang:SetDeliveryVehicle')
AddEventHandler('GiaoHang:SetDeliveryVehicle', function(plate, type)
	Delivery[plate] = type
end)

RegisterServerEvent('GiaoHang:GetDeliveryVehicle')
AddEventHandler('GiaoHang:GetDeliveryVehicle', function(vehicle)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Delivery[vehicle] == 'hangcam' or Delivery[vehicle] == 'vukhi' then
		xPlayer.showNotification('Xe này đang vận chuyển hàng hóa ~r~bất hợp pháp')
	else
		xPlayer.showNotification('Xe này đang vận hàng hóa ~g~hợp pháp')
	end
end)