-- This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
-- https://creativecommons.org/licenses/by-nc/4.0/

_addon.author   = 'Zuri';
_addon.name     = 'reminder';
_addon.version  = '0.0.1';

require 'common'
--require 'ffxi.recast'

-- TODO: all jobs: Read/display number of exp band charges
-- TODO: all jobs: Add timer after exp band use if charges remain
-- TODO: all jobs: Listen for packet that confirms dedication buff gain/loss
-- TODO: all jobs: Add reminder to use ring when charges remain, cooldown is ready, and dedication is down
-- TODO: all jobs: Add alert when food wears
-- TODO: all jobs: Add alert when poison buff wears after using a poison pot
-- TODO: all jobs: Check if job has access to reraise and it is not up
-- TODO: all jobs: Check if job has access to stoneskin and it is not up
-- TODO: if THF m/s, Read steal cooldown and alert when it's usable [in dynamis]
-- TODO: if SAM m/s, Read meditate cooldown and alert when it's usable
-- TODO: if SAM m/s, Read hasso/seigan cooldown and alert when neither are active and either are available
-- TODO: if RDM m, Read refresh self status and alert when it's down
-- TODO: if SMN m/s, alert when resting with pet out
-- TODO: add Japanese language support

----------------------------------------------------------------------------------------------------
-- Enums
----------------------------------------------------------------------------------------------------
JOBS = {
    [0]  = {id=0,  en='NON', jp=""},
    [1]  = {id=1,  en='WAR', jp="戦"},
    [2]  = {id=2,  en='MNK', jp="モ"},
    [3]  = {id=3,  en='WHM', jp="白"},
    [4]  = {id=4,  en='BLM', jp="黒"},
    [5]  = {id=5,  en='RDM', jp="赤"},
    [6]  = {id=6,  en='THF', jp="シ"},
    [7]  = {id=7,  en='PLD', jp="ナ"},
    [8]  = {id=8,  en='DRK', jp="暗"},
    [9]  = {id=9,  en='BST', jp="獣"},
    [10] = {id=10, en='BRD', jp="詩"},
    [11] = {id=11, en='RNG', jp="狩"},
    [12] = {id=12, en='SAM', jp="侍"},
    [13] = {id=13, en='NIN', jp="忍"},
    [14] = {id=14, en='DRG', jp="竜"},
    [15] = {id=15, en='SMN', jp="召"},
    [16] = {id=16, en='BLU', jp="青"},
    [17] = {id=17, en='COR', jp="コ"},
    [18] = {id=18, en='PUP', jp="か"},
    [19] = {id=19, en='DNC', jp="踊"},
    [20] = {id=20, en='SCH', jp="学"},
    [21] = {id=21, en='GEO', jp="風"},
    [22] = {id=22, en='RUN', jp="剣"},
    [23] = {id=23, en='MON', jp="MON"},
};
BUFFS = {
    [1]   = {id=1,   en='Weakened',        jp='衰弱'},
    [35]  = {id=25,  en='Blink',           jp='ブリンク'},
    [37]  = {id=37,  en='Stoneskin',       jp='ストンスキン'},
    [40]  = {id=40,  en='Protect',         jp='プロテス'},
    [41]  = {id=41,  en='Shell',           jp='シェル'},
    [45]  = {id=45,  en='Boost',           jp='ためる'},
    [66]  = {id=66,  en='Copy Image',      jp='分身'},
    [67]  = {id=67,  en='Third Eye',       jp='心眼'},
    [69]  = {id=69,  en='Invisible',       jp='インビジ'},
    [71]  = {id=71,  en='Sneak',           jp='スニーク'},
    [72]  = {id=72,  en='Sharpshot',       jp='狙い撃ち'},
    [73]  = {id=73,  en='Barrage',         jp='乱れ撃ち'},
    [113] = {id=113, en='Reraise',         jp='リレイズ'},
    [249] = {id=249, en='Dedication',      jp='専心'},
    [253] = {id=253, en='Signet',          jp='シグネット'},
    [256] = {id=256, en='Sanction',        jp='サンクション'},
    [269] = {id=269, en='Level Sync',      jp='レベルシンク'},
    [353] = {id=353, en='Hasso',           jp='八双'},
    [354] = {id=354, en='Seigan',          jp='星眼'},
    [444] = {id=444, en='Copy Image (2)',  jp='分身(2)'},
    [445] = {id=445, en='Copy Image (3)',  jp='分身(3)'},
    [446] = {id=446, en='Copy Image (4+)', jp='分身(4+)'},
    [541] = {id=541, en='Refresh',         jp='リフレシュ'},
};

----------------------------------------------------------------------------------------------------
-- Configurations
----------------------------------------------------------------------------------------------------
local default_config = 
{
    locale = "en", -- Note: trying to print JP strings will apparently crash Ashita
    font =
    {
        family      = 'Arial',
        size        = 10,
        color       = 0xFFFFFFFF,
        position    = { 200, 100 },
        bgcolor     = 0x60000000,
        bgvisible   = true
    },
    reminders = 
    {
        expRing = true,
        dynaSteal = true,
        refresh = true,
        samStance = true
    },
    ring = "Empress Band"
};
local reminder_config = default_config;
Locale = reminder_config.locale;

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
-- ashita.register_event('load', function()
-- end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
-- ashita.register_event('unload', function()
-- end );

----------------------------------------------------------------------------------------------------
-- func: msg
-- desc: Prints out a message with the addon name at the front.
----------------------------------------------------------------------------------------------------
local function msg(s)
    local txt = '\31\200[\31\05' .. _addon.name .. '\31\200]\31\130 ' .. s;
    print(txt);
end

----------------------------------------------------------------------------------------------------
-- func: command
-- desc: Event called when a command was entered.
----------------------------------------------------------------------------------------------------
ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command
    local args = command:args();
    if not (args[1] == "/reminder") then
        return false;
    end

    if (args[2] == "print" or args[2] == "p") then

        -- Print active known buffs
        if (args[3] == "buffs" or args[3] == "b") then
            local activeBuffs = AshitaCore:GetDataManager():GetPlayer():GetBuffs();
            for k, v in pairs(activeBuffs) do
                if BUFFS[v] then
                    msg(k .. ': ' .. BUFFS[v][Locale]);
                end
            end
        end

        -- Print equivalent to <job>
        if (args[3] == "jobs" or args[3] == "j") then
            local player    = AshitaCore:GetDataManager():GetPlayer();
            local mainJob   = JOBS[player:GetMainJob()][Locale];
            local mainLevel = player:GetMainJobLevel();
            local subJob    = JOBS[player:GetSubJob()][Locale];
            local subLevel  = player:GetSubJobLevel();
            local jobString = string.format("%s%s/%s%s", mainJob, mainLevel, subJob, subLevel);
            msg(jobString);
        end

        if (args[3] == "locale" or args[3] == "l") then
            msg(Locale);
        end

    end

    return true;
end);

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Event called when the addon is asked to handle an incoming packet.
---------------------------------------------------------------------------------------------------
-- ashita.register_event('incoming_packet', function(id, size, data)
-- end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- local f         = AshitaCore:GetFontManager():Get( '__reminder_addon' );
    local Entity    = AshitaCore:GetDataManager():GetEntity();
    local party     = AshitaCore:GetDataManager():GetParty();
    local player    = AshitaCore:GetDataManager():GetPlayer();
    local ZoneName  = AshitaCore:GetResourceManager():GetString('areas', party:GetMemberZone(0));

    local mainJob   = player:GetMainJob();
    local subJob    = player:GetSubJob();
    local buffs     = player:GetBuffs();


end);
