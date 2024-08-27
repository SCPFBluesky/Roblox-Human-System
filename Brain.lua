--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : Brain.lua
	Date : 8/24/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 

	This module manages the player's mental health disorders, including:
	- ADHD
	- Stroke risk
	More mental health conditions to come

	When a player is initialized, there is a 10% chance of having ADHD or a 5% chance of being at risk for a stroke. 
	- For ADHD, the player may randomly trigger a jumping symptom.
	- For a stroke, a random wait time between 4 to 8 minutes occurs before symptoms are triggered. 
	  The player will experience blurry vision and a ringing sound, followed by simulated death after 5 seconds.

	The `Update` function continuously monitors and triggers ADHD symptoms.
--]]
--!nonstrict
local Brain = {}
Brain.__index = Brain

function Brain.new(player)
	local self = setmetatable({}, Brain)
	self.player = player

	if math.random() < 0.1 then 
		self.player:SetAttribute("MentalHealthDisorder", "ADHD")
	elseif math.random() < 0.05 then 
		self.player:SetAttribute("MentalHealthDisorder", "Stroke")
		task.spawn(function() self:TriggerStroke() end)
	end

	return self
end

function Brain:TriggerADHDSymptom()
	if self.player:GetAttribute("MentalHealthDisorder") == "ADHD" then
		self.player.Character.Humanoid.Jump = true
	end
end

function Brain:TriggerStroke()
	task.wait(math.random(240, 480))

	if self.player:GetAttribute("MentalHealthDisorder") == "Stroke" then
		local strokeBlur = game.Lighting:FindFirstChild("StrokeBlur")
		if strokeBlur then
			strokeBlur.Enabled = true
		end
		local sound = Instance.new("Sound", self.player.Character)
		sound.SoundId = "rbxassetid://0" 
		sound:Play()

		wait(5)
		self.player.Character:BreakJoints() 
	end
end

function Brain:Update()
	self:TriggerADHDSymptom()
end

return Brain
