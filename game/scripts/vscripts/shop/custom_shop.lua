require("tables/custom_shop")

function GameMode:SetupShopForPlayer(playerID)
  local shopTables = g_shop_tables

  for i=1,#shopTables do
    local shopItems = shopTables[i]
    for itemIndex=1,#shopItems do
      local itemData = shopItems[i]

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
          restock_time = cd,
          purchase_time = GameRules:GetGameTime() - initial_cd,
      })
    end
  end
end

function GetShopItemKey(itemname, playerID)
  return itemname .. playerID
end

function OnAttemptPurchase(eventSourceIndex, args)
  local playerID = args.PlayerID
  local itemname = args.itemname
  local hero = PlayerResource:GetSelectedHeroEntity(playerID)
  local purchase_time = GameRules:GetGameTime()

  local shopKey = GetShopItemKey(itemname, playerID)
  local itemData = CustomNetTables:GetTableValue("custom_shop", shopKey)

  local cost = itemData.cost
  local stock = itemData.stock
  local restock_time = itemData.restock_time
  local income = itemData.income
  local unit = itemData.unit

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
      purchase_time = purchase_time,
    })

  -- Restock after restock_time has passed
  if (restock_time > 0) then
    Timers:CreateTimer(restock_time, function()
      -- Only restock if it's still the same round
      -- Since time has passed, we need to reget the net table value
      local currentItemData = CustomNetTables:GetTableValue("custom_shop", shopKey)

      CustomNetTables:SetTableValue("custom_shop",
      shopKey,
      {
        playerID = playerID,
        itemname = itemname,
        cost = cost,
        unit = unit,
        income = income,
        stock = stock + 1,
        restock_time = restock_time,
        purchase_time = nil,
      })
    end)
  end

  -- Play success sound
  EmitSoundOnClient("General.Buy", hero:GetPlayerOwner())

  -- Give the hero the item
  local item = hero:AddItemByName(itemname)
  item.income = income
  item.unit = unit
end