LinkLuaModifier("modifier_rejuvenating_spores", "abilities/buildings/rejuvenating_spores.lua", LUA_MODIFIER_MOTION_NONE)

rejuvenating_spores = class({})
function rejuvenating_spores:GetIntrinsicModifierName() return "modifier_rejuvenating_spores" end

modifier_rejuvenating_spores = class({})

function modifier_rejuvenating_spores:IsHidden() return true end

function modifier_rejuvenating_spores:OnCreated()
  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.heal_percent = self.ability:GetSpecialValueFor("heal_percent")
  self.radius = self.ability:GetSpecialValueFor("radius")
  self.knockback_distance = self.ability:GetSpecialValueFor("knockback")
  self.knockback_duration = self.ability:GetSpecialValueFor("knockback_duration")
end

function modifier_rejuvenating_spores:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_rejuvenating_spores:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.parent then
    local heal = damage * self.heal_percent / 100

    local allies = FindAlliesInRadius(self.parent, self.radius)

    for _,ally in pairs(allies) do
      if IsCustomBuilding(ally) then
        ally:Heal(heal, self.parent)
      end
    end

    local casterPosition = self.caster:GetAbsOrigin()

    local knockback = {
      should_stun = 1,                                
      knockback_duration = knockback_duration,
      duration = 0.3,
      knockback_distance = knockback_distance,
      knockback_height = 80,
      center_x = casterPosition.x,
      center_y = casterPosition.y,
      center_z = casterPosition.z,
    }

    target:AddNewModifier(self.parent, self.ability, "modifier_knockback", knockback)
  end
end