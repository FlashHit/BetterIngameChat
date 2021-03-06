class 'IncomingMessages'

--local MutedPlayerList = require 'mutedPlayerList'

function IncomingMessages:__init()

	--self.m_MutedPlayerList = MutedPlayerList()
	
	self.m_CreateChatMessage = Hooks:Install('UI:CreateChatMessage',999, self, self.OnUICreateChatMessage)
	
	self.m_MessageToSquadLeadersEvent = NetEvents:Subscribe('ToClient:MessageToSquadLeaders', self, self.OnMessageToSquadLeader)
	self.m_MessageToPlayerEvent = NetEvents:Subscribe('ToClient:MessageToPlayer', self, self.OnMessageToPlayer)
	self.m_AdminMessageToPlayerEvent = NetEvents:Subscribe('ToClient:AdminMessageToPlayer', self, self.OnAdminMessageToPlayer)
	self.m_AdminMessageEvent = NetEvents:Subscribe('ToClient:AdminMessage', self, self.OnAdminMessage)
	
	self.m_EndScreenMessageEvent = NetEvents:Subscribe('EndScreenMessage', self, self.OnEndScreenMessage)
	
	-- Region Mute
	
	self.m_TextChatModerationList = {}
	--self.m_TextChatModerationMode = "free"
	
	self.m_MutedPlayers = {}
	
	-- AdvancedRCON Textchatmoderation NetEvents
	self.m_GetTextChatModerationListEvent = NetEvents:Subscribe('Server:GetTextChatModerationList', self, self.OnGetTextChatModerationList)
	self.m_AddPlayerEvent = NetEvents:Subscribe('Server:AddPlayer', self, self.OnAddPlayer)
	self.m_OverWritePlayerEvent = NetEvents:Subscribe('Server:OverWritePlayer', self, self.OnOverWritePlayer)
	self.m_RemovePlayerEvent = NetEvents:Subscribe('Server:RemovePlayer', self, self.OnRemovePlayer)
	self.m_ClearListEvent = NetEvents:Subscribe('Server:ClearList', self, self.OnClearList)
	self.m_LoadListEvent = NetEvents:Subscribe('Server:LoadList', self, self.OnLoadList)
	--self.m_TextChatModerationModeEvent = NetEvents:Subscribe('Server:TextChatModerationMode', self, self.OnTextChatModerationMode)
	
	-- BetterIngameAdmin Mute
	self.m_WebUIMutePlayerEvent = Events:Subscribe('WebUI:MutePlayer', self, self.OnWebUIMutePlayer)
	self.m_WebUIUnmutePlayerEvent = Events:Subscribe('WebUI:UnmutePlayer', self, self.OnWebUIUnmutePlayer)
	--self.m_WebUIChatChannelsEvent = Events:Subscribe('WebUI:ChatChannels', self, self.OnWebUIChatChannels)
	
	-- Endregion
end

function IncomingMessages:OnUICreateChatMessage(p_Hook, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	if p_Message == nil then
		return
	end

	-- Get the player sending the message, and our local player.
	local s_OtherPlayer = PlayerManager:GetPlayerById(p_PlayerId)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil


	-- Region SquadLeaderMessage, DirectMessage, AdminMessage

	if p_Channel == ChatChannelType.CctAdmin then
		
		local s_Author = ""
		s_Target = "admin"
	
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = p_Message:gsub("^Admin: ", '')
		
		s_Table = {author = s_Author, content = s_String, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		
		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))

		goto continue
	end

	-- Endregion


	-- Players not found; cancel.
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		goto continue
	end
	
	
	-- Region target: spectator, enemy, all, team, squad
	
	-- Player is a spectator.
	if s_OtherPlayer.teamId == 0 then
		s_Target = "spectator"
	
	-- Player is on a different team; display enemy message.
	elseif (s_LocalPlayer.teamId == 0 and s_OtherPlayer.teamId == 2) or (s_LocalPlayer.teamId ~= 0 and s_OtherPlayer.teamId ~= s_LocalPlayer.teamId) then
		s_Target = "enemy"

	-- Player is in the same team.
	-- Display global message.
	elseif p_Channel == ChatChannelType.CctSayAll then
		s_Target = "all"
		
	-- Display team message.
	elseif p_Channel == ChatChannelType.CctTeam then
		s_Target = "team"

	-- Display squad message.
	elseif p_Channel == ChatChannelType.CctSquad then
		s_Target = "squad"
	else
		goto continue
	end
	
	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	
	s_Table = {author = s_OtherPlayer.name, content = p_Message, target = s_Target, playerRelation = s_PlayerRelation}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))

	::continue::

	-- A new chat message is being created; 
	-- prevent the game from rendering it.
	p_Hook:Return()
end

