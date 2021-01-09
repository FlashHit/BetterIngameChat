class 'BetterIngameChat'

function BetterIngameChat:__init()

	self.m_IsEndScreen = false
	
	self.m_AdminList = {}

	-- Subscribe to events.
	self.m_ServerRoundOverEvent = Events:Subscribe('Server:RoundOver', self, self.OnServerRoundOver)
	self.m_PlayerChatEvent = Events:Subscribe('Player:Chat', self, self.OnPlayerChat)
	self.m_LevelLoadedEvent = Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	-- NetEvents
	self.m_MessageToSquadLeadersEvent = NetEvents:Subscribe('Message:ToSquadLeaders', self, self.OnMessageToSquadLeaders)
	self.m_MessageToPlayerEvent = NetEvents:Subscribe('Message:ToPlayer', self, self.OnMessageToPlayer)
	self.m_AdminMessageToPlayerEvent = NetEvents:Subscribe('AdminMessage:ToPlayer', self, self.OnAdminMessageToPlayer)
	self.m_AdminMessageToAllEvent = NetEvents:Subscribe('AdminMessage:ToAll', self, self.OnAdminMessageToAll)

	-- gameAdmin Events
	self.m_GameAdminPlayerEvent = Events:Subscribe('GameAdmin:Player', self, self.OnGameAdminPlayer)
	self.m_GameAdminClearEvent = Events:Subscribe('GameAdmin:Clear', self, self.OnGameAdminClear)
	self.m_PlayerAuthenticatedEvent = Events:Subscribe('Player:Authenticated', self, self.OnPlayerAuthenticated)

end

function BetterIngameChat:OnServerRoundOver(p_RoundTime, p_WinningTeam)
    self.m_IsEndScreen = true
end

function BetterIngameChat:OnPlayerChat(p_Player, p_RecipientMask, p_Message)

    if self.m_IsEndScreen == true then
	
		local s_Target = "none"
		local s_TeamId = nil
		local s_SquadId = nil
		
		if p_RecipientMask > 1000000000000 then
			s_Target = "all"
		elseif p_RecipientMask == 1 then
			s_Target = "team"
		elseif p_RecipientMask == 2 then
			s_Target = "team"
		elseif p_RecipientMask >= 83 and p_RecipientMask <= 115 then
			s_Target = "squad"
		elseif p_RecipientMask >= 50 and p_RecipientMask <= 82 then
			s_Target = "squad"
		end
		
		NetEvents:Broadcast('EndScreenMessage', {p_Player.name, s_Target, p_Message})
		
	end
	
end

function BetterIngameChat:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self.m_IsEndScreen = false
end

function BetterIngameChat:OnMessageToSquadLeaders(p_Player, p_Content)
	if p_Player.isSquadLeader == false then
		RCON:SendCommand("admin.say", {"ERROR: You are no squad leader.", "player", p_Player.name})
		return
	end
	
	local s_Message = p_Content[1]
	
	for i,l_Player in pairs(PlayerManager:GetPlayersByTeam(p_Player.teamId)) do
		if l_Player.isSquadLeader == true then
			NetEvents:SendTo('ToClient:MessageToSquadLeaders', l_Player, {p_Player.name, s_Message})
			RCON:TriggerEvent("player.onChat",{p_Player.name, "SquadLeaderMessage: " .. s_Message, "player", l_Player.name})
		end
	end
end

function BetterIngameChat:OnMessageToPlayer(p_Player, p_Content)
	
	local s_Message = p_Content[1]
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Content[2])
	
	if s_TargetPlayer ~= nil then
		NetEvents:SendTo('ToClient:MessageToPlayer', s_TargetPlayer, {p_Player.name, s_Message})
		-- commented out for privacy
		-- RCON:TriggerEvent("player.onChat",{p_Player.name, s_Message, "player", s_TargetPlayer.name})
	else
		RCON:SendCommand("admin.say", {"ERROR: Player not found.", p_Player.name})
	end
end

function BetterIngameChat:OnAdminMessageToPlayer(p_Player, p_Content)
	if m_AdminList[p_Player.name] == nil then
		RCON:SendCommand("admin.say", {"ERROR: You are no admin.", "player", p_Player.name})
		return
	end
	
	local s_Message = p_Content[1]
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Content[2])
	
	if s_TargetPlayer ~= nil then
		NetEvents:SendTo('ToClient:AdminMessageToPlayer', s_TargetPlayer, {p_Player.name, s_Message})
		RCON:TriggerEvent("player.onChat",{p_Player.name, s_Message, "player", s_TargetPlayer.name})
		-- player.onChat senderName "test message" targetName
	end
end

function BetterIngameChat:OnAdminMessageToAll(p_Player, p_Content)
	if m_AdminList[p_Player.name] == nil then
		RCON:SendCommand("admin.say", {"ERROR: You are no admin.", "player", p_Player.name})
		return
	end
	
	local s_Message = p_Content[1]
	local s_IsAnonymMessage = p_Content[2]
	
	if s_IsAnonymMessage == false then
		NetEvents:Broadcast('ToClient:AdminMessage', {s_Message, p_Player.name})
		RCON:TriggerEvent("player.onChat",{p_Player.name, s_Message, "all"})
	else
		NetEvents:Broadcast('ToClient:AdminMessage', {s_Message})
		RCON:TriggerEvent("player.onChat",{p_Player.name, "Anonym: " .. s_Message, "all"})
	end
end

-- Region gameAdmin
function BetterIngameChat:OnGameAdminPlayer(p_PlayerName, p_Abilitities)

    self.m_AdminList[p_PlayerName] = p_Abilitities
	
	-- send to the player
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_Player ~= nil then
		NetEvents:SendTo('AddAdminPlayer', s_Player)
	end
end

function BetterIngameChat:OnGameAdminClear()
	-- send to all admins
	for l_AdminName,l_Abilitities in pairs(self.m_AdminList) do
		local s_Admin = PlayerManager:GetPlayerByName(l_AdminName)
		if s_Admin ~= nil then
			NetEvents:SendTo('RemoveAdminPlayer', s_Admin)
		end
	end
	
	self.m_AdminList = {}
end

function BetterIngameChat:OnPlayerAuthenticated(p_Player)
	-- send NetEvent if admin
	if self.m_AdminList[p_PlayerName] ~= nil then
		NetEvents:SendTo('AddAdminPlayer', p_Player)
	end
end
-- Endregion

g_BetterIngameChat = BetterIngameChat()
