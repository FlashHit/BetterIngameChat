---@class OutgoingMessages
OutgoingMessages = class 'OutgoingMessages'

function OutgoingMessages:__init()
	Events:Subscribe('WebUI:OutgoingChatMessage', self, self.OnWebUIOutgoingChatMessage)
	Events:Subscribe('WebUI:SetCursor', self, self.OnWebUISetCursor)

	self.m_Timer = -1.0
end

function OutgoingMessages:OnWebUIOutgoingChatMessage(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local p_Target = s_DecodedData.target
	local p_Message = s_DecodedData.message
	local p_TargetName = s_DecodedData.targetName
	-- Trim the message.
	local s_From = p_Message:match"^%s*()"
 	p_Message = s_From > #p_Message and "" or p_Message:match(".*%S", s_From)

	-- Ignore if the message is empty.
	if p_Message:len() == 0 then
		return
	end

	NetEvents:Send('ClientServer_Chat', p_Target, p_Message, p_TargetName)
end

function OutgoingMessages:OnWebUISetCursor()
	InputManager:SetCursorPosition(WebUI:GetScreenWidth() / 2, WebUI:GetScreenHeight() / 2)
	WebUI:ResetKeyboard()
	self.m_Timer = 0.035
end

---@param p_DeltaTime number
---@param p_SimulationDeltaTime number
function OutgoingMessages:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_Timer < 0.0 then
		return
	end

	self.m_Timer = self.m_Timer - p_DeltaTime

	if self.m_Timer < 0.0 then
		self.m_Timer = -1.0
		WebUI:ResetMouse()
	end
end

return OutgoingMessages()
