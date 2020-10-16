local shopTables = require("tables/custom_shop")
local researchTypes = require("tables/research")

function GameMode:InitializeShopData()
  -- Load the creeps in each tier
  for tier,shopItems in ipairs(shopTables) do
    local shopItems = shopTables[tier]
    local items = {}

    for _,itemData in ipairs(shopItems) do
      local itemname = itemData.itemname
      table.insert(items, itemname)
    end

    CustomNetTables:SetTableValue("custom_shop", "tier" .. tier, items)
  end
end

function GameMode:SetupShopForPlayer(playerID)
  local player = PlayerResource:GetPlayer(playerID)
  
  -- Load the creep items for the player
  local maxStock = 30
  for _,shopItems in ipairs(shopTables) do
    for _,itemData in ipairs(shopItems) do
      local itemname = itemData.itemname
      local cost = itemData.cost
      local income = itemData.income
      local initial_cd = itemData.initial_cd
      local cd = itemData.cd
      local unit = itemData.unit
      local max_stock = itemData.max_stock

      local shopKey = GetShopItemKey(itemname, playerID)

      CustomNetTables:SetTableValue("custom_shop",
        shopKey,
        {
          playerID = playerID,
          itemname = itemname,
          unit = unit,
          cost = cost,
          income = income,
          stock = 0,
          restock_time = GameRules:GetGameTime() + initial_cd,
          cooldown_length = initial_cd,
          cd = cd,
          max_stock = max_stock,
        }
      )

      StartRestockTimer(shopKey, initial_cd)
    end
  end

  -- Load the research points
  local itemname = "research_point"
  local shopKey = GetShopItemKey(itemname, playerID)

  CustomNetTables:SetTableValue("custom_shop",
    shopKey,
    {
      playerID = playerID,
      unspent = STARTING_RESEARCH_POINTS,
      remaining = MAX_RESEARCH_POINTS - STARTING_RESEARCH_POINTS,
      cost = RESEARCH_POINT_BASE_COST
    }
  )

  -- Load the research tiers
  for _,research in ipairs(researchTypes) do
    for i=1,3 do
      local researchTier = research .. i
      local shopKey = GetShopItemKey(researchTier, playerID)

      local itemTable = {
        playerID = playerID,
        research = researchTier,
        purchased = false,
        purchaseable = true,
        tier = i,
        type = research
      }

      -- tier 2 and 3 require having tier 1 purchased
      if i > 1 then
        itemTable["requires"] = GetShopItemKey(research .. 1, playerID)
        itemTable["purchaseable"] = false
      end

      CustomNetTables:SetTableValue("custom_shop", shopKey, itemTable)
    end
  end

  CustomGameEventManager:Send_ServerToPlayer(player, "setup_shop", {})
end

function StartRestockTimer(shopKey, initial_cd)
  Timers:CreateTimer(initial_cd, function()
    local itemData = CustomNetTables:GetTableValue("custom_shop", shopKey)
    local stock = itemData.stock

    if stock < itemData.max_stock then
      CustomNetTables:SetTableValue(
        "custom_shop",
        shopKey,
        {
          playerID = itemData.playerID,
          itemname = itemData.itemname,
          cost = itemData.cost,
          unit = itemData.unit,
          income = itemData.income,
          stock = stock + 1,
          restock_time = GameRules:GetGameTime() + itemData.cd,
          cooldown_length = itemData.cd,
          cd = itemData.cd,
          max_stock = itemData.max_stock,
      })
    else
      return 1
    end

    return itemData.cd
  end)
end

function GetShopItemKey(itemname, playerID)
  return itemname .. playerID
end

function OnAttemptPurchase(eventSourceIndex, args)
  local playerID = args.PlayerID
  local itemname = args.itemname
  local hero = PlayerResource:GetSelectedHeroEntity(playerID)

  local shopKey = GetShopItemKey(itemname, playerID)
  local itemData = CustomNetTables:GetTableValue("custom_shop", shopKey)

  local cost = itemData.cost
  local stock = itemData.stock
  local restock_time = itemData.restock_time
  local income = itemData.income
  local unit = itemData.unit
  local cooldown_length = itemData.cooldown_length

  if GameRules:IsGamePaused() then
    SendErrorMessage(playerID, "#error_game_paused")
    return false
  end

  if stock <= 0 then
    SendErrorMessage(playerID, "#error_out_of_stock")
    return false
  end

  if hero:GetCustomGold() < cost then
    SendErrorMessage(playerID, "#error_not_enough_gold")
    return false
  end

  if hero.numSent > MAX_CREEPS then
    SendErrorMessage(playerID, "#error_too_many_creeps")
    return false
  end

  -- Make the payment
  hero:ModifyCustomGold(-cost)

  -- Successful purchase, update stock
  CustomNetTables:SetTableValue("custom_shop",
    shopKey,
    {
      playerID = playerID,
      itemname = itemname,
      unit = unit,
      cost = cost,
      income = income,
      stock = stock - 1,
      restock_time = restock_time,
      cooldown_length = cooldown_length,
      cd = itemData.cd,
      max_stock = itemData.max_stock,
    })

  -- Send the creep
  SendCreep(hero, unit, income)
end

function OnAttemptResearch(eventSourceIndex, args)
  local playerID = args.PlayerID
  local itemname = args.itemname

  local shopKey = GetShopItemKey(itemname, playerID)
  local itemData = CustomNetTables:GetTableValue("custom_shop", shopKey)
  local research = itemData.research
  local purchased = itemData.purchased
  local purchaseable = itemData.purchaseable
  local tier = itemData.tier
  local requires = itemData.requires

  local researchPoints = GetResearchPoints(playerID)

  if GameRules:IsGamePaused() then
    SendErrorMessage(playerID, "#error_game_paused")
    return false
  end

  if researchPoints < 1 then
    SendErrorMessage(playerID, "#error_not_enough_research")
    return false
  end

  if purchased ~= 0 then
    SendErrorMessage(playerID, "#error_already_purchased")
    return false
  end

  if purchaseable == 0 then
    SendErrorMessage(playerID, "#error_cant_research")
    return false
  end

  -- Spend the research point and add the purchased research
  SpendResearchPoint(playerID)
  CompleteResearch(playerID, research)
end

function BuyResearchPoint(eventSourceIndex, args)
  local playerID = args.PlayerID
  local nettable = CustomNetTables:GetTableValue("custom_shop", "research_point" .. playerID)

  local unspent = nettable.unspent
  local remaining = nettable.remaining
  local cost = nettable.cost

  local gold = GetCustomGold(playerID)

  if GameRules:IsGamePaused() then
    SendErrorMessage(playerID, "#error_game_paused")
    return false
  end

  if gold < cost then
    SendErrorMessage(playerID, "#error_not_enough_gold")
    return false
  end

  if remaining <= 0 then
    SendErrorMessage(playerID, "#error_already_max_research")
    return false
  end

  AddResearchPoint(playerID)
end