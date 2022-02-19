---@class ServerBetterIngameChat
ServerBetterIngameChat = class 'ServerBetterIngameChat'

function ServerBetterIngameChat:__init()
	self.m_AdminList = {}

	Events:Subscribe('GameAdmin:Player', self, self.OnGameAdminPlayer)
	Events:Subscribe('GameAdmin:Clear', self, self.OnGameAdminClear)
	Events:Subscribe('Player:Authenticated', self, self.OnPlayerAuthenticated)

	NetEvents:Subscribe('ClientServer_Chat', self, self.OnChat)
end

---@param p_Player Player
---@param p_Target string
---@param p_Message string
---@param p_TargetName string|nil
function ServerBetterIngameChat:OnChat(p_Player, p_Target, p_Message, p_TargetName)
	if p_Target:match("admin") then
		if self.m_AdminList[p_Player.name] == nil then
			RCON:SendCommand("admin.say", {"ERROR: You are no admin.", "player", p_Player.name})
			return
		end
	end

	if p_Target == 'all' or p_Target == 'admin' or p_Target == 'adminAnonym' then
		NetEvents:Broadcast('ServerClient_Chat', p_Player.name, p_Target, p_Message, p_TargetName)
		return
	end

	if p_Target == 'team' then
		local s_Players = PlayerManager:GetPlayersByTeam(p_Player.teamId)

		for _, l_Player in pairs(s_Players) do
			NetEvents:SendTo('ServerClient_Chat', l_Player, p_Player.name, p_Target, p_Message, p_TargetName)
		end

		return
	end

	if p_Target == 'squad' then
		local s_Players = PlayerManager:GetPlayersBySquad(p_Player.teamId, p_Player.squadId)

		for _, l_Player in pairs(s_Players) do
			NetEvents:SendTo('ServerClient_Chat', l_Player, p_Player.name, p_Target, p_Message, p_TargetName)
		end

		return
	end

	if p_Target == 'squadLeader' then
		if p_Player.isSquadLeader == false then
			RCON:SendCommand("admin.say", {"ERROR: You are no squad leader.", "player", p_Player.name})
			return
		end

		local s_Players = PlayerManager:GetPlayersByTeam(p_Player.teamId)

		for _, l_Player in pairs(s_Players) do
			if l_Player.isSquadLeader then
				NetEvents:SendTo('ServerClient_Chat', l_Player, p_Player.name, p_Target, p_Message, p_TargetName)
			end
		end

		return
	end

	if p_TargetName ~= nil and (p_Target == 'adminPlayer' or p_Target == 'player') then
		local s_TargetPlayer = PlayerManager:GetPlayerByName(p_TargetName)

		if s_TargetPlayer ~= nil then
			NetEvents:SendTo('ServerClient_Chat', s_TargetPlayer, p_Player.name, p_Target, p_Message, p_TargetName)
			NetEvents:SendTo('ServerClient_Chat', p_Player, p_Player.name, p_Target, p_Message, p_TargetName)
			-- commented out for privacy
			-- RCON:TriggerEvent("player.onChat", {p_Player.name, p_Message, "player", p_TargetName})
		else
			RCON:SendCommand("admin.say", {"ERROR: Player not found.", p_Player.name})
		end

		return
	end
end

-- Region gameAdmin

function ServerBetterIngameChat:OnGameAdminPlayer(p_PlayerName, p_Abilitities)
    self.m_AdminList[p_PlayerName] = p_Abilitities

	-- send to the player
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_Player ~= nil then
		NetEvents:SendTo('AddAdminPlayer', s_Player)
	end
end

function ServerBetterIngameChat:OnGameAdminClear()
	-- send to all admins
	for l_AdminName, l_Abilitities in pairs(self.m_AdminList) do
		local s_Admin = PlayerManager:GetPlayerByName(l_AdminName)
		if s_Admin ~= nil then
			NetEvents:SendTo('RemoveAdminPlayer', s_Admin)
		end
	end

	self.m_AdminList = {}
end

function ServerBetterIngameChat:OnPlayerAuthenticated(p_Player)
	-- send NetEvent if admin
	if self.m_AdminList[p_Player.name] ~= nil then
		NetEvents:SendTo('AddAdminPlayer', p_Player)
	end
end

ServerBetterIngameChat()
