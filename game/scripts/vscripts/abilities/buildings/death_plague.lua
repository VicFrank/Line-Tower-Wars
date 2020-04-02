LinkLuaModifier("modifier_death_plague", "abilities/buildings/death_plague.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_death_plague_debuff", "abilities/buildings/death_plague.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gravestrike", "abilities/buildings/death_plague.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gravestrike_debuff", "abilities/buildings/death_plague.lua", LUA_MODIFIER_MOTION_NONE)

death_plague = class({})
function death_plague:GetIntrinsicModifierName() return "modifier_death_plague" end
gravestrike = class({})
function gravestrike:GetIntrinsicModifierName() return "modifier_gravestrike" end

---------------------------

modifier_death_plague = class({})

function modifier_death_plague:IsHidden() return true end

function modifier_death_plague:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_death_plague:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_death_plague:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    target:AddNewModifier(self.caster, self.ability, "modifier_death_plague_debuff", {duration = self.duration})
  end
end

------------------

modifier_death_plague_debuff = class({})

function modifier_death_plague_debuff:IsDebuff() return true end

function modifier_death_plague_debuff:OnCreated()
  self.damage_increase = self:GetAbility():GetSpecialValueFor("damage_increase")
end

function modifier_death_plague_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
  }
  return funcs
end

function modifier_death_plague_debuff:GetModifierIncomingDamage_Percentage()
  if not IsServer() then return end

  return self.damage_increase
end

---------------------------

modifier_gravestrike = class({})

function modifier_gravestrike:IsHidden() return true end

function modifier_gravestrike:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_gravestrike:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_gravestrike:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    target:AddNewModifier(self.caster, self.ability, "modifier_gravestrike_debuff", {duration = self.duration})
  end
end

------------------

modifier_gravestrike_debuff = class({})

function modifier_gravestrike_debuff:IsDebuff() return true end

function modifier_gravestrike_debuff:OnCreated()
  self.damage_increase = self:GetAbility():GetSpecialValueFor("damage_increase")
  self.chance = self:GetAbility():GetSpecialValueFor("chance")
  self.bonus_health_percent = self:GetAbility():GetSpecialValueFor("bonus_health_percent")

  local playerID = self:GetCaster():GetPlayerOwnerID()
  self.hero = PlayerResource:GetSelectedHeroEntity(playerID)
end

function modifier_gravestrike_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_gravestrike_debuff:GetModifierIncomingDamage_Percentage()
  if not IsServer() then return end

  return self.damage_increase
end

function modifier_gravestrike_debuff:OnDeath(keys)
  if not IsServer() then return nil end

  if keys.unit == self:GetParent() then
    if RollPercentage(self.chance) then
      -- reanimate as a skeleton with health equal to 125% of max health of the creep.
      local health = self:GetParent():GetBaseMaxHealth()
      local creep = SendCreep(self.hero, "skeleton", 0)
      creep:IncreaseMaxHealth(health - 1)
    end
  end
end