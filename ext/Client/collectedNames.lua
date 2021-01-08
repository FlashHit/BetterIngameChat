class 'CollectedPlayers'

function CollectedPlayers:__init()
	self.m_CollectedPlayers = {}

	self.m_PlayerConnectedEvent = Events:Subscribe('Player:Connected', self, self.OnPlayerConnected)
	self.m_PlayerLeftEvent = Events:Subscribe('Player:Left', self, self.OnPlayerLeft)
end

function CollectedPlayers:OnPlayerConnected(p_Player)
	if p_Player.name == PlayerManager:GetLocalPlayer().name then
		for _,l_Player in pairs(PlayerManager:GetPlayers()) do
			if p_Player.name ~= l_Player.name then
				self.m_CollectedPlayers[l_Player.id] = l_Player.name
			end
		end

		WebUI:ExecuteJS(string.format("OnUpdatePlayerName('%s')", tostring(p_Player.name)))
	else
		self.m_CollectedPlayers[p_Player.id] = p_Player.name
	end
	
	WebUI:ExecuteJS(string.format("OnUpdatePlayerList(%s)", json.encode(self.m_CollectedPlayers)))
end

function CollectedPlayers:OnPlayerLeft(p_Player)
	self.m_CollectedPlayers[p_Player.id] = nil
end

return CollectedPlayers
