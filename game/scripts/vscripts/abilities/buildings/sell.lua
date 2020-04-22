item_building_sell = class({})

function item_building_sell:OnChannelFinish(interrupted)
  if not IsServer() then return end
  if interrupted then return end
  
  local caster = self:GetCaster()
  local ability = self

  local playerID = caster:GetPlayerOwnerID()
  local player = PlayerResource:GetPlayer(playerID)
  local hero = PlayerResource:GetSelectedHeroEntity(playerID)

  local sellPrice = caster.gold_cost * 0.75

  hero:ModifyGold(sellPrice, true, 0)

  SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, caster, sellPrice, nil)

  caster:AddEffects(EF_NODRAW)
  caster:ForceKill(true)
end
