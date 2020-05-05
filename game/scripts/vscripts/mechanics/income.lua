function GameMode:StartPayingIncome()
  Timers:CreateTimer(function()
    GameMode:PayIncome()
    return INCOME_TICK_RATE
  end)
end

function GameMode:PayIncome()
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    local income = hero.income

    SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, income, hero)

    hero:AddNewModifier(hero, nil, "income_modifier", {duration=10})
    hero:ModifyCustomGold(income)
  end
end

function CDOTA_BaseNPC_Hero:ModifyIncome(amount)
  if not self.income then self.income = 0 end
  self.income = self.income + amount

  local playerID = self:GetPlayerOwnerID()
  CustomNetTables:SetTableValue("player_stats", tostring(playerID), {income = self.income})
end