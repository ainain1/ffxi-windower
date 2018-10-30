_addon.name     = 'Free Subjob'
_addon.author   = 'Datboi'
_addon.version  = '420.69'
_addon.commands = { 'freesubjob', 'fsj' }


require ('logger')
packets = require('packets')

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or 'help'
    local args = {...}
    local packet = packets.new('outgoing', 0x0100, {
        ["Sub Job"] = 1
    })
    packets.inject(packet)  
end)