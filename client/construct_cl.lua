

local consactivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false

local creatingshadow = false

local numb_of_objs = 0

local objs = {}

local shadow = nil

local constructed = {}

function OnKeyPress(key)
    if creatingshadow == false then
    if (key == "Y" and GetPlayerVehicle()==0) then
        consactivated = not consactivated
        if (consactivated == false) then
            shadow=nil
            CallRemoteEvent("RemoveShadow")
        end
    end
    if key == "Escape" then
        if consactivated then
            consactivated = false
            CallRemoteEvent("RemoveShadow")
            shadow=nil
        end
    end
    if key == "E" then
        if (consactivated == true) then
            remove_obj = not remove_obj
            if remove_obj then
                CallRemoteEvent("RemoveShadow")
                shadow=nil
            end
        end
    end
    if key == "Mouse Wheel Up" then
		curstruct = curstruct + 1
        curstruct = ((curstruct - 1) % numb_of_objs) + 1
    end
    if key == "Mouse Wheel Down" then
		curstruct = curstruct + 1
		curstruct = (curstruct % numb_of_objs) + 1
    end
    if key == "R" then
        if (currotyaw + 90 > 180) then
            currotyaw = -90
        else
            currotyaw = currotyaw + 90
        end
    end
    if key == "Left Mouse Button" then
        if consactivated then
            if (remove_obj==false) then
                local rotx , roty , rotz = GetObjectRotation(shadow.mapobjid)
                local ox, oy, oz = GetObjectLocation(shadow.mapobjid)
                CallRemoteEvent("Createcons",ox,oy,oz,rotx,roty)
                shadow=nil
            else
                local ScreenX, ScreenY = GetScreenSize()
                SetMouseLocation(ScreenX/2, ScreenY/2)
                local entityType, entityId = GetMouseHitEntity()
                local x,y,z = GetMouseHitLocation()
            if entityType==2 then
                local cx, cy, cz = GetCameraForwardVector()
                local ltx = x+cx*65
                local lty = y+cy*65
                local ltz = z+cz*65
                local eltx = x+cx*65+cx*10000
                local elty = y+cy*65+cy*10000
                local eltz = z+cz*65+cz*10000
                local hittype, hitid, impactX, impactY, impactZ = LineTrace(ltx,lty,ltz,eltx,elty,eltz,4)
                    entityType=hittype
                    entityId=hitid
            end
                if (entityId~=0) then
                	CallRemoteEvent("Removeobj",entityId)
                end
            end
        end
    end
end
end
AddEvent("OnKeyPress", OnKeyPress)
local lasthitposx = nil
local lasthitposy = nil
local lasthitposz = nil
local lastang = nil

local lastcons = nil

local lastconsactivated = nil

