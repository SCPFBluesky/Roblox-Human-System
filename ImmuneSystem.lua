--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : ImmuneSystem.lua
	Date : 8/24/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 

	This module manages the player's immune system and disease effects, including:
	- Infection management
	- Disease symptoms and treatment

	The module handles the following:
	- **Fighting Infections:** Reduces the infection level based on immunity.
	- **Infection Management:** Assigns a disease to the player and sets the infection level.
	- **Symptoms Triggering:** Activates symptoms for different diseases (Rabies, Cold, Flu) and manages visual and auditory effects.
	- **Symptom Management:** Uses coroutines to simulate ongoing symptoms such as coughing.
	- **Disease Cure:** Cures the disease, removes symptoms, and restores normal player attributes.

	The `Update` function continuously monitors and updates the player's immune system status.
--]]
--!nonstrict
local ImmuneSystem = {}
ImmuneSystem.__index = ImmuneSystem
local CoughSounds = {
	"2637490235",
	"6333150725",
	"6333150436"
}

function ImmuneSystem.new(player)
	local self = setmetatable({}, ImmuneSystem)
	self.player = player
	self.symptomCoroutine = nil
	return self
end
function ImmuneSystem:FightInfection()
	local infectionLevel = self.player:GetAttribute("InfectionLevel")
	local immunityLevel = self.player:GetAttribute("ImmunityLevel")

	if infectionLevel > 0 then
		infectionLevel = math.clamp(infectionLevel - (immunityLevel / 10), 0, 100)
		self.player:SetAttribute("InfectionLevel", infectionLevel)
		warn("Fighting infection, new infection level: " .. infectionLevel)

		if infectionLevel == 0 then
			self:CureDisease()
		end
	end
end

function ImmuneSystem:Infect(disease)
	local currentDisease = self.player:GetAttribute("CurrentDisease")

	if currentDisease == "" then
		self.player:SetAttribute("CurrentDisease", disease)
		local infectionLevel = math.random(30, 100)
		self.player:SetAttribute("InfectionLevel", infectionLevel)
	end
end

function ImmuneSystem:TriggerSymptoms()
	local disease = self.player:GetAttribute("CurrentDisease")
	local infectionLevel = self.player:GetAttribute("InfectionLevel")

	if disease == "Rabies" and infectionLevel > 50 then
		self.Type = "Virus"
		self.FeverTemp = 103
		self.TimeUntillCure = 5 * 60
		self.CanImmuneSystemFight = false
		self.player:SetAttribute("CurrentSymptoms", "Erratic movement")
		warn("Rabies symptoms triggered.")
		self:StartSymptomCoroutine(function()
			while true do
					--notdone
				wait(1)
			end
		end)
	elseif disease == "Cold" then
		self.Type = "Virus"
		self.FeverTemp = 99
		self.CoughWaitTime = 9
		self.TimeUntillCure = 5 * 60
		self.CanImmuneSystemFight = true
		self.player:SetAttribute("CurrentSymptoms", "Coughing, Fever")
		warn("Cold symptoms triggered.")
		local feverBlur = game.Lighting:FindFirstChild("FeverBlur")
		if feverBlur then
			feverBlur.Enabled = true
		end
		self:StartSymptomCoroutine(function()
			while true do
				self:PlayCoughSound()
				wait(self.CoughWaitTime)
			end
		end)
	elseif disease == "Flu" then
		self.Type = "Virus"
		self.FeverTemp = 103
		self.TimeUntillCure = 500
		self.CanImmuneSystemFight = false
		self.player:SetAttribute("CurrentSymptoms", "Fatigue, Fever")
		self.player:SetAttribute("Walkspeed", 8)
		local feverBlur = game.Lighting:FindFirstChild("FeverBlur")
		if feverBlur then
			feverBlur.Enabled = true
		end
		self:StartSymptomCoroutine(function()
			while true do
				wait(1)
			end
		end)
	end
end

function ImmuneSystem:StartSymptomCoroutine(symptomFunction)
	if self.symptomCoroutine then
		coroutine.close(self.symptomCoroutine)
	end
	self.symptomCoroutine = coroutine.create(symptomFunction)
	coroutine.resume(self.symptomCoroutine)
end

function ImmuneSystem:PlayCoughSound()
	local head = self.player.Character and self.player.Character:FindFirstChild("Head")
	if head then
		local soundId = CoughSounds[math.random(1, #CoughSounds)]
		local coughSound = Instance.new("Sound", head)
		coughSound.SoundId = "rbxassetid://" .. soundId
		coughSound:Play()
		coughSound.Ended:Connect(function()
			coughSound:Destroy()
		end)
	end
end

function ImmuneSystem:CureDisease()
	self.player:SetAttribute("CurrentDisease", "")
	self.player:SetAttribute("CurrentSymptoms", "")
	self.player:SetAttribute("InfectionLevel", 0)
	self.player:SetAttribute("Walkspeed", 16)
	local feverBlur = game.Lighting:FindFirstChild("FeverBlur")
	if feverBlur then
		feverBlur.Enabled = false
	end
	if self.symptomCoroutine then
		coroutine.close(self.symptomCoroutine)
		self.symptomCoroutine = nil
	end
end

function ImmuneSystem:Update()
	self:FightInfection()
	self:TriggerSymptoms()
end

return ImmuneSystem
