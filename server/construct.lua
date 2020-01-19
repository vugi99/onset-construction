local remove_objs_cons = true -- does the mod remove all objects created by the player who quit the game

local objs = {}

objs[1] = 240 --Don't change this line
objs[2] = 387 --Don't change this line
objs[3] = 387 --Don't change this line
--objs[4] = 1003
--objs[index] = object id -- https://dev.playonset.com/wiki/Objects


local admins_remove = {}

--admins_remove["76561197972837186"] = true -- me
--admins_remove["steamid"] = true

local pitchstairs = 45

local constructed = {}

local shadows = {}

function rshadow(ply)
    if (shadows[ply]) then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows, ply)
    end
 end

 AddRemoteEvent("RemoveShadow",rshadow)

function OnPlayerQuit(ply)
    rshadow(ply)
    if (remove_objs_cons == true) then
        local steamid = tostring(GetPlayerSteamId(ply))

        local index = 1 -- DjCtavia#3870

        while index < #constructed + 1 do
            if (constructed[index].owner == steamid) then
                DestroyObject(constructed[index].mapobjid)
                table.remove(constructed, index)
                index = index - 1
            end
            index = index + 1
        end
        for k,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v, "Constructed_sync", constructed)
        end
    end
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function Createobj(ply,x,y,z,rotx,roty)
    if (shadows[ply]) then
        local objtocreate = shadows[ply].mapobjid
        SetObjectLocation(objtocreate,x,y,z)
        SetObjectRotation(objtocreate,rotx,roty,0)
        local tbltoinsert = {}
        tbltoinsert.mapobjid = shadows[ply].mapobjid
        tbltoinsert.objid = shadows[ply].objid
        tbltoinsert.owner = tostring(GetPlayerSteamId(ply))
        table.insert(constructed,tbltoinsert)
        CallRemoteEvent(ply, "Createdobj", shadows[ply].mapobjid, true)
        for k,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v, "Constructed_sync", constructed)
        end
        table.remove(shadows, ply)
    end
end

AddRemoteEvent("Createcons", Createobj)

function OnPlayerSpawn(ply)
    CallRemoteEvent(ply, "numberof_objects", #objs)
    CallRemoteEvent(ply,"objs_table_cons",objs)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)

function Removeobj(ply,hitentity)
    local steamid = tostring(GetPlayerSteamId(ply))
    for i,v in ipairs(constructed) do
        if (hitentity==v.mapobjid) then
            if (v.owner == steamid or admins_remove[steamid]) then
                DestroyObject(hitentity)
                table.remove(constructed,i)
                for k,v in ipairs(GetAllPlayers()) do
                    CallRemoteEvent(v, "Constructed_sync", constructed)
                end
            else
                AddPlayerChat(ply,"You can't remove this object")
            end
        end
    end
end
AddRemoteEvent("Removeobj", Removeobj)

function CreateShadow(ply,conid,angle,x,y,z)
    if shadows[ply] then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows,ply)
    end
    local anglex = 0
    local size = 1
    if (conid == 1) then
        size = 2
        if (angle == 180) then
            angle = 0
            x = x - 300
        elseif (angle == -90) then
           angle = 90
           y = y - 300
        elseif (angle == 90) then
            y = y - 300
        elseif (angle == 0) then
            x = x - 300
        end
    end
    if (conid == 2) then
        anglex = 45
        size = 0.25
        z = z + 175
    end
    if (conid == 3) then
        size = 0.25
        z = z + 25
    end
    local identifier = CreateObject(objs[conid], x, y, -1000 , anglex, angle, 0, size, size, size)
    if (identifier~=false) then
        shadows[ply] = {}
        shadows[ply].objid = conid
        shadows[ply].mapobjid = identifier
        CallRemoteEvent(ply,"created_shadow_tbl",shadows[ply])
        --[[for k,v in ipairs(GetAllPlayers()) do
           CallRemoteEvent(v,"Createdobj",identifier,false)
        end]]--
    else
        print("Error at CreateObject Construction mod")
    end
end
AddRemoteEvent("CreateShadow",CreateShadow)