function tickhook(DeltaSeconds)
    if creatingshadow==false then
    if consactivated then
        if GetPlayerVehicle()==0 then
		local ScreenX, ScreenY = GetScreenSize()
		SetMouseLocation(ScreenX/2, ScreenY/2)
		if remove_obj == false then
		lastconsactivated = true
        local x,y,z = GetMouseHitLocation()
        local entityType, entityId = GetMouseHitEntity()
        if entityType==2 then
            local cx, cy, cz = GetCameraForwardVector()
            local ltx = x+cx*65
            local lty = y+cy*65
            local ltz = z+cz*65
            local eltx = x+cx*65+cx*10000
            local elty = y+cy*65+cy*10000
            local eltz = z+cz*65+cz*10000
            local hittype, hitid, impactX, impactY, impactZ = LineTrace(ltx,lty,ltz,eltx,elty,eltz,4)
                x=impactX
                y=impactY
                z=impactZ
                entityType=hittype
                entityId=hitid
                if entityType==2 then
                   x=0
                   y=0
                   z=0
                end
        end
			if (x ~= lasthitposx or y ~= lasthitposy or z ~= lasthitposz or lastang ~= currotyaw or lastconsactivated ~= consactivated or lastcons ~= curstruct) then
				lasthitposx = x
				lasthitposy = y
				lasthitposz = z
				lastang = currotyaw
				lastcons = curstruct
				lastconsactivated = true
                if (x ~= 0 and y ~= 0 and z ~= 0) then
                    local pitch,yaw,roll = GetCameraRotation()
                    if shadow==nil then
                    creatingshadow=true
                    CallRemoteEvent("CreateShadow", curstruct, currotyaw,x,y,z)
                    end
                    if shadow~=nil then
                        local conid = curstruct
                        local angle = currotyaw
                        local hitentity = entityId
                        if (shadow.objid==conid) then
                            --AddPlayerChat("X : " .. x .. " Y : " .. y .. " Z : " .. z .. " Angle : " .. angle)
                            if (conid == 1) then
                                local befangle = angle
                                if (angle == 180) then
                                    angle = 0
                                elseif (angle == -90) then
                                   angle = 90
                                end
                                local nofound = true
                                for k,v in ipairs(constructed) do -- IDK if you can read the code below
                                    if (v.mapobjid == hitentity and v.objid == 1) then
                                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                                         --Very bad precision when spawning on the server
                                        rotx = math.floor(rotx+0,5) -- i just can't understand , i need to do math.floor + 1 for the stairs and some if here and math.floors + 0.5
                                        roty = math.floor(roty+0,5) -- Be carrefull if you do custom dynamic placed objects with this weird angle values
                                        rotz = math.floor(rotz+0,5)
                                        if roty == -1 then
                                           roty = 0
                                        elseif roty == 89 then
                                            roty = 90

                                        end
                                        --AddPlayerChat(rotx..roty..rotz)
                                        local ox, oy, oz = GetObjectLocation(hitentity)
                                        nofound = false
                                        local valtoadd = 0
                                        if (roty == 90 or roty == -90) then
                                            if (y - oy > 300) then
                                                if (angle == 90) then
                                                    valtoadd = 600
                                                else
                                                    valtoadd = 600
                                                end
                                            else
                                                if (angle == 90) then
                                                    valtoadd = -600
                                                else
                                                    valtoadd = 0
                                                end
                                            end
                                        else
                                            if (x - ox > 300) then
                                                if (angle == 0) then
                                                    valtoadd = 600
                                                else
                                                     valtoadd = 600
                                                end
                                            else
                                                if (angle == 0) then
                                                    valtoadd = -600
                                                else
                                                    valtoadd = 0
                                                end
                                            end
                                        end
                                        x = ox
                                        y = oy
                                        z = oz
                                        if (befangle == 180 and roty == 90) then
                                            y = oy + valtoadd
                                            x = ox - 600
                                        elseif (befangle == -90 and roty == 0) then
                                            x = ox + valtoadd
                                            y = oy - 600
                                        elseif (roty == 0) then
                                            x = ox + valtoadd
                                        elseif (roty == 90) then
                                            y = oy + valtoadd
                                        end
                                    end
                                end
                                if (nofound == true) then
                                    if (angle == 0) then
                                       x = x - 300
                                    elseif (angle == 90) then
                                        y = y - 300
                                    end
                                end
                            end
                            if (conid == 2) then
                                z = z + 175
                                for k,v in ipairs(constructed) do
                                    if (v.mapobjid == hitentity and v.objid == 2) then
                                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                                         rotx = math.floor(rotx+1)
                                         roty = math.floor(roty+1)
                                         rotz = math.floor(rotz+1)
                                        local ox, oy, oz = GetObjectLocation(hitentity)
                                        local valtoadd = 0
                                        if (z - oz > 175) then
                                          z = oz + 350
                                          valtoadd = 350
                                        else
                                          z = oz - 350
                                          valtoadd = -350
                                        end
                                        x = ox
                                        y = oy
                                        angle = roty
                                        if (roty == 0) then
                                            x = ox + valtoadd
                                        elseif (roty == 90) then
                                            y = oy + valtoadd
                                        elseif (roty == 180) then
                                            x = ox + valtoadd * -1
                                        elseif (roty == -90) then
                                            y = oy + valtoadd * -1
                                        end
                                    end
                                end
                            end
                            if (conid == 3) then
                                z = z + 25
                                for k, v in ipairs(constructed) do
                                    if (v.mapobjid == hitentity and v.objid == 3) then
                                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                                        local ox, oy, oz = GetObjectLocation(hitentity)
                                        local valtoadd = 0
                                        if (x - ox > 0 and y - oy > 0) then
                                            if (x - ox > y - oy) then
                                                x = ox+500
                                                z = oz
                                                y = oy
                                            else
                                                x = ox
                                                z = oz
                                                y = oy + 500
                                            end
                                        elseif (x - ox < 0 and y - oy < 0) then
                                            if (x - ox < y - oy) then
                                                x = ox - 500
                                                z = oz
                                                y = oy
                                            else
                                                x = ox
                                                z = oz
                                                y = oy - 500
                                            end
                                        elseif (x - ox < 0) then
                                            if ((x - ox) * -1 > y - oy) then
                                                x = ox - 500
                                                z = oz
                                                y = oy
                                            else
                                                x = ox
                                                z = oz
                                                y = oy + 500
                                            end
                                        elseif (y - oy < 0) then
                                            if ((y - oy) * -1 > x - ox) then
                                                x = ox
                                                z = oz
                                                y = oy - 500
                                            else
                                                x = ox + 500
                                                z = oz
                                                y = oy
                                            end
                                        end
                                    end
                                end
                            end
                            local px, py, pz = GetPlayerLocation()
                            local dist = GetDistance3D(px, py, pz, x, y, z)
                            if (dist<10000) then
                                --AddPlayerChat("X2 : " .. x .. " Y2 : " .. y .. " Z2 : " .. z .. " Angle2 : " .. angle)
                                GetObjectActor(shadow.mapobjid):SetActorLocation(FVector(x, y, z))
                                local anglex = 0
                                if (conid == 2) then
                                    anglex = 45
                                end
                                GetObjectActor(shadow.mapobjid):SetActorRotation(FRotator(anglex, angle, 0))
                            else
                                AddPlayerChat("Too far from you")
                            end
                        else
                            CallRemoteEvent("CreateShadow", curstruct, currotyaw,x,y,z)
                            creatingshadow=true
                        end
                    end
                else
					AddPlayerChat("Please look at valid locations")
                    end
				end
            end
        end
    else
        consactivated=false
        CallRemoteEvent("RemoveShadow")
        shadow=nil
		end
	else
        lastconsactivated=false
    end
