LinkLuaModifier("modifier_deathly_regen", "abilities/creeps/deathly_regen.lua", LUA_MODIFIER_MOTION_NONE)

deathly_regen = class({})
function deathly_regen:GetIntrinsicModifierName() return "modifier_deathly_regen" end

modifier_deathly_regen = class({})

function modifier_deathly_regen:IsHidden() return true end

function modifier_deathly_regen:OnCreated()
  local ability = self:GetAbility()

  self.heal = ability:GetSpecialValueFor("heal")
  self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_deathly_regen:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_deathly_regen:OnDeath(params)
  if not IsServer() then return end

  local parent = self:GetParent()

  if params.unit == parent then
    local allies = FindAlliesInRadius(parent, self.radius)

    for _,ally in pairs(allies) do
      ally:Heal(self.heal, parent)
    end
  end
end