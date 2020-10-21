LinkLuaModifier("modifier_custom_cleave", "abilities/creeps/custom_cleave.lua", LUA_MODIFIER_MOTION_NONE)

custom_cleave = class({})
function custom_cleave:GetIntrinsicModifierName() return "modifier_custom_cleave" end

modifier_custom_cleave = class({})

function modifier_custom_cleave:IsHidden() return true end

function modifier_custom_cleave:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.cleave_damage = self.ability:GetSpecialValueFor("cleave_damage")
  self.cleave_radius = self.ability:GetSpecialValueFor("cleave_radius")
end

function modifier_custom_cleave:OnRefresh()
  self.cleave_damage = self.ability:GetSpecialValueFor("cleave_damage")
  self.cleave_radius = self.ability:GetSpecialValueFor("cleave_radius")
end

function modifier_custom_cleave:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED
  }
  return funcs
end

function modifier_custom_cleave:OnAttackLanded(params)
  if not IsServer() then return end

  local attacker = params.attacker
  local target = params.target
  local damage = params.damage

  if attacker == self:GetParent() then
    local particleName = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
    local enemies = FindEnemiesInRadius(attacker, 150, target:GetAbsOrigin())

    for _,enemy in pairs(enemies) do
      if IsCustomBuilding(enemy) and (enemy:GetEntityIndex() ~= target:GetEntityIndex()) then
        ApplyDamage({
          victim = enemy,
          attacker = attacker,
          damage = damage * self.cleave_damage / 100,
          damage_type = DAMAGE_TYPE_PHYSICAL,
          ability = self:GetAbility()
        })
      end
    end
  end
end