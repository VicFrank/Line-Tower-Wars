income_modifier = class({})

function income_modifier:GetTexture()
  return "alchemist_goblins_greed"
end

function income_modifier:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function income_modifier:OnCreated()
  if not IsServer() then return end

  self.parent = self:GetParent()
  self.playerID = self.parent:GetPlayerOwnerID()
end