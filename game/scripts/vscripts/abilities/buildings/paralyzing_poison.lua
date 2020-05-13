LinkLuaModifier("modifier_paralyzing_poison", "abilities/buildings/paralyzing_poison.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_paralyzing_poison_debuff", "abilities/buildings/paralyzing_poison.lua", LUA_MODIFIER_MOTION_NONE)

paralyzing_poison = class({})
function paralyzing_poison:GetIntrinsicModifierName() return "modifier_paralyzing_poison" end

modifier_paralyzing_poison = class({})

function modifier_paralyzing_poison:IsHidden() return true end

function modifier_paralyzing_poison:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_paralyzing_poison:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_paralyzing_poison:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target

  if attacker == self.parent then
    target:AddNewModifier(attacker, self.ability, "modifier_paralyzing_poison_debuff", {duration = self.duration})
  end
end

---------------------


modifier_paralyzing_poison_debuff = class({})

function modifier_paralyzing_poison_debuff:IsDebuff() return true end

function modifier_paralyzing_poison_debuff:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.slow = self.ability:GetSpecialValueFor("slow")
  self.dps = self.ability:GetSpecialValueFor("dps")

  self:StartIntervalThink(1)
  self:DamageTick()
end

function modifier_paralyzing_poison_debuff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
  return funcs
end

function modifier_paralyzing_poison_debuff:DamageTick()
  if IsServer() then

    local final_damage = ApplyDamage({
      attacker = self:GetCaster(),
      victim = self.parent,
      ability = self.ability,
      damage = self.dps,
      damage_type = DAMAGE_TYPE_MAGICAL,
      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    })
    
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self.parent, final_damage, nil)
  end
end

function modifier_paralyzing_poison_debuff:GetModifierMoveSpeedBonus_Percentage()
  return -self.slow
end

function modifier_paralyzing_poison_debuff:GetModifierAttackSpeedBonus_Constant()
  return -self.slow
end

function modifier_paralyzing_poison_debuff:OnIntervalThink()
  self:DamageTick()
end

function modifier_paralyzing_poison_debuff:GetEffectName()
  return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf"
end

function modifier_paralyzing_poison_debuff:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end