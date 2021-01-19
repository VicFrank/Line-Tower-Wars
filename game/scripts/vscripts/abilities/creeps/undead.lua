LinkLuaModifier("modifier_undead", "abilities/creeps/undead.lua", LUA_MODIFIER_MOTION_NONE)

undead = class({})
function undead:GetIntrinsicModifierName() return "modifier_undead" end

modifier_undead = class({})

function modifier_undead:IsHidden() return true end

function modifier_undead:OnCreated()
  local ability = self:GetAbility()

  self.delay = ability:GetSpecialValueFor("delay")
  self.health_percent = ability:GetSpecialValueFor("health_percent")

  if IsServer() then
    local parent = self:GetParent()

    if parent.respawned then return end

    self.minBounty = parent:GetMinimumGoldBounty()
    self.maxBounty = parent:GetMaximumGoldBounty()

    parent:SetMinimumGoldBounty(0)
    parent:SetMaximumGoldBounty(0)
  end
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
      if parent.respawned then return end
      local name = parent:GetUnitName()
      local position = parent:GetAbsOrigin()
      local lane = parent.lane
      local sender = parent.sender
      local goal = parent.goal
      local minBounty = self.minBounty
      local maxBounty = self.maxBounty
      local health_percent = self.health_percent
      local abilityName = self:GetAbility():GetAbilityName()

      Timers:CreateTimer(2, function()
        local waveUnit = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
        waveUnit.lane = lane
        waveUnit.sender = sender
        waveUnit:SetGoal(goal)
        waveUnit.respawned = true

        waveUnit:SetMinimumGoldBounty(minBounty)
        waveUnit:SetMaximumGoldBounty(maxBounty)

        waveUnit:SetHealth(waveUnit:GetMaxHealth() * (health_percent / 100))

        waveUnit:RemoveAbility(abilityName)
      end)
    end
  end
end