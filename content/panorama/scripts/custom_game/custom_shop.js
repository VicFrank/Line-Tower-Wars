"use strict";

var IsSpectator = !Players.IsValidPlayerID(Players.GetLocalPlayer());

var LocalPlayerID = Players.GetLocalPlayer();
var LocalPlayerTeam = Players.GetTeam(LocalPlayerID);

var DefaultPlayerID = 0;
if (!IsSpectator)
  DefaultPlayerID = LocalPlayerID;

var shopPanel = $("#Items");
var shopItemPanels = [];
var itemData = {};

var tier1;
var tier2;
var tier3;

var CurrentTier;

var NUM_SHOP_ITEMS = 12;

function GetPlayerIDToShow() {
  var queryUnit = Players.GetLocalPlayerPortraitUnit();
  var queryUnitTeam = Entities.GetTeamNumber(queryUnit);
  var queryUnitPlayerOwnerID = Entities.GetPlayerOwnerID(queryUnit);
  if (IsSpectator && queryUnitPlayerOwnerID >= 0)
    return queryUnitPlayerOwnerID;
  else
    return DefaultPlayerID;
}

function OnPageClicked(tier) {
	Game.EmitSound("ui_chat_slide_out");

  $("#Page1").SetHasClass("PageButtonsActive", false);
  $("#Page2").SetHasClass("PageButtonsActive", false);
  $("#Page3").SetHasClass("PageButtonsActive", false);

  $("#Page" + tier).SetHasClass("PageButtonsActive", true);

  if (tier === 1) {
    CurrentTier = tier1;
  } else if (tier === 2) {
    CurrentTier = tier2;
  } else if (tier === 3) {
    CurrentTier = tier3;
  }

  RefreshShop();
}

function LoadItems() {
  tier1 = CustomNetTables.GetTableValue("custom_shop", "tier1");
  tier2 = CustomNetTables.GetTableValue("custom_shop", "tier2");
  tier3 = CustomNetTables.GetTableValue("custom_shop", "tier3");

  CurrentTier = tier1;

  BuildShopPanels();
  RefreshShop();
}

function BuildShopPanels() {
  shopItemPanels = [];

  $("#ShopRow1").RemoveAndDeleteChildren();
  $("#ShopRow2").RemoveAndDeleteChildren();
  $("#ShopRow3").RemoveAndDeleteChildren();
  $("#ShopRow4").RemoveAndDeleteChildren();

  for(var i=0; i< NUM_SHOP_ITEMS; ++i) {
    var row = Math.floor(i/4) + 1;
    var rowPanel = $("#ShopRow" + row);
    var shopItemPanel = $.CreatePanel("Panel", rowPanel, "");

    shopItemPanel.BLoadLayout("file://{resources}/layout/custom_game/shop_item.xml", false, false);
    shopItemPanels.push(shopItemPanel);
  }
}

function RefreshShop() {
  if (!CurrentTier) {
    LoadItems();
  }

  for (var i=0; i<NUM_SHOP_ITEMS; ++i) {
    if (CurrentTier[i+1]) {
      var itemname = CurrentTier[i+1]; // lua is 1 indexed
      var shopItemPanel = shopItemPanels[i];
      var key = itemname + GetPlayerIDToShow();
      var data = CustomNetTables.GetTableValue("custom_shop", key);

      if (data) {
        shopItemPanel.SetItem(data);
      } else {
        shopItemPanel.SetItem({
          itemname,
          stock: 0,
          restock_time: 0,
          cooldown_length: 0,
          hotkey: ""
        });
      }
    }
  }
}

function OnShopUpdated(table_name, key, data) {
  if (data.playerID === GetPlayerIDToShow()) {
    RefreshShop();
  }
}

function PurchaseItem(slot) {
  slot = slot - 1;
  if (IsSpectator) return;
  
  let panel = shopItemPanels[slot];
  if (panel)
    panel.PurchaseItem();
}

(function () {
  LoadItems();

  GameEvents.Subscribe("setup_shop", LoadItems);
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnShopUpdated);

  if (!GameUI.Keybinds) GameUI.Keybinds = {};

  GameUI.Keybinds.PurchaseItem1 = function() { PurchaseItem(1) };
  GameUI.Keybinds.PurchaseItem2 = function() { PurchaseItem(2) };
  GameUI.Keybinds.PurchaseItem3 = function() { PurchaseItem(3) };
  GameUI.Keybinds.PurchaseItem4 = function() { PurchaseItem(4) };
  GameUI.Keybinds.PurchaseItem5 = function() { PurchaseItem(5) };
  GameUI.Keybinds.PurchaseItem6 = function() { PurchaseItem(6) };
  GameUI.Keybinds.PurchaseItem7 = function() { PurchaseItem(7) };
  GameUI.Keybinds.PurchaseItem8 = function() { PurchaseItem(8) };
  GameUI.Keybinds.PurchaseItem9 = function() { PurchaseItem(9) };
  GameUI.Keybinds.PurchaseItem10 = function() { PurchaseItem(10) };
  GameUI.Keybinds.PurchaseItem11 = function() { PurchaseItem(11) };
  GameUI.Keybinds.PurchaseItem12 = function() { PurchaseItem(12) };
})();