function IncomingMessages:OnMessageToSquadLeader(p_Content)

	local s_Author = p_Content[1]
	local s_Message = p_Content[2]
	
	local s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	
	local s_Target = "squadLeader"
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil
	
	if self:CheckMuted(s_Author) then
		return
	end
	
	if self:CheckGlobalMuted(s_Author) then
		return
	end
	
	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	
	s_Table = {author = s_Author, content = s_Message, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	
end

function IncomingMessages:OnMessageToPlayer(p_Content)
	
	local s_Author = p_Content[1]
	local s_Message = p_Content[2]
	
	local s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target = "player"
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil
	
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		return
	end
	
	if self:CheckMuted(s_OtherPlayer.name) then
		return
	end
	
	if self:CheckGlobalMuted(s_OtherPlayer.name) then
		return
	end
	
	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	
	s_Table = {author = s_Author, content = s_Message, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
	
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	
end

function IncomingMessages:OnAdminMessageToPlayer(p_Content)
	
	local s_Author = p_Content[1]
	local s_Message = p_Content[2]
	
	local s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target = "adminPlayer"
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil
	
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		return
	end
	
	s_TargetName = s_LocalPlayer.name
	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	
	s_Table = {author = s_Author, content = s_Message, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	
end

function IncomingMessages:OnAdminMessage(p_Content)
	
	local s_Author = ""
	
	if #p_Content == 2 then
		s_Author = p_Content[2]
	end
	
	local s_Message = p_Content[1]
	
	local s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target = "admin"
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil
	
	if s_OtherPlayer ~= nil and s_LocalPlayer ~= nil then
		s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	end
	
	
	s_Table = {author = s_Author, content = s_Message, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	
end

function IncomingMessages:OnEndScreenMessage(p_Content)
	
	local s_Author = p_Content[1]
	local s_Target = p_Content[2]
	local s_Message = p_Content[3]
	
	local s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil
	
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		return
	end
	
	if s_Target ~= "all" then
		if s_OtherPlayer.teamId ~= s_LocalPlayer.teamId then
			return
		end
		
		if s_Target == "squad" and s_OtherPlayer.squadId ~= s_LocalPlayer.squadId then
			return
		end
		
	elseif (s_LocalPlayer.teamId == 0 and s_OtherPlayer.teamId == 2) or (s_LocalPlayer.teamId ~= 0 and s_OtherPlayer.teamId ~= s_LocalPlayer.teamId) then
		s_Target = "enemy"
	end
	
	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	
	
	s_Table = {author = s_Author, content = s_Message, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	
end

function IncomingMessages:GetPlayerRelation(p_OtherPlayer, p_LocalPlayer)
	
	if p_OtherPlayer.name == p_LocalPlayer.name then
		
		return "localPlayer"
	
	elseif p_OtherPlayer.teamId == p_LocalPlayer.teamId then
		
		if p_OtherPlayer.squadId == p_LocalPlayer.squadId and p_LocalPlayer.squadId ~= 0 then
			
			return "squadMate"
		
		else
			
			return "teamMate"
		
		end
	
	elseif p_OtherPlayer.teamId == 0 then
		
		return "spectator"
	
	else
		
		return "enemy"
	
	end
	
end


function IncomingMessages:OnGetTextChatModerationList(p_TextChatModerationList)
	self.m_TextChatModerationList = p_TextChatModerationList
end

function IncomingMessages:OnAddPlayer(p_Content)
	table.insert(self.m_TextChatModerationList, p_Content[1])
end

function IncomingMessages:OnOverWritePlayer(p_Content)
	self.m_TextChatModerationList[p_Content[1]] = p_Content[2]
end

function IncomingMessages:OnRemovePlayer(p_Content)
	table.remove(self.m_TextChatModerationList, p_Content[1])
end

function IncomingMessages:OnClearList(p_Content)
	self.m_TextChatModerationList = {}
end

function IncomingMessages:OnLoadList(p_TextChatModerationList)
	self.m_TextChatModerationList = p_TextChatModerationList
end

function IncomingMessages:OnTextChatModerationMode(p_Content)
	self.m_TextChatModerationMode = p_Content[1]
end

function IncomingMessages:CheckGlobalMuted(p_PlayerName)

	local s_IsVoice = false
	local s_IsAdmin = false
	
	for _,l_Player in pairs(self.m_TextChatModerationList) do
		if l_Player == "muted:"..p_PlayerName then
			return true
		elseif l_Player == "admin:"..p_PlayerName then
			s_IsAdmin = true
			return false
		elseif l_Player == "voice:"..p_PlayerName then
			s_IsVoice = true
			return false
		end
	end
	
end

function IncomingMessages:OnWebUIMutePlayer(p_PlayerName)

	local s_PlayerAlreadyMuted = false
	
	for _,l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == p_PlayerName then	
			s_PlayerAlreadyMuted = true
			return
		end
	end
	if s_PlayerAlreadyMuted == false then
		table.insert(self.m_MutedPlayers, p_PlayerName)
	end
end

function IncomingMessages:OnWebUIUnmutePlayer(p_PlayerName)

	local s_PlayerAlreadyMuted = false
	
	for i,l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == p_PlayerName then
			table.remove(self.m_MutedPlayers, i)
			return
		end
	end
end

function IncomingMessages:CheckMuted(p_PlayerName)

	for _,l_Player in pairs(self.m_MutedPlayers) do
		if l_Player == p_PlayerName then
			return true
		end
	end
	
	return false
	
end

return IncomingMessages
