_addon.name = 'autoWeaponskill'
_addon.author = 'Lorand'
_addon.commands = {'autows','aws'}
_addon.version = '0.2.1'

_libs = _libs or {}
_libs.luau = _libs.luau or require('luau')

debugging = false
useAutows = false
useAutoRA = false
araDelayed = 0
autoWsCmd = ''
autowsHpLt = true
autowsMobHp = 100
autowsDelay = 0.8
mobs = {}

windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = {...}
	
	if (command == 'reload') then
		windower.send_command('lua reload '.._addon.name)
	elseif (command == 'unload') then
		windower.send_command('lua unload '.._addon.name)
	elseif S{'enable','on','start'}:contains(command) then
		useAutows = true
		print_status()
	elseif S{'disable','off','stop'}:contains(command) then
		useAutows = false
		print_status()
	elseif (command == 'toggle') then
		useAutows = not useAutows
		print_status()
	elseif S{'set','use','ws'}:contains(command) then
		autoWsCmd = '/ws "'
		for i = 1, #args, 1 do
			autoWsCmd = autoWsCmd..args[i]
			if i < #args then
				autoWsCmd = autoWsCmd..' '
			end
		end
		autoWsCmd = autoWsCmd..'" <t>'
		print_status()
	elseif (command == '<') then
		autowsHpLt = true
		print_status()
	elseif (command == '>') then
		autowsHpLt = false
		print_status()
	elseif (command == 'hp') then
		autowsMobHp = tonumber(args[1])
		print_status()
	elseif (command == 'mob') then
		local mobName = ''
		for i = 3, #args, 1 do
			mobName = mobName..args[i]
			if i < #args then
				mobName = mobName..' '
			end
		end
		mobs[mobName] = {
			hp = tonumber(args[2]),
			sign = args[1]
		}
	elseif (command == 'autora') then
		local cmd = args[2] ~= nil and args[2]:lower() or (useAutoRA and 'off' or 'on')
		if S{'on'}:contains(cmd) then
			useAutoRA = true
			atc('AutoWS will now resume auto ranged attacks after WSing')
		elseif S{'off'}:contains(cmd) then
			useAutoRA = false
			atc('AutoWS will no longer resume auto ranged attacks after WSing')
		else
			atc(123,'Error: invalid argument for AutoRA: '..cmd)
		end
	elseif (command == 'status') then
		print_status()
	else
		atc('Error: Unknown command')
	end
end)

windower.register_event('load', function()
	autowsLastCheck = os.clock()
	atc('autoWeponskill commands:')
	atc('autows <on|off|toggle>')
	atc('autows mob <sign> <hp%> <name>')
	atc('autows hp <hp%>')
	atc('autows <')
	atc('autows >')
	atc('autows set <weaponskill name>')
	atc('autows autora [<on|off>]')
end)

windower.register_event('prerender', function()
	if useAutows and (autoWsCmd ~= '') then
		local now = os.clock()
		if (now - autowsLastCheck) >= autowsDelay then
			local player = windower.ffxi.get_player()
			local mob = windower.ffxi.get_mob_by_target()
			
			if (player ~= nil) and (player.status == 1) and (mob ~= nil) then
				if mobs[mob.name] ~= nil then
					local signLt = (mobs[mob.name].sign == '<')
					local mobHp = mobs[mob.name].hp
					if (autowsMobHp ~= mobHp) or (autowsHpLt ~= signLt) then
						autowsHpLt = signLt
						windower.send_command('autows hp '..mobHp)
					end
				end
				
				if player.vitals.tp > 999 then
					if useAutoRA and (araDelayed < 2) then
						araDelayed = araDelayed + 1
					else
						if autowsHpLt then
							if mob.hpp < autowsMobHp then
								windower.send_command('input '..autoWsCmd)
							end
						else
							if mob.hpp > autowsMobHp then
								windower.send_command('input '..autoWsCmd)
							end
						end
						araDelayed = 0
						if useAutoRA then
							windower.send_command('wait 4;ara start')
						end
					end
				end
			end
			autowsLastCheck = now
		end
	end
end)

function print_status()
	local onoff = useAutows and 'On' or 'Off'
	local ltgt = autowsHpLt and '<' or '>'
	atc('[autoWeaponskill: '..onoff..'] {'..autoWsCmd..'} when target HP '..ltgt..' '..autowsMobHp..'%')
end

function atc(c, msg)
	if (type(c) == 'string') and (msg == nil) then
		msg = c
		c = 0
	end
	windower.add_to_chat(c, msg)
end

function atcd(text)
	if debugging then
		atc(text)
	end
end

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2014-2015, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------