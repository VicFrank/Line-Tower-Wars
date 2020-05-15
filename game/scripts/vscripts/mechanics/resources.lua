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

--------------------------------------
-- Research Points
--------------------------------------

function GetResearchPoints(playerID)
  local nettable = CustomNetTables:GetTableValue("custom_shop", "research_point" .. playerID)
  return nettable.unspent
end

function AddResearchPoint(playerID)
  local shopKey = GetShopItemKey("research_point", playerID)
  local nettable = CustomNetTables:GetTableValue("custom_shop", shopKey)

  local unspent = nettable.unspent
  local remaining = nettable.remaining
  local cost = nettable.cost

  if remaining <= 0 then
    print("You can't buy anymore research points!")
    return false
  end

  CustomNetTables:SetTableValue("custom_shop", shopKey,
    {
      playerID = playerID,
      unspent = unspent + 1,
      remaining = remaining - 1,
      cost = cost + RESEARCH_POINT_COST_INCREASE
    }
  )
end

function SpendResearchPoint(playerID)
  local shopKey = GetShopItemKey("research_point", playerID)
  local nettable = CustomNetTables:GetTableValue("custom_shop", shopKey)

  local unspent = nettable.unspent
  local remaining = nettable.remaining
  local cost = nettable.cost

  if unspent <= 0 then
    print("You don't have any research points to spend")
    return false
  end

  CustomNetTables:SetTableValue("custom_shop", shopKey,
    {
      playerID = playerID,
      unspent = unspent - 1,
      remaining = remaining,
      cost = cost
    }
  )
end

--------------------------------------
-- Research
--------------------------------------

function UnlockResearch(playerID, research)
  local key = research .. playerID
  local nettable = CustomNetTables:GetTableValue("custom_shop", key)

  nettable.purchaseable = true

  CustomNetTables:SetTableValue("custom_shop", key, nettable)
end

function CompleteResearch(playerID, research)
  local key = research .. playerID
  local nettable = CustomNetTables:GetTableValue("custom_shop", key)
  local tier = nettable.tier
  local researchType = nettable.type

  -- Unlock the next two tiers of this type
  if tier == 1 then
    UnlockResearch(playerID, researchType .. 2)
    UnlockResearch(playerID, researchType .. 3)
  end

  -- Update this nettable
  nettable.purchased = true
  nettable.purchaseable = false

  CustomNetTables:SetTableValue("custom_shop", key, nettable)
end

function HasResearch(playerID, research)
  if playerID < 0 then return false end

  local key = research .. playerID
  local nettable = CustomNetTables:GetTableValue("custom_shop", key)

  return nettable.purchased
end

function CDOTA_BaseNPC:HasResearch(research)
  local playerID = self:GetPlayerOwnerID()  
  return HasResearch(playerID, research)
end
