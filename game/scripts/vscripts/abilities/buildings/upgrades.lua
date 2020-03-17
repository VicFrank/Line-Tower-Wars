function ResourceCheck(keys)
  local caster = keys.caster
  local ability = keys.ability
  local playerID = caster:GetPlayerOwnerID()
  local hero = caster:GetOwner()

  -- local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0

  -- if hero:GetGold() < gold_cost then
  --   SendErrorMessage(playerID, "#error_not_enough_gold")
  --   ability:EndChannel(true)
  --   Timers:CreateTimer(.03, function()
  --     ability:EndChannel(true)
  --   end)
  --   ability.refund = false
  --   return false

  -- hero:ModifyGold(-gold_cost, false, 0)
  ability.refund = true
end

function UpgradeBuilding(keys)
  local caster = keys.caster
  local ability = keys.ability
  local new_unit = keys.UnitName
  local playerID = caster:GetPlayerOwnerID()
  local hero = caster:GetOwner()
  local currentHealthPercentage = caster:GetHealthPercent() * 0.01
  -- local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0
  local gold_cost = ability:GetGoldCost(1)

  -- Keep the gridnav blockers, hull radius and orientation
  local blockers = caster.blockers
  local hull_radius = caster:GetHullRadius()
  local angle = caster:GetAngles()

  -- New building
  local building = BuildingHelper:UpgradeBuilding(caster, new_unit)
  building:SetHullRadius(hull_radius)

  -- Add the self destruct item
  local self_destruct_item = CreateItem("item_building_sell", hero, hero)
  building:AddItem(self_destruct_item)

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

end

function RefundUpgradePrice(keys)
  local caster = keys.caster
  local ability = keys.ability
  
  -- local gold_cost = tonumber(ability:GetAbilityKeyValues()['GoldCost']) or 0
  local gold_cost = ability:GetGoldCost(1)
    
  local playerID = caster:GetPlayerOwnerID()

  local hero = caster:GetOwner()
  
  if ability.refund then
    hero:ModifyGold(gold_cost, false, 0)
  end
end