--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : MainScript.lua
	Date : 8/24/24
	ClassName : Script
	RunTime: Server
	Description: 

	This script manages the simulation of various physiological systems for players in the game. It initializes and updates:
	- **Circulatory System**
	- **Respiratory System**
	- **Immune System**
	- **Brain Functions**
	- **Nervous System**
	- **Temperature Zones**

	The script performs the following:
	- **Add Player Attributes:** Sets default attributes for player health, immunity, disease status, and body temperature.
	- **Setup Temperature Zones:** Initializes temperature zones and connects player entry/exit events to update the nervous system.
	- **Simulate Body Functions:** Creates instances of physiological systems and runs a continuous simulation that updates these systems.
	- **Disease Assignment:** Randomly assigns diseases (Cold, Flu, Rabies) to players upon joining.
	- **Player Events:** Handles player joining and character creation to start the simulation.

	The `simulateBody` function continuously updates the player's physiological systems while the player’s character exists in the game.
--]]
--!nonstrict
local Debugging = true
local Overture = require(game.ReplicatedStorage.Overture)
local CirculatorySystem = Overture:LoadLibrary("CirculatorySystem")
local RespiratorySystem = Overture:LoadLibrary("RespiratorySystem")
local ImmuneSystem = Overture:LoadLibrary("ImmuneSystem")
local Brain = Overture:LoadLibrary("Brain")
local NervousSystem = Overture:LoadLibrary("NervousSystem")
local Zone = Overture:LoadLibrary("Zone")


local function addAttributes(player)
	player:SetAttribute("Walkspeed", 16) 
	player:SetAttribute("ImmunityLevel", math.random(50, 100))
	player:SetAttribute("InfectionLevel", 0)
	player:SetAttribute("CurrentDisease", "")
	player:SetAttribute("CurrentSymptoms", "")
	player:SetAttribute("MentalHealthDisorder", "")
	player:SetAttribute("BodyTemperature", 98.6) 
	player:SetAttribute("BreathRate", 12) 
	player:SetAttribute("BloodPressure", 12)
end

local function setupTemperatureZones(player, nervousSystem)
	local zones = {}
	for _, part in pairs(game.Workspace.Temperatures:GetChildren()) do
		if part:IsA("BasePart") then
			local zone = Zone.new(part)
			local tempValue = part:FindFirstChild("Temp")
			if tempValue then
				zone.temp = tempValue.Value
				table.insert(zones, zone)

				zone.playerEntered:Connect(function(otherPlayer)
					if otherPlayer == player then
						warn("Player entered zone with temp:", zone.temp)
						nervousSystem:HandleTemperatureChange(zone.temp, "enter")
					end
				end)

				zone.playerExited:Connect(function(otherPlayer)
					if otherPlayer == player then
						warn("Player exited zone with temp:", zone.temp)
						nervousSystem:HandleTemperatureChange(zone.temp, "exit")
					end
				end)
			else
				warn("No Temp value found in part:", part.Name)
			end
		else
			warn("Ignored non-BasePart in Temperatures folder:", part.Name)
		end
	end
end

local function simulateBody(player)
	local humanCirculatory = CirculatorySystem.new(player)
	local humanRespiratory = RespiratorySystem.new(player)
	local humanImmune = ImmuneSystem.new(player)
	local brain = Brain.new(player)
	local nervousSystem = NervousSystem.new(player)

	setupTemperatureZones(player, nervousSystem)

	if math.random() < 0.2 then 
		humanImmune:Infect("Cold")
		warn("Player has caught a cold.")
	end
	if math.random() < 0.1 then 
		humanImmune:Infect("Flu")
		warn("Player has caught the flu.")
	end
	if math.random() < 0.05 then 
		humanImmune:Infect("Rabies")
		warn("Player has caught rabies.")
	end

	while player.Character and player.Character.Parent do
		humanImmune:Update()
		humanCirculatory:Update()
		--humanRespiratory:Update()
		brain:Update()
--		nervousSystem:Update()

		task.wait(1)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	addAttributes(player)
	player.CharacterAdded:Connect(function()
		simulateBody(player)
	end)
end)
