---@class IncomingMessages
IncomingMessages = class 'IncomingMessages'

function IncomingMessages:__init()
	-- Region Mute

	self.m_TextChatModerationMode = "free"
	self.m_TextChatModerationList = {}
	self.m_MutedPlayers = {}

	-- AdvancedRCON Textchatmoderation NetEvents
	NetEvents:Subscribe('Server:GetTextChatModerationList', self, self.OnGetTextChatModerationList)
	NetEvents:Subscribe('Server:AddPlayer', self, self.OnAddPlayer)
	NetEvents:Subscribe('Server:OverWritePlayer', self, self.OnOverWritePlayer)
	NetEvents:Subscribe('Server:RemovePlayer', self, self.OnRemovePlayer)
	NetEvents:Subscribe('Server:ClearList', self, self.OnClearList)
	NetEvents:Subscribe('Server:LoadList', self, self.OnLoadList)
	NetEvents:Subscribe('Server:TextChatModerationMode', self, self.OnTextChatModerationMode)

	-- BetterIngameAdmin Mute
	Events:Subscribe('WebUI:MutePlayer', self, self.OnWebUIMutePlayer)
	Events:Subscribe('WebUI:UnmutePlayer', self, self.OnWebUIUnmutePlayer)

	NetEvents:Subscribe('ServerClient_Chat', self, self.OnChat)
end

---@param p_PlayerName string
---@param p_Target string
---@param p_Message string
---@param p_TargetName string|nil
function IncomingMessages:OnChat(p_PlayerName, p_Target, p_Message, p_TargetName)
	if self:CheckMuted(p_PlayerName) then
		return
	end

	if self:CheckGlobalMuted(p_PlayerName) then
		return
	end

	local s_OtherPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	local s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)

	if p_Target == "adminAnonym" then
		p_PlayerName = ""
	end

	local s_Table = {author = p_PlayerName, content = p_Message, target = p_Target, playerRelation = s_PlayerRelation, targetName = p_TargetName}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
end


---@param p_HookCtx HookContext
---@param p_Message string
---@param p_ChannelId ChatChannelType|integer
---@param p_PlayerId integer
---@param p_RecipientMask integer
---@param p_IsSenderDead boolean
function IncomingMessages:OnUICreateChatMessage(p_HookCtx, p_Message, p_ChannelId, p_PlayerId, p_RecipientMask, p_IsSenderDead)
	if p_ChannelId == ChatChannelType.CctAdmin then
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		p_Message = p_Message:gsub("^Admin: ", '')

		local s_Table = {author = "", content = p_Message, target = "admin", playerRelation = "none", targetName = nil}

		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	end

	-- A new chat message is being created;
	-- prevent the game from rendering it.
	p_HookCtx:Return()
end

function IncomingMessages:GetPlayerRelation(p_OtherPlayer, p_LocalPlayer)
	if p_OtherPlayer == nil or p_LocalPlayer == nil then
		return "none"
	elseif p_OtherPlayer.name == p_LocalPlayer.name then
		return "localPlayer"
	elseif p_OtherPlayer.teamId == p_LocalPlayer.teamId then
		if p_OtherPlayer.squadId == p_LocalPlayer.squadId and p_LocalPlayer.squadId ~= SquadId.SquadNone then
			return "squadMate"
		else
			return "teamMate"
		end
	elseif p_OtherPlayer.teamId == TeamId.TeamNeutral then
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
	for _, l_Player in pairs(self.m_TextChatModerationList) do
		if l_Player == "muted:" .. p_PlayerName then
			return true
		elseif l_Player == "admin:" .. p_PlayerName then
			return false
		elseif l_Player == "voice:" .. p_PlayerName then
			if self.m_TextChatModerationMode == "muted" then
				return true
			else
				return false
			end
		end
	end

	if self.m_TextChatModerationMode == "muted" then
		return true
	end
end

function IncomingMessages:OnWebUIMutePlayer(p_PlayerName)
	local s_PlayerAlreadyMuted = false

	for _, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == p_PlayerName then
			s_PlayerAlreadyMuted = true
			return
		end
	end

	if not s_PlayerAlreadyMuted then
		table.insert(self.m_MutedPlayers, p_PlayerName)
	end
end

function IncomingMessages:OnWebUIUnmutePlayer(p_PlayerName)
	for i, l_MutedPlayer in pairs(self.m_MutedPlayers) do
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

return IncomingMessages()
