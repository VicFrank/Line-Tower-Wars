LinkLuaModifier("modifier_pressuring_water", "abilities/buildings/pressuring_water.lua", LUA_MODIFIER_MOTION_NONE)

pressuring_water = class({})
function pressuring_water:GetIntrinsicModifierName() return "modifier_pressuring_water" end

modifier_pressuring_water = class({})

function modifier_pressuring_water:IsHidden() return true end

function modifier_pressuring_water:OnCreated()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()

  self.max_bonus_damage = self.ability:GetSpecialValueFor("max_bonus_damage")
end

function modifier_pressuring_water:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_pressuring_water:OnAttackLanded(keys)
  if not IsServer() then return end

  local attacker = keys.attacker
  local target = keys.target
  local damage = keys.damage

  if attacker == self.parent then
    local maxDistance = self.parent:Script_GetAttackRange()
    local distance = (attacker:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()

    if distance > maxDistance then
      return
    else
      local distanceMultiplier = 1 - (distance / maxDistance)
      local damageMultiplier = distanceMultiplier * self.max_bonus_damage / 100

      ApplyDamage({
        victim = target,
        attacker = attacker,
        damage = damage * damageMultiplier,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self.ability
      })
    end
  end
end