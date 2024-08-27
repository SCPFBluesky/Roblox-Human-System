--[[
	Writer: @SCPF_RedSky (most of the time)
	Name : NervousSystem.lua
	Date : 8/24/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 

	This module manages the player's body temperature and its effects, including:
	- Temperature adjustment based on environmental zones
	- Effects of hypothermia and hyperthermia

	The module handles the following:
	- **Temperature Handling:** Adjusts body temperature when entering or exiting temperature zones.
	- **Temperature Update:** Gradually adjusts body temperature towards a target temperature, with faster recovery when returning to normal.
	- **Temperature Effects:** Applies effects based on body temperature, including reduced breath rate for hypothermia and health reduction for hyperthermia. Severe hypothermia can simulate respiratory failure.

	The `UpdateTemperature` function continuously adjusts and monitors the player's body temperature and its effects.
--]]
--!nonstrict
local NervousSystem = {}
NervousSystem.__index = NervousSystem
local Debugging = true
function NervousSystem.new(player)
	local self = setmetatable({}, NervousSystem)
	self.player = player
	self.bodyTemp = player:GetAttribute("BodyTemperature") or 98.6
	self.targetTemp = 98.6 
	return self
end

function NervousSystem:HandleTemperatureChange(temp, action)
	warn("Handling temperature change. Action:", action, "Zone Temp:", temp, "Current Body Temp:", self.bodyTemp)

	if action == "enter" then
		self.targetTemp = temp
	elseif action == "exit" then
		self.targetTemp = 98.6 
	end
end

function NervousSystem:UpdateTemperature()
	local changeRate = 0.05
	local recoveryRate = 0.1 

	if self.bodyTemp > self.targetTemp then
		self.bodyTemp = math.max(self.bodyTemp - changeRate, self.targetTemp)
	elseif self.bodyTemp < self.targetTemp then
		local rate = self.targetTemp == 98.6 and recoveryRate or changeRate
		self.bodyTemp = math.min(self.bodyTemp + rate, self.targetTemp)
	end

	self:CheckTemperatureEffects()
	self.player:SetAttribute("BodyTemperature", self.bodyTemp)
end

function NervousSystem:CheckTemperatureEffects()

	if self.bodyTemp < 95 then
		self.player:SetAttribute("BreathRate", self.player:GetAttribute("BreathRate") - 1)
		if self.bodyTemp < 90 then
			self.player.Character:BreakJoints() 
		end
	elseif self.bodyTemp > 107 then
		self.player.Character.Humanoid.Health = self.player.Character.Humanoid.Health - 10
	end
end

return NervousSystem
