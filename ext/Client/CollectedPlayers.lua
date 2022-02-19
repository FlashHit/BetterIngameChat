---@class CollectedPlayers
CollectedPlayers = class 'CollectedPlayers'

function CollectedPlayers:__init()
	self.m_CollectedPlayers = {}
end

---@param p_Player Player
function CollectedPlayers:OnPlayerConnected(p_Player)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil and p_Player.name == s_LocalPlayer.name then
		WebUI:ExecuteJS(string.format("OnUpdatePlayerName(%s)", json.encode(p_Player.name)))
	else
		self.m_CollectedPlayers[p_Player.id] = p_Player.name
	end

	WebUI:ExecuteJS(string.format("OnUpdatePlayerList(%s)", json.encode(self.m_CollectedPlayers)))
end

---@param p_Player Player
function CollectedPlayers:OnPlayerDeleted(p_Player)
	self.m_CollectedPlayers[p_Player.id] = nil

	WebUI:ExecuteJS(string.format("OnUpdatePlayerList(%s)", json.encode(self.m_CollectedPlayers)))
end

return CollectedPlayers()
