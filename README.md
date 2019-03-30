# ashita-addons
Original addons for use with the Final Fantasy XI launcher Ashita

### dinfo
- **Status:** Ready!
- **Description:** Displays some basic information about the current zone and the player's target, including zone ID, target ID, and target coordinates including rotation value. Useful for developing in DSP without having to use the GM commands `!getid` or `!getpos`.
- **Options:** `/di f` toggles "fast mode," which switches the position info between local data (where is the target on my screen right now?) and last data (where was the target the last time the server sent me an update packet about it?)
- **Planned features:** Options to also display zone weather, target's current status, and colors based on target type (PC/NPC/mob)

### reminder
- **Status:** Not ready; in development
- **Description:** Checks various conditions and shows reminders not to do the stupid things you're doing.
- **Planned features:** Remind you to use your empress band, use food when it wears, Steal on cooldown in Dynamis, refresh yourself as a RDM, etc.

### ticklish
- **Status:** Buggy; development on hold
- **Description:** Displays a countdown until the next resting tick. An Ashita-native rewrite of Windower's "tickle" plugin with extra functionality.
- **Planned features:** Display information about number of ticks rested, amount of HP/MP on next tick, and set an ashitacast var to enable precise swapping between HMP and refresh gear.
