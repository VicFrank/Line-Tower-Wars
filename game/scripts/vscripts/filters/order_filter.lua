function GameMode:OrderFilter(filterTable)
  -- for k, v in pairs( filterTable ) do
  --  print("Order: " .. k .. " " .. tostring(v) )
  -- end

  local playerID = filterTable["issuer_player_id_const"]
  local units = filterTable["units"]
  local order_type = filterTable["order_type"]
  local issuer = filterTable["issuer_player_id_const"]
  local entindex_ability = filterTable["entindex_ability"]
  
  local selectedEntities = PlayerResource:GetSelectedEntities(playerID)
  local mainSelectedEntity = PlayerResource:GetMainSelectedEntity(playerID)
  local firstUnit = nil

  if mainSelectedEntity ~= nil then
    firstUnit = EntIndexToHScript(mainSelectedEntity)
  end

  -- Get the source of the command so we can properly use bots to build buildings
  for _,entindex in pairs(units) do
    local unit = EntIndexToHScript(entindex)

    if IsInToolsMode() then
      unit.issuer_player_id = 0
    elseif playerID < 0 then
      unit.issuer_player_id = nil
    else
      unit.issuer_player_id = playerID
    end
  end

  if entindex_ability and entindex_ability ~= 0 then
    local queue = filterTable["queue"] == 1
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

    local ability = EntIndexToHScript(entindex_ability)
    if ability == null then return true end
    local abilityName = ability:GetAbilityName()

    local entityList = PlayerResource:GetSelectedEntities(issuer)
    if not entityList or #entityList == 1 then return true end

    for _,entityIndex in pairs(entityList) do
      local caster = EntIndexToHScript(entityIndex)
      -- Make sure the original caster unit doesn't cast twice
      if caster and caster ~= unit and caster:HasAbility(abilityName) then
        local abil = caster:FindAbilityByName(abilityName)
        if abil and abil:IsFullyCastable() then

          caster.skip = true
          if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
            ExecuteOrderFromTable({UnitIndex = entityIndex, OrderType = order_type, Position = point, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

          elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET then
            ExecuteOrderFromTable({UnitIndex = entityIndex, OrderType = order_type, TargetIndex = targetIndex, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

          elseif order_type == DOTA_UNIT_ORDER_CAST_TOGGLE then
            if abil:GetToggleState() == ability:GetToggleState() then --order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
              ExecuteOrderFromTable({UnitIndex = entityIndex, OrderType = DOTA_UNIT_ORDER_CAST_TOGGLE, AbilityIndex = abil:GetEntityIndex(), Queue = queue})    
            end
          else
            ExecuteOrderFromTable({UnitIndex = entityIndex, OrderType = order_type, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
          end
        end
      end
    end
  end

  return true
end