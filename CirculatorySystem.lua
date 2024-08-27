--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : CirculatorySystem.lua
	Date : 8/24/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 

	This module manages the player's circulatory system, including:
	- Heart rate
	- Oxygen level
	- Blood pressure

	It handles bleeding effects when health drops below 30, reduces health over time with a delay, and checks for low blood pressure risks. The `Update` function continuously monitors and updates the player's circulatory status.
--]]
--!nonstrict
local CirculatorySystem = {}
CirculatorySystem.__index = CirculatorySystem

function CirculatorySystem.new(player)
	local self = setmetatable({}, CirculatorySystem)
	self.player = player
	self.heartRate = 70
	self.oxygenLevel = 100
	self.bloodPressure = 12 
	self.isBleeding = false
	self.BloodLiters = 15
	return self
end

function CirculatorySystem:UpdateHeartRate(newRate)
	self.heartRate = newRate
end

function CirculatorySystem:UpdateOxygenLevel(oxygenChange)
	self.oxygenLevel = math.clamp(self.oxygenLevel + oxygenChange, 0, 100)
	warn("Oxygen level updated to " .. self.oxygenLevel)
end

function CirculatorySystem:PumpBlood()
	if self.oxygenLevel > 0 then
		self.oxygenLevel = self.oxygenLevel - 1
	else
	end
end

function CirculatorySystem:CheckBleeding()
	local health = self.player.Character.Humanoid.Health
	if health < 30 and not self.isBleeding then 
		self.isBleeding = true
		local BloodParts = game:GetService("ReplicatedStorage").Assets.Blood:GetChildren()

		while health > 0 and self.isBleeding do
			local bloodPart = BloodParts[math.random(1, #BloodParts)]:Clone()
			local humanoidRootPartPosition = self.player.Character.HumanoidRootPart.Position
			bloodPart.CFrame = CFrame.new(humanoidRootPartPosition - Vector3.new(0, 3, 0))
			bloodPart.Parent = workspace

			self.BloodLitters = self.BloodLitters - 1

			if self.BloodLitters < 6 then
				if self.player and self.player:IsA("Player") then
					game.ReplicatedStorage.UnconsciousEvent:FireClient(self.player)
				else
				end

				self.player.Character.Humanoid.WalkSpeed = 0

				warn("Player has become unconscious!")
				break 
			end

			task.wait(5)
		end

		self.isBleeding = false
	end
end



function CirculatorySystem:MakeUnconscious()
	local humanoid = self.player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = true
		self.player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(self.player.Character.HumanoidRootPart.Position) * CFrame.Angles(math.rad(90), 0, 0) -- Make them lay down
	end
end

function CirculatorySystem:KillPlayer()
	local humanoid = self.player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0 
	end
end

function CirculatorySystem:CheckBloodPressure()
	if self.bloodPressure < 7 then
		-- not done
	end
end

function CirculatorySystem:Update()
	self:PumpBlood()
	self:CheckBleeding()
	self:CheckBloodPressure()
	self:MakeUnconscious()
end

return CirculatorySystem
