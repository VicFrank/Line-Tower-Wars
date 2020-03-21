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

function RefreshShopUI() {
  if (!CurrentTier) {
    LoadItems();
  }

  for (var i=0; i<NUM_SHOP_ITEMS; ++i) {
    if (CurrentTier[i+1]) {
      var itemname = CurrentTier[i+1]; // lua is 1 indexed
      var shopItemPanel = shopItemPanels[i];
      var data = itemData[itemname];
      shopItemPanel.SetItem(data);
    }
  }
} 

function UpdateItemInfo(data) {  
  var itemname = data.itemname;
  itemData[itemname] = data;

  RefreshShopUI();
}

function RefreshShopData() {
  var items = Object.keys(itemData);

  items.forEach(function(itemname) {
    var key = itemname + localPlayerID;
    var shopData = CustomNetTables.GetTableValue("custom_shop", key);
    if (shopData) {
      UpdateItemInfo(shopData);
    }
  });

  RefreshShopUI();
}

function OnShopUpdated(table_name, key, data) {
  if (data.playerID === localPlayerID) {
    UpdateItemInfo(data)
  }
}

(function () {
  LoadItems();
  RefreshShopData();

  GameEvents.Subscribe("setup_shop", RefreshShopData);
  CustomNetTables.SubscribeNetTableListener("custom_shop", OnShopUpdated);
})();