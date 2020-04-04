LinkLuaModifier("modifier_unholy_miasma", "abilities/buildings/unholy_miasma.lua", LUA_MODIFIER_MOTION_NONE)

unholy_miasma = class({})
function unholy_miasma:GetIntrinsicModifierName() return "modifier_unholy_miasma" end

modifier_unholy_miasma = class({})

function modifier_unholy_miasma:IsHidden() return false end

function modifier_unholy_miasma:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.min_splash = self.ability:GetSpecialValueFor("min_splash")
  self.max_splash = self.ability:GetSpecialValueFor("max_splash")
  self.splash_increase = self.ability:GetSpecialValueFor("splash_increase")
  self.loss_per_second = self.ability:GetSpecialValueFor("loss_per_second")

  self:SetStackCount(self.min_splash)

  if IsServer() then self:StartIntervalThink(1) end
end

function modifier_unholy_miasma:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_unholy_miasma:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.caster then
    local currentStacks = self:GetStackCount()
    self:SetStackCount(math.min(self.max_splash, currentStacks + self.splash_increase))
  end
end

function modifier_unholy_miasma:OnIntervalThink()
  local currentStacks = self:GetStackCount()
  self:SetStackCount(math.max(self.min_splash, currentStacks - self.loss_per_second))
end