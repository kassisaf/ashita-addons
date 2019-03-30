_addon.author   = 'Zuri';
_addon.name     = 'dinfo';
_addon.version  = '0.0.1';

require 'common'

----------------------------------------------------------------------------------------------------
-- Configurations
----------------------------------------------------------------------------------------------------
local default_config = 
{
    font =
    {
        family      = 'Arial',
        size        = 10,
        color       = 0xFFFFFFFF,
        position    = { -700, 165 },
        bgcolor     = 0x60000000,
        bgvisible   = true
    },
    useLocalPos = true;
};
local dinfo_config = default_config;

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the config file
    dinfo_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', dinfo_config);

    -- Create our font object
    local f = AshitaCore:GetFontManager():Create('__dinfo_addon');
    f:SetColor(dinfo_config.font.color);
    f:SetFontFamily(dinfo_config.font.family);
    f:SetFontHeight(dinfo_config.font.size);
    f:SetBold(false);
    f:SetPositionX(dinfo_config.font.position[1]);
    f:SetPositionY(dinfo_config.font.position[2]);
    f:SetVisibility(true);
    f:GetBackground():SetColor(dinfo_config.font.bgcolor);
    f:GetBackground():SetVisibility(dinfo_config.font.bgvisible);

    useLocalPos = dinfo_config.useLocalPos;

end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():Get('__dinfo_addon');
    dinfo_config.font.position = { f:GetPositionX(), f:GetPositionY() };
        
    -- Save the configuration..
    ashita.settings.save(_addon.path .. 'settings/settings.json', dinfo_config);
    
    -- Unload our font object..
    AshitaCore:GetFontManager():Delete('__dinfo_addon');
end );


----------------------------------------------------------------------------------------------------
-- func: getRotation
-- desc: Returns the current heading of an entity in degrees
----------------------------------------------------------------------------------------------------
local function getRotation(entity, index)
    local yaw;
    if (useLocalPos) then
        yaw = entity:GetLocalYaw(index)
    else
        yaw = entity:GetLastYaw(index)
    end

    local degrees = yaw * (180/math.pi) + 90
    -- Correct for negative yaw
    if (degrees > 360) then
        degrees = degrees - 360;
    elseif (degrees < 0) then
        degrees = degrees + 360;
    end

    return degrees;
end

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Get the font object
    local f = AshitaCore:GetFontManager():Get('__dinfo_addon');
    if (f == nil) then return; end

    -- Set up some variables for the info we'll want to display
    local Entity    = AshitaCore:GetDataManager():GetEntity();
    local party     = AshitaCore:GetDataManager():GetParty();
    -- Zone info
    local zoneId    = party:GetMemberZone(0);
    local zoneName  = AshitaCore:GetResourceManager():GetString('areas', zoneId);
    local zoneInfo  = string.format("%s (%s)", zoneName, zoneId)

    -- Target info
    local target    = AshitaCore:GetDataManager():GetTarget();
    local targetInfo;

    -- Target info should be blank unless we have a valid target
    if not (target:GetTargetEntityPointer() == nil 
        or target:GetTargetName() == nil
        or target:GetTargetServerId() == 0 ) then

        local tIndex    = target:GetTargetIndex()
        local tEntity   = GetEntity(tIndex)
        local tPos;
        if (useLocalPos) then
            tPos = {
                X = Entity:GetLocalX(tIndex),
                Y = Entity:GetLocalY(tIndex),
                Z = Entity:GetLocalZ(tIndex),
                R = getRotation(Entity, tIndex)
            }
        else
            tPos = {
                X = Entity:GetLastX(tIndex),
                Y = Entity:GetLastY(tIndex),
                Z = Entity:GetLastZ(tIndex),
                R = getRotation(Entity, tIndex)
            }
        end

        -- TODO: change color of output below based on npc/player/mob (use existing targetType enum?)
        targetInfo = string.format("T: %s [%i]", target:GetTargetName(), target:GetTargetServerId());
        targetInfo = string.format("%s\n(%.3f, %.3f, %.3f) R%i", targetInfo, tPos.X, tPos.Y, tPos.Z, tPos.R);
    end

    local output = zoneInfo;
    if (targetInfo ~= nil) then
        output = string.format("%s\n%s", output, targetInfo);
    end

    f:SetText(output);
end);
