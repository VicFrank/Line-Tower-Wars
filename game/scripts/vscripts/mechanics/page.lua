function ChangePage(keys)
  local tower = keys.caster
  local player = tower:GetOwner()
  local playerID = player:GetPlayerID()
  local team = player:GetTeam()
  local pos = tower:GetAbsOrigin()
  local newName = keys.tower
  
  local items = {}
  for i=0, 8 do
    local item = tower:GetItemInSlot(i)
    if item then
      table.insert(items,item)
    end
  end
  
  -- Kill the old building
  tower:AddEffects(EF_NODRAW) --Hide it, so that it's still accessible after this script
  tower.upgraded = true --Skips visual effects
  tower:ForceKill(true) --Kill the tower
  
  -- Create the new building
  local new_building = BuildingHelper:PlaceBuilding(playerID, newName, pos, BuildingHelper:GetConstructionSize(newName), BuildingHelper:GetBlockPathingSize(newName), angle)
  
  -- Save the Gold Cost
  new_building.gold_cost = tower.gold_cost
  
  -- Add Old Building's Items to the new tower
  for _,v in pairs(items) do
    new_building:AddItem(v)
  end
  
  -- If the building to ugprade is selected, change the selection to the new one
  if PlayerResource:IsUnitSelected(playerID, tower) then
    PlayerResource:AddToSelection(playerID, new_building)
  end

  new_building:UpdateResearchAbilitiesActive()

  return new_building
end