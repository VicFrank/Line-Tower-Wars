modifier_max_health = class({})

function modifier_max_health:IsHidden() return true end

function modifier_max_health:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_max_health:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
  }
end

function modifier_max_health:GetModifierExtraHealthBonus()
  return self:GetStackCount()
end