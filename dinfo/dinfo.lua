_addon.author   = 'Zuri';
_addon.name     = 'dinfo';
_addon.version  = '0.0.1';

require 'common'
require 'ffxi.targets'

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
        bgcolor     = 0x80000000,
        bgvisible   = true
    }
};
local dinfo_config = default_config;

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the fps configuration..
    dinfo_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', dinfo_config);

    -- Create our font object..
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

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
-- ashita.register_event('incoming_packet', function(id, size, data)

--     -- PC or NPC update packet
--     if (id == 0x00D or id == 0x00E) then
--         local packet = data:totable()
--         local id = packet[0x04]
--         local index = packet[0x08]
--         local pos = packet[0x0C]
--         local rot = packet[0x0B]
--         local status = packet[0x1F]
--         local hpp = packet[0x1E]

--         -- PC specific info
--         if (id == 0x00D) then
--             local movespeed = packet[0x1C]
--         end

--         -- NPC specific info
--         if (id == 0x00E) then
--             local modelId = packet[0x32]
--             local claimId = packet[0x2C]
--         end

--     end


--     return false;
-- end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__dinfo_addon');
    if (f == nil) then return; end

    local pentity   = AshitaCore:GetDataManager():GetEntity();
    local player    = AshitaCore:GetDataManager():GetPlayer();
    local target    = AshitaCore:GetDataManager():GetTarget();
    local tentity   = GetEntity(target:GetTargetIndex())
    local party     = AshitaCore:GetDataManager():GetParty();
    local zoneId    = party:GetMemberZone(0);
    local zoneName  = AshitaCore:GetResourceManager():GetString('areas', zoneId);

    -- TODO: Zone name, id, and weather, maybe timestamp?

    local staticInfo = zoneName .. ' (' .. zoneId .. ')';

    local targetInfo;

    -- Ensure we have a valid target..
    local target = ashita.ffxi.targets.get_target('t');
    if (target == nil or target.Name == '' or target.TargetIndex == 0) then
        targetInfo = ''
    else
        -- TODO: change color of output below based on npc/player/mob (use existing targetType enum?)

        -- Append the name..
        targetInfo = string.format('\n %s', target.Name);
        
        -- Append the server id (decimal)..
        targetInfo = string.format(' %s [%d]', targetInfo, target.ServerId);

        -- Append the target's position
        -- tposX = AshitaCore:GetDataManager():GetTarget()GetPositionX();

        targetInfo = string.format('%s \n (%.3f %.3f %.3f), R%i', targetInfo, 
            tentity.Movement.LocalPosition.X, 
            tentity.Movement.LocalPosition.Y, 
            tentity.Movement.LocalPosition.Z, 
            0);
    end
    
    -- Update the text..
    str = string.format(' %s %s', staticInfo, targetInfo);
    f:SetText(str);
end);
