var HUD = $.GetContextPanel().GetParent().GetParent().GetParent();
var newUI = HUD.FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var AbilitiesContainer = newUI.FindChildTraverse("AbilitiesAndStatBranch").FindChildTraverse("abilities");

function SetCustomAbilityCosts(abilityNumber, goldCost) {
  let AbilityPanel = AbilitiesContainer.FindChildTraverse("Ability" + abilityNumber);
  if (!AbilityPanel) return;
  let AbilityButton = AbilityPanel.FindChildTraverse("ButtonAndLevel").FindChildTraverse("ButtonWithLevelUpTab").FindChildTraverse("ButtonWell").FindChildTraverse("ButtonSize");

  if (goldCost == 0) goldCost = "";

  if (AbilityButton.FindChildTraverse("CustomGoldCost")) {
    AbilityButton.FindChildTraverse("CustomGoldCost").text = goldCost;
  } else {
    let goldCostLabel = $.CreatePanel("Label", AbilityButton, "CustomGoldCost");
    goldCostLabel.text = goldCost;
    goldCostLabel.style.fontSize = "14px";
    goldCostLabel.style.verticalAlign = "bottom";
    goldCostLabel.style.horizontalAlign = "left";
    goldCostLabel.style.fontWeight = "bold";
    goldCostLabel.style.color = "#FFFF99";
    goldCostLabel.style.textShadow = "0px 0px 3px 3.0 #000000";
  }
}

function UpdateAbilityUI() {
  let queryUnit = Players.GetLocalPlayerPortraitUnit();

  let abilityIndex = 0;
  for (let i=0; i < Entities.GetAbilityCount(queryUnit); ++i) {
    const ability = Entities.GetAbility(queryUnit, i);
    if (ability == -1)
      continue;

    if (!Abilities.IsDisplayedAbility(ability))
      continue;

    const abilityname = Abilities.GetAbilityName(ability);
    const index = abilityIndex;
    abilityIndex += 1;

    const abilityCostData = CustomNetTables.GetTableValue("building_settings", abilityname);
    if (!abilityCostData) {
      SetCustomAbilityCosts(index, "");
      continue;
    }

    const goldCost = abilityCostData.goldCost;

    SetCustomAbilityCosts(index, goldCost);
  }
}

function DelayedUpdateAbilityUI() {
  $.Schedule(1, UpdateAbilityUI);
}

(function () {
  UpdateAbilityUI();
  DelayedUpdateAbilityUI();
  GameEvents.Subscribe("dota_player_update_selected_unit", UpdateAbilityUI);
  GameEvents.Subscribe("dota_player_update_query_unit", UpdateAbilityUI);
  GameEvents.Subscribe("init_ability_prices", UpdateAbilityUI);
})();