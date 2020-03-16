function item_building_sell:OnSpellStart()
  if not IsServer() then return end
  
  local caster = self:GetCaster()
  local ability = self

  caster:AddEffects(EF_NODRAW)
  caster:ForceKill(true)
end
