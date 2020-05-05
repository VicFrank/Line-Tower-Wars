function CDOTA_BaseNPC:GetCustomGold()
  local playerID = self:GetPlayerOwnerID()
  return GetCustomGold(playerID)
end

function CDOTA_BaseNPC:SetCustomGold(gold)
  SetCustomGold(self:GetPlayerOwnerID(), gold)
end

function CDOTA_BaseNPC:ModifyCustomGold(value)
  self:SetCustomGold(math.max(0, self:GetCustomGold() + value))
end

function GetCustomGold(playerID)
  local hero = PlayerResource:GetSelectedHeroEntity(playerID)
  if not hero then return end
  if not hero.gold then
    hero.gold = 0
  end
  return hero.gold
end

function SetCustomGold(playerID, gold)
  -- update their real gold, for spectators
  PlayerResource:SetGold(playerID, gold, false)
  local hero = PlayerResource:GetSelectedHeroEntity(playerID)
  if not hero then return end
  hero.gold = gold
  UpdateNetTable(playerID)
end

function ModifyCustomGold(playerID, value)
  SetCustomGold(playerID, math.max(0, GetCustomGold(playerID) + value))
end

function UpdateNetTable(playerID)
  CustomNetTables:SetTableValue("custom_shop", "gold" .. playerID, {
    gold = GetCustomGold(playerID),
  })
end