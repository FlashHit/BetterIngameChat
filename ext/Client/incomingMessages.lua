class 'IncomingMessages'

function IncomingMessages:__init()
	self.m_CreateChatMessage = Hooks:Install('UI:CreateChatMessage',999, self, self.OnUICreateChatMessage)
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
		
		local s_Author = "Admin"
		s_Target = "admin"
		
		if p_Message:gsub(":.*$", ""):match("DirectPlayerMessage") then
			
			p_Message = p_Message:match("^[a-z]+:(.*)$")
			
			s_Target = "player"
			
			s_Author = p_Message:gsub(":.*$", ""):gsub("DirectPlayerMessage ", "")
			s_OtherPlayer = PlayerManager:GetPlayerByName(s_Author)
			
			if s_OtherPlayer == nil then
				goto continue
			end
			
			-- Result: "[From] playername: message"
			
		elseif p_Message:gsub(":.*$", ""):match("DirectReturnMessage") then
		
			p_Message = p_Message:match("^[a-z]+:(.*)$")
			
			s_Target = "player"
			
			s_TargetName = p_Message:gsub(":.*$", ""):gsub("DirectReturnMessage ", "")
			
			if s_LocalPlayer ~= nil then
				s_Author = s_LocalPlayer.name
				s_OtherPlayer = s_LocalPlayer
			else
				goto continue
			end
			
			-- Result: "[To playername] localPlayerName: message"
			
			-- or what if we just do: "[@playerName] message"?
		end
	
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = p_Message:gsub("^Admin: ", '')


		s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)	

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
	elseif p_Channel == ChatChannelType.CctSayAll and s_LocalPlayer.teamId ~= 0 then
		s_Target = "all"

	-- Player sends a squad leader message
	--[[ this will be moved up to the CctAdmin part
	elseif p_Channel == ChatChannelType.CctSquadLeader or (ChatChannelType.CctTeam and p_Message:gsub(":.*$", "") == "SquadLeaderMessage") then
		p_Message = p_Message:match("^[a-z]+:(.*)$")
		s_Target = "squadLeader"]]
		
	-- Display team message.
	elseif p_Channel == ChatChannelType.CctTeam or s_LocalPlayer.teamId == 0 then
		s_Target = "team"

	-- Display squad message.
	elseif p_Channel == ChatChannelType.CctSquad then
		s_Target = "squad"
	else
		goto continue
	end

	s_Table = {author = s_OtherPlayer.name, content = p_Message, target = s_Target, playerRelation = s_PlayerRelation}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))

	::continue::

	-- A new chat message is being created; 
	-- prevent the game from rendering it.
	p_Hook:Return()
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

return IncomingMessages
