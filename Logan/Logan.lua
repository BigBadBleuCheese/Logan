if Settings == nil then
	Settings = {
		Enabled = true,
		ChanceZone = 5,
		ChatType = 'DYNAMIC'
	}
end

local function SpeakZone()
	local message = string.format("Never thought I'd find myself back in %s again.", GetZoneText())
	if Settings.ChatType == 'SAY' or Settings.ChatType == 'YELL' then
		print('Logan: Blizzard no longer allows add-ons to send messages to SAY or YELL outdoors when not directly tied to a hardware event. I have changed your chat type to DYNAMIC for now. You can change it with slash commands.')
		Settings.ChatType = 'DYNAMIC'
	end
	if Settings.ChatType == 'PRIVATE' then
		print(message)
	elseif Settings.ChatType == 'DYNAMIC' then
		local inInstance, _ = IsInInstance()
		if inInstance then
			if message:find('!') then
				SendChatMessage(message, 'YELL')
			else
				SendChatMessage(message, 'SAY')
			end
		elseif UnitInBattleground("player") ~= nil then
			SendChatMessage(message, 'INSTANCE_CHAT')
		elseif IsInRaid(LE_PARTY_CATEGORY_HOME) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			SendChatMessage(message, 'RAID')
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			SendChatMessage(message, 'PARTY')
		else
			local guildName, _, _, _ = GetGuildInfo('player')
			if (guildName ~= nil) then
				SendChatMessage(message, 'GUILD')
			else
				print(message)
			end
		end
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
LoganFrame:RegisterEvent('CHAT_MSG_CHANNEL')
LoganFrame:RegisterEvent('CHAT_MSG_GUILD')
LoganFrame:RegisterEvent('CHAT_MSG_INSTANCE_CHAT')
LoganFrame:RegisterEvent('CHAT_MSG_INSTANCE_CHAT_LEADER')
LoganFrame:RegisterEvent('CHAT_MSG_OFFICER')
LoganFrame:RegisterEvent('CHAT_MSG_PARTY')
LoganFrame:RegisterEvent('CHAT_MSG_PARTY_LEADER')
LoganFrame:RegisterEvent('CHAT_MSG_RAID')
LoganFrame:RegisterEvent('CHAT_MSG_RAID_LEADER')
LoganFrame:RegisterEvent('CHAT_MSG_RAID_WARNING')
LoganFrame:RegisterEvent('CHAT_MSG_SAY')
LoganFrame:RegisterEvent('CHAT_MSG_WHISPER')
LoganFrame:RegisterEvent('CHAT_MSG_YELL')
LoganFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
LoganFrame:SetScript('OnEvent', function(self, event, ...)
	if Settings.Enabled then
		if event:find("^CHAT_MSG_") then
			local realmName = GetRealmName()
			local player = UnitName('player') .. '-' .. realmName
			local text, sender, _, channelName = ...
			if not sender:find("-") then
				sender = sender .. '-' .. realmName
			end
			if sender ~= player and text:find("^Never thought I'd find myself back in .+ again\.$") then
				if channelName == '' then
					channelName = event:sub(10)
				end
				if channelName:find("_LEADER$") then
					channelName = event:sub(1, channelName:len() - 7)
				end
				if channelName:find("_WARNING$") then
					channelName = event:sub(1, channelName:len() - 8)
				end
				if event == 'CHAT_MSG_WHISPER' then
					SendChatMessage("That's what I'm say'n!", channelName, nil, sender)
				else
					SendChatMessage("That's what I'm say'n!", channelName)
				end
			end
		elseif event == 'ZONE_CHANGED_NEW_AREA' then
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
				print(string.format("Logan's current chat is %s. You can choose DYNAMIC, GUILD, INSTANCE_CHAT, OFFICER, PARTY, PRIVATE, RAID, RAID_WARNING, or WHISPER.", Settings.ChatType))
			else
				local newChatType = string.upper(arguments)
				if newChatType == 'DYNAMIC' or newChatType == 'GUILD' or newChatType == 'INSTANCE_CHAT' or newChatType == 'OFFICER' or newChatType == 'PARTY' or newChatType == 'PRIVATE' or newChatType == 'RAID' or newChatType == 'RAID_WARNING' or newChatType == 'WHISPER' then
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