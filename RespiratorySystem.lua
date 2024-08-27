--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : RespiratorySystemModule.lua
	Date : 8/24/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 

	This module manages the player's respiratory system and its effects, including:
	- Breathing mechanics
	- Effects of cold and hypoxemia

	The module handles the following:
	- **Breathing In:** Increases oxygen level in the oxygen module.
	- **Breathing Out:** Expels CO2 with potential minor effects.
	- **Cold Symptoms:** Reduces breath rate when the player has a cold.
	- **Hypoxemia:** Damages the player over time if breath rate falls below 5.

	The `Respirate` function continuously manages breathing, applies cold symptoms, and checks for hypoxemia.
-]]
--!nonstrict
local RespiratorySystem = {}
RespiratorySystem.__index = RespiratorySystem

function RespiratorySystem.new(player)
	local self = setmetatable({}, RespiratorySystem)
	self.player = player
	self.breathRate = 12
	return self
end

function RespiratorySystem:BreatheIn(oxygenModule)
	oxygenModule:UpdateOxygenLevel(5)
end

function RespiratorySystem:BreatheOut()
	-- not done
end

function RespiratorySystem:ApplyColdSymptoms()
	local currentDisease = self.player:GetAttribute("CurrentDisease")
	if currentDisease == "Cold" then
		self.breathRate = math.max(self.breathRate - 1, 6) 
	end
end

function RespiratorySystem:CheckHypoxemia()
	if self.breathRate < 5 then
		while self.breathRate < 5 and self.player.Character.Humanoid.Health > 0 do
			self.player.Character.Humanoid.Health = self.player.Character.Humanoid.Health - 30
			wait(2)
		end
	end
end

function RespiratorySystem:Respirate(oxygenModule)
	self:BreatheIn(oxygenModule)
	self:BreatheOut()
	self:ApplyColdSymptoms()
	self:CheckHypoxemia()
end

return RespiratorySystem