end
AddEvent("OnGameTick", tickhook)

local rtim = nil

function retry_timer()
    if IsValidObject(shadow.mapobjid) then
	    GetObjectActor(shadow.mapobjid):SetActorEnableCollision(false)
	    SetObjectCastShadow(shadow.mapobjid, false)
        EnableObjectHitEvents(shadow.mapobjid , false)
        GetObjectStaticMeshComponent(shadow.mapobjid):SetMobility(EComponentMobility.Movable)
        creatingshadow=false
        DestroyTimer(rtim)
    end
end

AddRemoteEvent("Createdobj", function(objid, collision)
    local delay = 50
    if (GetPing() ~= 0) then
        delay = GetPing() * 6
    end
    Delay(delay,function()
	    GetObjectActor(objid):SetActorEnableCollision(collision)
	    SetObjectCastShadow(objid, collision)
        EnableObjectHitEvents(objid , collision)
        if collision == true then
            GetObjectStaticMeshComponent(objid):SetMobility(EComponentMobility.Static)
        else
            GetObjectStaticMeshComponent(objid):SetMobility(EComponentMobility.Movable)
        end
    end)
end)

AddRemoteEvent("numberof_objects", function(number)
    numb_of_objs = number
end)

function render_cons()
    if consactivated then
	    DrawText(5, 400, "Press Y to toggle construction")
	    DrawText(5, 425, "Press E to toggle remove constructions")
	    DrawText(5, 450, "Press R to rotate your construction")
	    DrawText(5, 475, "Use the mouse wheel to change your object")
	    DrawText(5, 500, "Use the left click to place your object")
	    if remove_obj then
            local entityType, entityId = GetMouseHitEntity()
            local x,y,z = GetMouseHitLocation()
            if entityType==2 then
                local cx, cy, cz = GetCameraForwardVector()
                local ltx = x+cx*65
                local lty = y+cy*65
                local ltz = z+cz*65
                local eltx = x+cx*65+cx*10000
                local elty = y+cy*65+cy*10000
                local eltz = z+cz*65+cz*10000
                local hittype, hitid, impactX, impactY, impactZ = LineTrace(ltx,lty,ltz,eltx,elty,eltz,4)
                    entityType=hittype
                    entityId=hitid
            end
            if (entityId ~= 0) then
                local x, y, z = GetObjectLocation(entityId)
                local bResult, ScreenX, ScreenY = WorldToScreen(x, y, z)
                if bResult then
                    DrawText(ScreenX - 40, ScreenY, "Left Click to remove")
                end
            end
    	end
    end
end
AddEvent("OnRenderHUD", render_cons)



AddRemoteEvent("objs_table_cons",function(tbl)
    objs = tbl
end)

AddRemoteEvent("created_shadow_tbl",function(tbl_obj)
    shadow=tbl_obj
    local delay = 50
    if (GetPing() ~= 0) then
        delay = GetPing() * 6
    end
    Delay(delay,function()
        if IsValidObject(shadow.mapobjid) then
	    GetObjectActor(shadow.mapobjid):SetActorEnableCollision(false)
	    SetObjectCastShadow(shadow.mapobjid, false)
        EnableObjectHitEvents(shadow.mapobjid , false)
        GetObjectStaticMeshComponent(shadow.mapobjid):SetMobility(EComponentMobility.Movable)
        creatingshadow=false
        else
            rtim = CreateTimer(retry_timer, 100)
    end
    end)
end)

AddRemoteEvent("Constructed_sync",function(constr_tbl)
    constructed=constr_tbl
end)
