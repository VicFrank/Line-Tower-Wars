"use strict";

var localPlayerID = Players.GetLocalPlayer();

// GameUI.SetCameraDistance(1300);

var itemToPanel = {
  arc: "Arcane",
  ear: "Earth",
  fir: "Fire",
  ice: "Ice",
  lit: "Light",
  lig: "Lightning",
  unh: "Unholy",
  wat: "Water",
}

function OnScoreboardButtonPressed() {
	Game.EmitSound("ui_chat_slide_in")
}

function OnLeaderboardButtonPressed() {
	Game.EmitSound("ui_chat_slide_in")
}

var hideShop = false;
$("#Items").SetHasClass("ShopHidden", false);

function OnShopButtonPressed() {
  Game.EmitSound("ui_chat_slide_out");
  hideShop = !hideShop;
  $("#Items").SetHasClass("ShopHidden", hideShop);
}

function UIContinuePressed() {
  Game.EmitSound("ui_chat_slide_out")
  $("#PopupWindow").ToggleClass("Invisible");
}

function ResearchItem(item) {
  // make responsive by doing an optimistic ui update before the server responds
  var data = CustomNetTables.GetTableValue("custom_shop", "research_point" + localPlayerID);
  var unspent = data.unspent;

  var panel = GetResearchPanel(item);
  var unpurchaseable = panel.BHasClass("Unpurchasable")

  if (unspent < 1 || Game.IsGamePaused() || unpurchaseable) {
    // Game.EmitSound("General.SecretShopNotInRange");
  } else {
    Game.EmitSound("General.Buy");
  }

  GameEvents.SendCustomGameEventToServer("attempt_research_purchase", {itemname: item});
}

function BuyResearchPoint() {
  var gold = CustomNetTables.GetTableValue("custom_shop", "gold" + localPlayerID).gold;

  var data = CustomNetTables.GetTableValue("custom_shop", "research_point" + localPlayerID);
  var cost = data.cost;
  var remaining = data.remaining;

  if (gold < cost || remaining <= 0 || Game.IsGamePaused()) {
    // Game.EmitSound("General.SecretShopNotInRange");
  } else {
    Game.EmitSound("General.Buy");
  }

  GameEvents.SendCustomGameEventToServer("buy_research_point", {itemname: "research_point"});
}

function SetItemPurchased(itemPanel) {
  itemPanel.SetHasClass("Unpurchasable", true);

  var iconPanel = $.CreatePanel("Panel", itemPanel, "");
  iconPanel.SetHasClass("PurchasedIcon", true);
}

function UnlockResearchItem(itemPanel) {
  itemPanel.SetHasClass("Unpurchasable", false);
}

function GetResearchPanel(research) {
  var itemType = research.substring(0, 3);
  var itemTier = research.substring(3, 4);

  return $("#" + itemToPanel[itemType] + itemTier);
}

function UpdateResearchItem(data) {
  if (!data.research) return;

  // Update the shop on research purchased
  var item = data.research;
  var itemType = item.substring(0, 3);
  var itemTier = data.tier;

  var panelID = "#" + itemToPanel[itemType] + itemTier;
  var panel = $(panelID);

  if (data.purchased) {
    SetItemPurchased(panel);
  }
  if (data.purchaseable) {
    UnlockResearchItem(panel);
  }
}

function RefreshShop() {
  // update research
  var researchTypes = Object.keys(itemToPanel);
  for (var i = 0; i < researchTypes.length; i++) {
    for (var tier = 1; tier <= 3; tier++) {
      var type = researchTypes[i];
      var shopKey = type + tier + localPlayerID;
      var data = CustomNetTables.GetTableValue("custom_shop", shopKey);
      if (data) {
        UpdateResearchItem(data);
      }
    }
  }

  // update research points
  var key = "research_point" + localPlayerID;
  var data = CustomNetTables.GetTableValue("custom_shop", key);

  UpdateResearchPoints(data);
}

function UpdateResearchPoints(data) {
  if (!data) return;
  $("#ResearchPoints").text = data.unspent;
  $("#RPInformation").text = "1 RP = " + data.cost + " gold";
}

function OnShopUpdated(table_name, key, data) {
  if (data.playerID === localPlayerID) {
    if (data.research) {
      // update the research shop
      RefreshShop();
    }

    if (data.unspent) {
      // the number of research points has changed
      UpdateResearchPoints(data);
    }
  }
}

(function () {
  RefreshShop();
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnShopUpdated);
})();