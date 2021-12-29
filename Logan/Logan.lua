if Settings == nil then
	Settings = {
		Enabled = true,
		ChanceZone = 5,
		ChatType = 'SAY'
	}
end

local function SpeakZone()
	local message = string.format("Never thought I'd find myself back in %s again.", GetZoneText())
	if Settings.ChatType == 'PRIVATE' then
		print(message)
	else
		SendChatMessage(message, Settings.ChatType)
	end
end

local function RollToSpeakZone()
	if math.random(100) <= Settings.ChanceZone then
		SpeakZone()
	end
end

local function ShowHelp()
	print('Logan, by CodeBleu')
	print('Commands:')
	print('/logan [on|off] - Turns Logan on or off')
	print('/logan chancezone - Gets/sets the chance that Logan will speak when you change zones')
	print('/logan chat - Gets/sets the chat Logan will speak in')
	print('/logan forcezone - Makes Logan speak about the current zone now')
end

local LoganFrame = CreateFrame('Frame')
LoganFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
LoganFrame:SetScript('OnEvent', function(self, event, ...)
	if Settings.Enabled then
		if event == 'ZONE_CHANGED_NEW_AREA' then
			RollToSpeakZone()
		end
	end
end)

SLASH_LOGAN1 = '/logan';
function SlashCmdList.LOGAN(msg, editbox)
	if msg == nil or msg == '' then
		ShowHelp()
	else
		local command, arguments = msg:match("^(%S*)%s*(.-)$")
		if command == 'help' then
			ShowHelp()
		elseif command == 'forcezone' then
			SpeakZone()
		elseif command == 'on' then
			if Settings.Enabled then
				print('Logan is already on.')
			else
				Settings.Enabled = true
				print('Logan is now on.')
			end
		elseif command == 'off' then
			if Settings.Enabled then
				Settings.Enabled = false
				print('Logan is now off.')
			else
				print('Logan is already off.')
			end
		elseif command == 'chancezone' then
			if arguments == nil or arguments == '' then
				if Settings.Enabled then
					print(string.format('Logan has a %d%% chance to speak when you change zones.', Settings.ChanceZone))
				else
					print(string.format('Logan will have a %d%% chance to speak when you change zones if you enable it.', Settings.ChanceZone))
				end
			else
				local newChance = tonumber(arguments)
				if newChance ~= nil then
					if newChance >= 0 and newChance <= 100 then
						Settings.ChanceZone = newChance
						if Settings.Enabled then
							print(string.format('Logan now has a %d%% chance to speak when you change zones.', Settings.ChanceZone))
						else
							print(string.format('Logan will now have a %d%% chance to speak when you change zones if you enable it.', Settings.ChanceZone))
						end
					else
						print('The announcement chance must be between 0 and 100 (inclusive).')
					end
				else
					print('The announcement chance must be a number.')
				end
			end
		elseif command == 'chat' or command == 'chattype' then
			if arguments == nil or arguments == '' then
				print(string.format("Logan's current chat is %s. You can choose GUILD, INSTANCE_CHAT, OFFICER, PARTY, PRIVATE, RAID, RAID_WARNING, SAY, WHISPER, or YELL.", Settings.ChatType))
			else
				local newChatType = string.upper(arguments)
				if newChatType == 'GUILD' or newChatType == 'INSTANCE_CHAT' or newChatType == 'OFFICER' or newChatType == 'PARTY' or newChatType == 'PRIVATE' or newChatType == 'RAID' or newChatType == 'RAID_WARNING' or newChatType == 'SAY' or newChatType == 'WHISPER' or newChatType == 'YELL' then
					Settings.ChatType = newChatType
					print(string.format("Logan's chat is now %s.", Settings.ChatType))
				else
					print('That is not an acceptable chat type.');
				end
			end
		else
			print("Logan doesn't understand what you mean.");
		end
	end
end