LinkLuaModifier("modifier_crippling_decay_aura", "abilities/buildings/crippling_decay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crippling_decay_aura_debuff", "abilities/buildings/crippling_decay.lua", LUA_MODIFIER_MOTION_NONE)

crippling_decay = class({})
function crippling_decay:GetIntrinsicModifierName() return "modifier_crippling_decay_aura" end

modifier_crippling_decay_aura = class({})

function modifier_crippling_decay_aura:IsAura() return true end
function modifier_crippling_decay_aura:IsHidden() return true end
function modifier_crippling_decay_aura:GetAuraDuration() return 0.5 end

function modifier_crippling_decay_aura:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_crippling_decay_aura:GetAuraSearchFlags()
  return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_crippling_decay_aura:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_crippling_decay_aura:GetAuraSearchType()
  return DOTA_UNIT_TARGET_ALL
end

function modifier_crippling_decay_aura:GetModifierAura()
  return "modifier_crippling_decay_aura_debuff"
end

function modifier_crippling_decay_aura:IsAuraActiveOnDeath()
  return false
end

function modifier_crippling_decay_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_crippling_decay_aura:OnCreated()
  self.chance = self:GetAbility():GetSpecialValueFor("chance")
end

function modifier_crippling_decay_aura:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    if RollPercentage(self.chance) then
      target:AddNewModifier(self.parent, self.ability, "modifier_crippling_decay_debuff", {})

      local stackCount = target:GetModifierStackCount("modifier_crippling_decay_debuff", self.parent)
      local newCount = math.min(stackCount + 1, 38)
      target:SetModifierStackCount("modifier_crippling_decay_debuff", self.parent, newCount)
    end
  end
end

function modifier_crippling_decay_aura:GetEffectName()
  return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end


------------------------------

modifier_crippling_decay_aura_debuff = class({})

function modifier_crippling_decay_aura_debuff:IsDebuff() return true end

function modifier_crippling_decay_aura_debuff:OnCreated(table)
  self.bonus_damage_percent = self:GetAbility():GetSpecialValueFor("bonus_damage_percent")
end

function modifier_crippling_decay_aura_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
  }
  return funcs
end

function modifier_crippling_decay_aura_debuff:GetModifierIncomingDamage_Percentage()
  return self.bonus_damage_percent
end

------------------------------

modifier_crippling_decay_debuff = class({})

function modifier_crippling_decay_debuff:IsDebuff() return true end

function modifier_crippling_decay_debuff:OnCreated(table)
  self.move_slow = self:GetAbility():GetSpecialValueFor("move_slow")
  self.max_move_slow = self:GetAbility():GetSpecialValueFor("max_move_slow")
end

function modifier_crippling_decay_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_crippling_decay_debuff:GetModifierMoveSpeedBonus_Percentage()
  return self.move_slow * self:GetStackCount()
end