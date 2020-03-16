item_building_sell = class({})

function item_building_sell:OnSpellStart()
  if not IsServer() then return end
  
  local caster = self:GetCaster()
  local ability = self
  local hero = caster:GetOwner()
  local playerID = hero:GetPlayerID()
  local player = PlayerResource:GetPlayer(playerID)

  local playerId = caster:GetPlayerOwnerID()
  local hero =  PlayerResource:GetSelectedHeroEntity(playerId)

  local sellPrice = caster.gold_cost * 0.5

  hero:ModifyGold(sellPrice, true, 0)

  SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, tower, sellPrice, nil)

  caster:AddEffects(EF_NODRAW)
  caster:ForceKill(true)
end
