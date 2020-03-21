local shopTables = require("tables/custom_shop")

function GameMode:InitializeShopData()
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
  
  local maxStock = 30
  for _,shopItems in ipairs(shopTables) do
    for _,itemData in ipairs(shopItems) do
      local itemname = itemData.itemname
      local cost = itemData.cost
      local income = itemData.income
      local initial_cd = itemData.initial_cd
      local cd = itemData.cd
      local unit = itemData.unit

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
      })

      StartRestockTimer(shopKey, initial_cd)
    end
  end

  CustomGameEventManager:Send_ServerToPlayer(player, "setup_shop", {})
end

function StartRestockTimer(shopKey, initial_cd)
  Timers:CreateTimer(initial_cd, function()
    local itemData = CustomNetTables:GetTableValue("custom_shop", shopKey)
    local stock = itemData.stock

    if stock < MAX_ITEM_STOCK then
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

  -- Make sure we have enough resources to buy this item
  if hero:GetGold() < cost then
    SendErrorMessage(playerID, "#error_not_enough_gold")
    return false
  end

  -- Make sure the item is in stock
  if stock <= 0 then
    SendErrorMessage(playerID, "#error_out_of_stock")
    return false
  end

  -- Make the payment
  hero:ModifyGold(-cost, false, 0)

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
    })

  -- Play success sound
  EmitSoundOnClient("General.Buy", hero:GetPlayerOwner())

  -- Send the creep
  SendCreep(hero, unit, income)
end