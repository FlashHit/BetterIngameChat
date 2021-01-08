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

end

function BetterIngameChat:OnServerRoundOver(p_RoundTime, p_WinningTeam)
    self.m_IsEndScreen = true
end

function BetterIngameChat:OnPlayerChat(p_Player, p_RecipientMask, p_Message)
    if self.m_IsEndScreen == true then
		NetEvents:Broadcast('EndScreenMessage', {p_Player.name, p_RecipientMask, p_Message})
	end
end

function BetterIngameChat:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self.m_IsEndScreen = false
end

function BetterIngameChat:OnMessageToSquadLeaders(p_Player, p_Content)
	local s_Message = "SquadLeaderMessage:" .. p_Player.name .. p_Content[1]
	for i,l_Player in pairs(PlayerManager:GetPlayersByTeam(p_Player.teamId)) do
		if l_Player.isSquadLeader == true then
			ChatManager:SendMessage(s_Message, l_Player)
		end
	end
	-- TODO: send message to the sender
end

function BetterIngameChat:OnMessageToPlayer(p_Player, p_Content)
	local s_TargetPlayerMessage = "DirectPlayerMessage" .. p_Player.name .. ":" .. p_Content[1]
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Content[2])
	
	if s_TargetPlayer ~= nil then
		ChatManager:SendMessage(s_TargetPlayerMessage, s_TargetPlayer)
		local s_SenderReturnMessage = "DirectReturnMessage" .. s_TargetPlayer.name .. ":" .. p_Content[1]
		ChatManager:SendMessage(s_SenderReturnMessage, p_Player)
	else
		ChatManager:SendMessage("ERROR: Player not found.", p_Player)
	end
end

function BetterIngameChat:OnAdminMessageToPlayer(p_Player, p_Content)
	if m_AdminList[p_Player.name] == nil then
		-- player is no admin
		return
	end
	local s_Message = p_Player.name": " .. p_Content[1]
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Content[2])
	
	if s_TargetPlayer ~= nil then
		ChatManager:SendMessage(s_Message, s_TargetPlayer)
	end
	-- TODO: send message to the sender
end

function BetterIngameChat:OnAdminMessageToAll(p_Player, p_Content)
	if m_AdminList[p_Player.name] == nil then
		-- player is no admin
		return
	end
	local s_IsAnonymMessage = p_Content[2]
	local s_Message = p_Content[1]
	
	if s_IsAnonymMessage == false then
		s_Message = p_Player.name": " .. p_Content[1]
	end
	
	if s_TargetPlayer ~= nil then
		ChatManager:SendMessage(s_Message)
	end
	-- TODO: send message to the sender
end

-- Region gameAdmin
function BetterIngameChat:OnGameAdminPlayer(p_PlayerName, p_Abilitities)
    self.m_AdminList[playerName] = p_Abilitities
	
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
-- Endregion

g_BetterIngameChat = BetterIngameChat()
