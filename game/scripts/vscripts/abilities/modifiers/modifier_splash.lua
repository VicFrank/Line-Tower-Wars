modifier_splash = class({})

function modifier_splash:GetTexture()
  return "black_dragon_splash_attack"
end

function modifier_splash:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_splash:OnCreated()
  if not IsServer() then return end

  self.parent = self:GetParent()
  self.splash = self.parent:GetSplashRadius()

  self:SetStackCount(self.splash)
end