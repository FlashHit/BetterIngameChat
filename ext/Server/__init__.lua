local isEndScreen = false

Events:Subscribe('Server:RoundOver', function(roundTime, winningTeam)
    isEndScreen = true
end)

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
    if isEndScreen == true then
		NetEvents:Broadcast('EndScreenMessage', {player.name, recipientMask, message})
	end
end)

Events:Subscribe('Level:Loaded', function(levelName, gameMode, round, roundsPerMap)
    isEndScreen = false
end)

NetEvents:Subscribe('Message:ToSquadLeaders', p_Player, function(p_Content)
	local s_Message = "SquadLeaderMessage:" .. p_Content[1]
	for i,l_Player in pairs(PlayerManager:GetPlayersByTeam(p_Player.teamId)) do
		if l_Player.isSquadLeader == true then
			ChatManager:SendMessage(s_Message, l_Player)
		end
	end
end)

NetEvents:Subscribe('Message:ToPlayer', p_Player, function(p_Content)
	local s_Message = "DirectMessage:" .. p_Content[1]
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Content[2])
	
	if s_TargetPlayer ~= nil then
		ChatManager:SendMessage(s_Message, s_TargetPlayer)
	end
end)
