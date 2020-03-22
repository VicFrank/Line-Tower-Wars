"use strict";

var localPlayerID = Players.GetLocalPlayer();
var shopPanel = $("#Items");
var shopItemPanels = [];
var itemData = {};

var tier1;
var tier2;
var tier3;

var CurrentTier;

var NUM_SHOP_ITEMS = 12;

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

  RefreshShopUI();
}

function LoadItems() {
  $.Msg("Load Items");

  tier1 = CustomNetTables.GetTableValue("custom_shop", "tier1");
  tier2 = CustomNetTables.GetTableValue("custom_shop", "tier2");
  tier3 = CustomNetTables.GetTableValue("custom_shop", "tier3");

  CurrentTier = tier1;

  InitializeItemData(tier1);
  InitializeItemData(tier2);
  InitializeItemData(tier3);

  BuildShopPanels();
}

function InitializeItemData(tier) {
  Object.values(tier).forEach(function(itemname) {
    itemData[itemname] = {};
  });
} 

function ClearShopPanels() {
  $("#ShopRow1").RemoveAndDeleteChildren();
  $("#ShopRow2").RemoveAndDeleteChildren();
  $("#ShopRow3").RemoveAndDeleteChildren();
  $("#ShopRow4").RemoveAndDeleteChildren();
} 

function BuildShopPanels() {
  ClearShopPanels();
  shopItemPanels = [];

  for(var i=0; i< NUM_SHOP_ITEMS; ++i) {
    var row = Math.floor(i/4) + 1;
    var rowPanel = $("#ShopRow" + row);
    var shopItemPanel = $.CreatePanel("Panel", rowPanel, "");
    shopItemPanel.BLoadLayout("file://{resources}/layout/custom_game/shop_item.xml", false, false);
    shopItemPanels.push(shopItemPanel);
  }
}

function ObjectIsEmpty(obj) {
  return Object.keys(obj).length === 0 && obj.constructor === Object
}

function RefreshShopUI() {
  if (!CurrentTier) {
    LoadItems();
  }

  for (var i=0; i<NUM_SHOP_ITEMS; ++i) {
    if (CurrentTier[i+1]) {
      var itemname = CurrentTier[i+1]; // lua is 1 indexed
      var shopItemPanel = shopItemPanels[i];
      var data = itemData[itemname];

      // I'm not sure why, but sometimes the data isn't initialized
      if (ObjectIsEmpty(data)) {
        RefreshShopData();
      }

      shopItemPanel.SetItem(data);
    }
  }
}

function RefreshShopData() {
  var items = Object.keys(itemData);

  items.forEach(function(itemname) {
    var key = itemname + localPlayerID;
    var shopData = CustomNetTables.GetTableValue("custom_shop", key);

    if (shopData) {
      itemData[itemname] = shopData;
    }
  });
}

function OnShopUpdated(table_name, key, data) {
  if (data.playerID === localPlayerID) {
    var itemname = data.itemname;
    itemData[itemname] = data;

    RefreshShopUI();
  }
}

(function () {
  LoadItems();
  RefreshShopData();
  RefreshShopUI();

  GameEvents.Subscribe("setup_shop", RefreshShopData);
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnShopUpdated);
})();