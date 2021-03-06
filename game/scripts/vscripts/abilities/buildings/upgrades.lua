function ResourceCheck(keys)
  local caster = keys.caster
  local ability = keys.ability
  local playerID = caster:GetPlayerOwnerID()
  local hero = caster:GetOwner()

  local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0

  -- If this isn't the main selected unit, don't show error messages
  local mainSelection = CDOTA_PlayerResource:GetMainSelectedEntity(playerID)
  local showErrors = mainSelection == caster:entindex()

  if hero:GetCustomGold() < gold_cost then
    if showErrors then
      SendErrorMessage(playerID, "#error_not_enough_gold")
    end
    ability:EndChannel(true)
    Timers:CreateTimer(.03, function()
      ability:EndChannel(true)
    end)
    ability.refund = false
    return false
  end

  if not ability:HasResearched(playerID) then
    if showErrors then
      SendErrorMessage(playerID, "#error_not_researched")
    end
    ability:EndChannel(true)
    Timers:CreateTimer(.03, function()
      ability:EndChannel(true)
    end)
    ability.refund = false
    return false
  end

  hero:ModifyCustomGold(-gold_cost)
  ability.refund = true

  return true
end

function UpgradeBuilding(keys)
  local caster = keys.caster
  local ability = keys.ability
  local new_unit = keys.UnitName
  local playerID = caster:GetPlayerOwnerID()
  local hero = caster:GetOwner()
  local currentHealthPercentage = caster:GetHealthPercent() * 0.01
  local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0

  -- Keep the gridnav blockers, hull radius and orientation
  local blockers = caster.blockers
  local hull_radius = caster:GetHullRadius()
  local angle = caster:GetAngles()

  -- New building
  local building = BuildingHelper:UpgradeBuilding(caster, new_unit)
  building:SetHullRadius(hull_radius)

  -- Add the self destruct item
  -- local self_destruct_item = CreateItem("item_building_sell", hero, hero)
  -- building:AddItem(self_destruct_item)

  -- If the building to upgrade is selected, change the selection to the new one
  if PlayerResource:IsUnitSelected(playerID, caster) then
    PlayerResource:AddToSelection(playerID, building)
  end

  -- Add the gold cost for refund purposes
  building.gold_cost = caster.gold_cost + gold_cost
  
  -- Remove old building entity
  caster:RemoveSelf()

  local newRelativeHP = math.max(building:GetMaxHealth() * currentHealthPercentage, 1)
  building:SetHealth(newRelativeHP)

  building:UpdateResearchAbilitiesActive()
end

function RefundUpgradePrice(keys)
  local caster = keys.caster
  local ability = keys.ability
  local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0
  local playerID = caster:GetPlayerOwnerID()
  local hero = caster:GetOwner()
  
  if ability.refund then
    hero:ModifyCustomGold(gold_cost)
  end
end