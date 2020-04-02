LinkLuaModifier("modifier_frost_attack", "abilities/buildings/frost_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frost_attack_debuff", "abilities/buildings/frost_attack.lua", LUA_MODIFIER_MOTION_NONE)

frost_attack = class({})
function frost_attack:GetIntrinsicModifierName() return "modifier_frost_attack" end

---------------------

modifier_frost_attack = class({})

function modifier_frost_attack:IsHidden() return true end

function modifier_frost_attack:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
  self.radius = attacker:GetKeyValue("SplashRadius") or 0
end

function modifier_frost_attack:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_frost_attack:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    if self.radius == 0 then
      local stackCount = target:GetModifierStackCount(
        "modifier_frost_attack_debuff",
        self:GetCaster()
      )

      target:AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "modifier_frost_attack_debuff",
        {duration = self.duration}
      )

      target:SetModifierStackCount(
        "modifier_frost_attack_debuff",
        self:GetCaster(),
        stackCount + 1
      )
    else
      local enemies = FindEnemiesInRadius(target, self.radius)

      for _,enemy in pairs(enemies) do
        local stackCount = enemy:GetModifierStackCount(
          "modifier_frost_attack_debuff",
          self:GetCaster()
        )

        enemy:AddNewModifier(
          self:GetCaster(),
          self:GetAbility(),
          "modifier_frost_attack_debuff",
          {duration = self.duration}
        )

        enemy:SetModifierStackCount(
          "modifier_frost_attack_debuff",
          self:GetCaster(),
          stackCount + 1
        )
      end
    end
    
  end
end
---------------------

modifier_frost_attack_debuff = class({})

function modifier_frost_attack_debuff:IsHidden() return false end
function modifier_frost_attack_debuff:IsDebuff() return true end

function modifier_frost_attack_debuff:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.initial_slow = self.ability:GetSpecialValueFor("initial_slow")
  self.max_slow = self.ability:GetSpecialValueFor("max_slow")
end

function modifier_frost_attack_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_frost_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
  if not IsServer() then return end

  local stacks = self:GetStackCount()
  local slow = math.min(self.initial_slow * stacks, self.max_slow)

  return slow
end

function modifier_frost_attack_debuff:GetStatusEffectName()
  return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_frost_attack_debuff:StatusEffectPriority()
  return FX_PRIORITY_CHILLED
end

function modifier_frost_attack_debuff:GetEffectName()
  return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_frost_attack_debuff:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end
