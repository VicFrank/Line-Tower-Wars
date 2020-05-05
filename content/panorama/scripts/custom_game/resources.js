var HUD = $.GetContextPanel().GetParent().GetParent().GetParent();
var newUI = HUD.FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
var AbilitiesContainer = newUI.FindChildTraverse("AbilitiesAndStatBranch").FindChildTraverse("abilities");

function SetCustomAbilityCosts(abilityNumber, goldCost) {
  var AbilityPanel = AbilitiesContainer.FindChildTraverse("Ability" + abilityNumber);
  if (!AbilityPanel) return;
  var AbilityButton = AbilityPanel.FindChildTraverse("ButtonAndLevel").FindChildTraverse("ButtonWithLevelUpTab").FindChildTraverse("ButtonWell").FindChildTraverse("ButtonSize");

  if (goldCost == 0) goldCost = "";

  if (AbilityButton.FindChildTraverse("CustomGoldCost")) {
    AbilityButton.FindChildTraverse("CustomGoldCost").text = goldCost;
  } else {
    var goldCostLabel = $.CreatePanel("Label", AbilityButton, "CustomGoldCost");
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
  var queryUnit = Players.GetLocalPlayerPortraitUnit();

  for (var i=0; i < Entities.GetAbilityCount(queryUnit); ++i) {
    var ability = Entities.GetAbility(queryUnit, i);
    if (ability == -1)
      continue;

    if (!Abilities.IsDisplayedAbility(ability))
      continue;

    var abilityname = Abilities.GetAbilityName(ability);

    var abilityCostData = CustomNetTables.GetTableValue("building_settings", abilityname);
    if (!abilityCostData) {
      SetCustomAbilityCosts(i, "");
      continue;
    }

    var goldCost = abilityCostData.goldCost;

    SetCustomAbilityCosts(i, goldCost);
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
  GameEvents.Subscribe("round_started", UpdateAbilityUI);
})();