GameUI.SetCameraDistance(1300);

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

function OnShopButtonPressed() {
  Game.EmitSound("ui_chat_slide_out")
  $("#Items").ToggleClass("ShopHidden");
}

function UIContinuePressed() {
  Game.EmitSound("ui_chat_slide_out")
  $("#PopupWindow").ToggleClass("Invisible");
}

function ResearchItem(item) {
  

  GameEvents.SendCustomGameEventToServer("attempt_purchase", {itemname: "research_point"});
}

function BuyResearchPoint() {
  $.Msg("Buy Research Point");
  GameEvents.SendCustomGameEventToServer("attempt_purchase", {itemname: "research_point"});
}

function SetItemPurchased(itemPanel) {
  itemPanel.SetHasClass("Unpurchasable", true);

  var iconPanel = $.CreatePanel("Panel", itemPanel, "");
  iconPanel.SetHasClass("PurchasedIcon", true);
}

function UnlockResearchItem(itemPanel) {
  itemPanel.SetHasClass("Unpurchasable", false);
}

function RefreshShop() {
  var key = "research" + localPlayerID;
  var data = CustomNetTables.GetTableValue("custom_shop", key);

  var item = "";
  var itemType = item.substring(0, 3);
  var itemTier = item.substring(4);

  var panelID = itemToPanel[itemType];

  SetItemPurchased($("#" + panelID + itemTier));

  if (itemTier === "1") {
    UnlockResearchItem($("#" + panelID + "1"));
    UnlockResearchItem($("#" + panelID + "2"));
  }  
}

function OnShopUpdated(table_name, key, data) {
  if (data.playerID === localPlayerID) {
    RefreshShop();
  }
}

(function () {
  RefreshShop();
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnShopUpdated);
})();