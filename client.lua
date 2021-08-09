local nearestTrailer

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(1, 51) then

        	local trailer

        	for vehicle in EnumerateVehicles() do
				if GetEntityModel(vehicle) == GetHashKey("trailersmall") and (Vdist2(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(vehicle)) < 70) then 
					
					nearestTrailer = vehicle

		            trailerMenu:Visible(not trailerMenu:Visible())

				end
			end
        	
        end
    end
end)

function notify(msg) -- Function to send notification to player
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true,false)
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function attachCar()
	
	local trailer

	for vehicle in EnumerateVehicles() do
		if GetEntityModel(vehicle) == GetHashKey("trailersmall") and (Vdist2(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(vehicle)) < 70) then 
			
			trailer = vehicle

		end
	end


	-- print("Found trailer: "..trailer)

	local attached = false

	for vehicle in EnumerateVehicles() do
	
		if (Vdist2(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(vehicle)) < 10) and IsEntityAttachedToEntity(trailer, vehicle) then

			attached = true

		end

	end

	if attached then

		notify("There is already a vehicle attached to the trailer!")

	else

		local veh
		local dist = 0
		local smallestdist = 99999

		for vehicle in EnumerateVehicles() do

			dist = Vdist2(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(vehicle))

			print(vehicle.. ", ".. dist)

			if (dist < 10) and (dist < smallestdist) and not (GetEntityModel(vehicle) == GetHashKey("trailersmall")) then

				smallestdist = dist

				veh = vehicle

			end

		end

		if not (veh == nil) then

			AttachEntityToEntity(veh, trailer, 20, 0, -1.5, GetEntityHeightAboveGround(veh)-0.63, 0, 0, 0, false, false, true, false, 20, true)

		else

			notify("You moved to far away")

		end

	end
end

function detachCar()
	local veh

	for vehicle in EnumerateVehicles() do
	
		if (Vdist2(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(vehicle)) < 10) and not (GetEntityModel(vehicle) == GetHashKey("trailersmall")) and IsEntityAttached(vehicle) then

			veh = vehicle

		end

	end

	print(veh)

	SetEntityCoords(veh, GetEntityCoords(veh).x, GetEntityCoords(veh).y, GetEntityCoords(veh).x + 0.5, 0, 0, 0, false)

	DetachEntity(veh, true, true)
end


RegisterCommand("attachCar", function()

	attachCar()

end, false)

RegisterCommand("detachCar", function(source, args)

	detachCar()

end, false)

_menuPool = NativeUI.CreatePool()
trailerMenu = NativeUI.CreateMenu("Trailer Menu", "by SirChainsmokerGollum")
_menuPool:Add(trailerMenu)

rampDown = false

function AddMenuToggle(menu)
	
	local newitem = NativeUI.CreateCheckboxItem("Toggle Ramp", rampDown, "Toggle this")
	menu:AddItem(newitem)
	menu.OnCheckboxChange = function(sender, item, checked_)
		if item == newitem then

			rampDown = checked_

			if rampDown == true then 

				SetVehicleExtra(nearestTrailer, 3, 0)
				SetVehicleExtra(nearestTrailer, 2, 1)
				SetTrailerLegsRaised(nearestTrailer)


			else

				SetVehicleExtra(nearestTrailer, 3, 1)
				SetVehicleExtra(nearestTrailer, 2, 0)
				SetTrailerLegsRaised(nearestTrailer)

			end

		end
	end

end

function AddMenuItems(menu)
	
	local newitem1 = NativeUI.CreateItem("Attach", "Attach Vehicle to Trailer")
	local newitem2 = NativeUI.CreateItem("Detach", "Detach Vehicle from Trailer")
	menu:AddItem(newitem1)
	menu:AddItem(newitem2)
	menu.OnItemSelect = function(sender, item, index)
		
		if item == newitem1 then

			attachCar()

		elseif item == newitem2 then 

			detachCar()

		end

	end

end

AddMenuToggle(trailerMenu)

AddMenuItems(trailerMenu)

_menuPool:RefreshIndex()