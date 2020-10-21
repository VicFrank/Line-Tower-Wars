LinkLuaModifier("modifier_undead", "abilities/creeps/undead.lua", LUA_MODIFIER_MOTION_NONE)

undead = class({})
function undead:GetIntrinsicModifierName() return "modifier_undead" end

modifier_undead = class({})

function modifier_undead:IsHidden() return true end

function modifier_undead:OnCreated()
  local ability = self:GetAbility()

  self.delay = ability:GetSpecialValueFor("delay")
  self.health_percent = ability:GetSpecialValueFor("health_percent")
end

function modifier_undead:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH,
  }
end

function modifier_undead:OnDeath(keys)
  if IsServer() then
    local unit = keys.unit
    local parent = self:GetParent()

    if parent == unit then
      local name = parent:GetUnitName()
      local position = parent:GetAbsOrigin()
      local lane = parent.lane
      local sender = parent.sender
      local goal = parent.goal

      Timers:CreateTimer(2, function()
        local waveUnit = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
        waveUnit.lane = lane
        waveUnit.sender = sender
        waveUnit:SetGoal(goal)

        waveUnit:SetMinimumGoldBounty(0)
        waveUnit:SetMaximumGoldBounty(0)

        waveUnit:SetHealth(waveUnit:GetMaxHealth() * (self.health_percent / 100))

        waveUnit:RemoveAbility(self:GetAbility():GetAbilityName())
      end)
    end
  end
end