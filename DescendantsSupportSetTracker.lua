DSST = {}
DSST.name = "DescendantsSupportSetTracker"
DSST.version = "0.8"
DSST.variableVersion = 2
--------------------------------------------------------------------------------
-- LIBRARY IMPORTS
--------------------------------------------------------------------------------
local LAM = LibAddonMenu2
--------------------------------------------------------------------------------
-- DEFINE LOCAL CONSTANTS
--------------------------------------------------------------------------------
local TRASH_WHITE = ZO_ColorDef:New("c8ffd2")
local FINE_GREEN= ZO_ColorDef:New("00a103")
local SUPERIOR_BLUE = ZO_ColorDef:New("303af0")
local EPIC_PURPLE = ZO_ColorDef:New("880ba1")
local LEGENDARY_GOLD = ZO_ColorDef:New("ffd817")
--------------------------------------------------------------------------------
-- GLOBAL VARIABLES
--------------------------------------------------------------------------------
DSST.hidden = true
DSST.nameWidth = 450
DSST.gSetList = nil
DSST.custSetList = {}
DSST.libSetsReady = false
DSST.s2h = false
DSST.collumns = 18
DSST.width = 450+32*DSST.collumns
DSST.fullSetTable = {}
--------------------------------------------------------------------------------
-- LOCAL VARIABLES
--------------------------------------------------------------------------------
local vXOffset = 20
local setDump = ""


--------------------------------------------------------------------------------
-- ARRAY OF ICONS FOR THE HEADDERLINE
--------------------------------------------------------------------------------

DSST.icons = {
	{pieceId=1 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_head.dds", name="Head"},
	{pieceId=2 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_shoulders.dds", name="Shoulder"},
	{pieceId=3 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_chest.dds", name="Chest"},
	{pieceId=4 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_hands.dds", name="Hand"},
	{pieceId=5 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_waist.dds", name="Waist"},
	{pieceId=6 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_legs.dds", name="Legs"},
	{pieceId=7 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_feet.dds", name="Feet"},
	{pieceId=8 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_neck.dds", name="Necklace"},
	{pieceId=9 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_ring.dds", name="Ring"},
	--{pieceId=9 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_ring.dds"},
	{pieceId=10 ,link="esoui/art/icons/gear_breton_dagger_d.dds", name="Dagger"},
	{pieceId=11 ,link="esoui/art/icons/gear_breton_1haxe_d.dds", name="Axe"},
	{pieceId=12 ,link="esoui/art/icons/gear_breton_1hhammer_d.dds", name="Hammer"},
	{pieceId=13 ,link="esoui/art/icons/gear_breton_1hsword_d.dds", name="Sword"},
	{pieceId=22 ,link="esoui/art/tutorial/gamepad/gp_tooltip_itemslot_offhand.dds", name="Shield"},
	{pieceId=19 ,link="esoui/art/icons/icon_firestaff.dds", name="Fire"},
	{pieceId=21 ,link="esoui/art/icons/icon_lightningstaff.dds", name="Lightning"},
	{pieceId=20 ,link="esoui/art/icons/icon_icestaff.dds", name="Ice"},
	{pieceId=18 ,link="esoui/art/progression/icon_healstaff.dds", name="Restoration"},
	{pieceId=16 ,link="esoui/art/icons/gear_breton_2hsword_d.dds", name="2hSword"},
	{pieceId=14 ,link="esoui/art/icons/gear_breton_2haxe_d.dds", name="2hAxe"},
	{pieceId=15 ,link="esoui/art/icons/gear_breton_2hhammer_d.dds", name="2hHammer"},
	{pieceId=17 ,link="esoui/art/icons/gear_breton_bow_d.dds", name="Bow"},	

}

--------------------------------------------------------------------------------
-- MATCH EQUIPMENT TYPES TO COLELCTION SLOTS
--------------------------------------------------------------------------------

local tEquipType = {
	[EQUIP_TYPE_HEAD] = 1,
	[EQUIP_TYPE_SHOULDERS] = 2,
	[EQUIP_TYPE_CHEST] = 3,
	[EQUIP_TYPE_HAND] = 4,
	[EQUIP_TYPE_WAIST] = 5,
	[EQUIP_TYPE_LEGS] = 6,
	[EQUIP_TYPE_FEET] = 7,
	[EQUIP_TYPE_NECK] = 8,
	[EQUIP_TYPE_RING] = 9,
	[EQUIP_TYPE_MAIN_HAND] = -1,
	[EQUIP_TYPE_OFF_HAND] = -1,
	[EQUIP_TYPE_ONE_HAND] = -1,
	[EQUIP_TYPE_TWO_HAND] = -1
}

local tWeaponType = {
	[WEAPONTYPE_DAGGER] = 10,
	[WEAPONTYPE_AXE] = 11,
	[WEAPONTYPE_HAMMER] = 12,
	[WEAPONTYPE_SWORD] = 13,
	[WEAPONTYPE_TWO_HANDED_AXE] = 14,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 15,
	[WEAPONTYPE_TWO_HANDED_SWORD] = 16,
	[WEAPONTYPE_BOW] = 17,
	[WEAPONTYPE_HEALING_STAFF] = 18,
	[WEAPONTYPE_FIRE_STAFF] = 19,
	[WEAPONTYPE_FROST_STAFF] = 20,
	[WEAPONTYPE_LIGHTNING_STAFF] = 21,
	[WEAPONTYPE_SHIELD] = 22
}


--------------------------------------------------------------------------------
-- CHECK IF LIB SETS IS LOADED
--------------------------------------------------------------------------------
function DSST.lsLoaded()
	if not LibSets or not LibSets.checkIfSetsAreLoadedProperly() then
		--LIBSETS IS CURRENTLS SCANNING AND/OR NOT READY! ABORT HERE
		DSST.libSetsReady = false
	else
		DSST.libSetsReady = true
	end
end
--------------------------------------------------------------------------------
-- CHECK OWNED GEAR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- GET THE OWNED ITEMS AND SAVE THEM INTO A SAVED VARIABLE 
--------------------------------------------------------------------------------
function DSST.getItems(bag)
	local storageId = bag
	if bag == BAG_BACKPACK then
		storageId = GetCurrentCharacterId()	
	end
	for slotId=0,GetBagSize(bag) do
		local _, _, _, _, _, equipType, _, quality = GetItemInfo(bag,slotId)
		if equipType ~= EQUIP_TYPE_INVALID then
			local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(bag, slotId))
			if hasSet then
				eqType = tEquipType[equipType]
				if eqType == -1 then
					eqType = tWeaponType[GetItemWeaponType(bag,slotId)]
				end
				if not DSST.accSavedVariables.setList[setId] then
					DSST.accSavedVariables.setList[setId] = {[eqType] = {["quality"] = quality,["storage"] = storageId}}
				else if DSST.accSavedVariables.setList[setId][eqType] then
					if quality >= DSST.accSavedVariables.setList[setId][eqType]["quality"] then
						DSST.accSavedVariables.setList[setId][eqType]= {["quality"] = quality,["storage"] = storageId}
					end
				else
					DSST.accSavedVariables.setList[setId][eqType] = {["quality"] = quality,["storage"] = storageId}
					
					end end
			end
		end
	end
end
--------------------------------------------------------------------------------
-- DELETE SAVED VARIABLES FOR CURRENTLY AVAILALE STORAGES TO ACCOUTN FOR DECONSTRUCTION
--------------------------------------------------------------------------------
function DSST.delCurrCharGear()
	local storageId = GetCurrentCharacterId()
	local savList = {}
	for setkey, lSet in pairs(DSST.accSavedVariables.setList) do
		for pieceKey, lPiece in pairs(lSet) do

			if lPiece.storage == storageId then
				DSST.accSavedVariables.setList[setkey][pieceKey] = nil
			end
		end
		lSet = savList
		savList = {}
	end 
end


--------------------------------------------------------------------------------
-- Functions to adjust the window
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- RESTORE POSITION AFTER RELOAD UI/RELOG
--------------------------------------------------------------------------------
function DSST:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  DSSTWindow:ClearAnchors()
  DSSTWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
--------------------------------------------------------------------------------
 -- SAVE POSITION OF THE WINDOW WHEN MOVED
 --------------------------------------------------------------------------------
function DSST.OnIndicatorMoveStop()
  DSST.savedVariables.left = DSSTWindow:GetLeft()
  DSST.savedVariables.top = DSSTWindow:GetTop()
end
--------------------------------------------------------------------------------
-- HIDE THE WINDOW
--------------------------------------------------------------------------------
function DSST.HideUI()
	DSST.hidden = true 
	DSSTWindow:SetHidden(DSST.hidden)
end

--------------------------------------------------------------------------------
-- CHECK IF THE CURRENT PIECE IS RECONSTRUCTED
-- RETURN: RET =  TRUE/FALSE CURRENT PIECE IS IN ONE OFTHE STORAGES
--------------------------------------------------------------------------------
function DSST.isReconstructed(set,piece)
	local ret
	if DSST.accSavedVariables.setList[set] and DSST.accSavedVariables.setList[set][piece] then 
		ret = true
	else
		ret = false
	end
	
	return ret
end
--------------------------------------------------------------------------------
-- CHECK TYPE OF GEAR
-- RETURN: RET = GEAR TYPE
--------------------------------------------------------------------------------
function DSST.gearType(iLink)
	local eqType = tEquipType[GetItemLinkEquipType(iLink)]
	if eqType == -1 then
		eqType = tWeaponType[GetItemLinkWeaponType(iLink)]
	end
	return eqType
end
--------------------------------------------------------------------------------
-- CHECK IF PIECES IS AVAILABLE FOR RECONSTRUCTION
-- RETURN: RET = TRUE/FALSE
--------------------------------------------------------------------------------
function DSST.isUnlocked(iSetId, iPiece) 
	for y = 1,GetNumItemSetCollectionPieces(iSetId) do
	        local lPieceId = GetItemSetCollectionPieceInfo(iSetId, y)
			local lEqType = DSST.gearType(GetItemSetCollectionPieceItemLink(lPieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil))
			if lEqType == iPiece then
				if IsItemSetCollectionPieceUnlocked(lPieceId) then
					return 2
				else 
					return 3
				end 
			end
	end
	 return 4
end
--------------------------------------------------------------------------------
-- CHECK WHICH SET TYPE IS SELECTED AND CALL THE FUNCTIONS
-- RETURN: LSTATE = 0 ERROR | 1 OWNED | 2 TRANSMUTE | 3 NOT OWNED | 4 N/A 
--------------------------------------------------------------------------------
function DSST.checkPiece(setId, pieceId)
	local lState = DSST.isUnlocked(setId, pieceId)
	local lQuality = 0

	if lState ~= 4 then
		if DSST.isReconstructed(setId,pieceId) then-- USES THE ACTUAL SLOT OF THE PIECE
			lState = 1
			lQuality = DSST.accSavedVariables.setList[setId][pieceId]["quality"] 
		end
	end
	
	return lState, lQuality
end--GetItemLinkItemSetCollectionSlot
--------------------------------------------------------------------------------
-- FORMAT THE SET ROWS ACCORING TO PLAN IN XML FILE
 -- VSTATE = 0 ERROR | 1 OWNED | 2 TRANSMUTE | 3 NOT OWNED | 4 N/A 
--------------------------------------------------------------------------------

function DSST.LayoutRow(rowControl, data, scrollList)
	local xOffSet = DSST.nameWidth
	local vState = 0
	local vQuality = 0
	local vColor = TRASH_WHITE

	-- THE ROWCONTROL, DATA, AND SCROLLLISTCONTROL ARE ALL SUPPLIED BY THE INTERNAL CALLBACK TRIGGER
	local cLabel = rowControl:GetNamedChild("Name") -- GET THE CHILD OF OUR VIRTUAL CONTROL IN THE XML CALELD NAME
	cLabel:SetFont("ZoFontWinH4")
	cLabel:SetMaxLineCount(1) -- FORCES THE TEXT TO ONLY USE ONE ROW.  IF IT GOES LONGER, THE EXTRA WILL NOT DISPLAY.
	if GetItemReconstructionCurrencyOptionCost(data.id, CURT_CHAOTIC_CREATIA) then
		cLabel:SetText(data.name.." ("..GetItemReconstructionCurrencyOptionCost(data.id, CURT_CHAOTIC_CREATIA).."|t16:16:esoui/art/currency/icon_seedcrystal.dds|t)") -- 
	else
		cLabel:SetText(data.name.." (N/A |t16:16:esoui/art/currency/icon_seedcrystal.dds|t)") -- 
	end
	
	for x = 1, DSST.collumns do
		-- IF THERE IS ALREADY A BOX SELECT IT TO PREVENT ERRORS OTEHRWISE CREATE A NEW ONE 
	    local cEntry = rowControl:GetNamedChild("Entry"..x)
    	if not cEntry then
	    	cEntry = WINDOW_MANAGER:CreateControl("$(parent)Entry"..x, rowControl, CT_TEXTURE)
	    end
		cEntry:SetAnchor(LEFT, rowControl, LEFT,(xOffSet+(x-1)*30),0)
		cEntry:SetDimensions(20, 20)
		cEntry:SetHidden(false)
		
		-- THIS IS WHERE THE MAGIC HAPPENS
		vState, vQuality = DSST.checkPiece(data.id, DSST.icons[x].pieceId)
		
		
		-- ASSIGN THE TEXTURE TO THE TABLE ENTRY
		if vState == 1 then
			cEntry:SetTexture("/esoui/art/cadwell/check.dds")
			if vQuality == 1 or vQuality ==0 then
				cEntry:SetColor(TRASH_WHITE:UnpackRGBA())
			else if vQuality == 2 then
				cEntry:SetColor(FINE_GREEN:UnpackRGBA())
			else if vQuality == 3 then
				cEntry:SetColor(SUPERIOR_BLUE:UnpackRGBA())
			else if vQuality == 4 then
				cEntry:SetColor(EPIC_PURPLE:UnpackRGBA())				
			else if vQuality == 5 then
				cEntry:SetColor(LEGENDARY_GOLD:UnpackRGBA())
			end end end end end 

		else if vState == 2 then
			cEntry:SetTexture("esoui/art/currency/icon_seedcrystal.dds")
			cEntry:SetColor(1, 1, 1)
		else if vState == 3 then 
			cEntry:SetTexture("/esoui/art/buttons/swatchframe_down.dds")
			cEntry:SetColor(1, 1, 1)
		else if vState == 4 then  
			cEntry:SetHidden(true) 
		else
			d("Descendants Support Set Tracker ran into an issue. Please reload UI and Try again. If that doesnt Fix the issue Please comment on ESOUI with E"..data.id.."-"..x.." as error number")
		end end end end-- ends elifs
	end
	
end
--------------------------------------------------------------------------------
-- CHECK ALL BAGS IN ONE CALL 
--------------------------------------------------------------------------------
function DSST.checkBags()
	DSST.getItems(BAG_BACKPACK)
	DSST.getItems(BAG_BANK)
	DSST.getItems(BAG_SUBSCRIBER_BANK)
	DSST.getItems(BAG_WORN)
	if GetUnitDisplayName('player') == GetCurrentHouseOwner() then -- ONLY CHECK HOSUE BANKS WHEN YOU ARE IN YOUR HOUSE
		DSST.getItems(BAG_HOUSE_BANK_TEN)
		DSST.getItems(BAG_HOUSE_BANK_NINE)
		DSST.getItems(BAG_HOUSE_BANK_EIGHT)
		DSST.getItems(BAG_HOUSE_BANK_SEVEN)
		DSST.getItems(BAG_HOUSE_BANK_SIX)
		DSST.getItems(BAG_HOUSE_BANK_FIVE)
		DSST.getItems(BAG_HOUSE_BANK_FOUR)
		DSST.getItems(BAG_HOUSE_BANK_THREE)
		DSST.getItems(BAG_HOUSE_BANK_TWO)
		DSST.getItems(BAG_HOUSE_BANK_ONE)
	end
end
--------------------------------------------------------------------------------
-- SAVE A FULL LIST OF ALL SET NAMES
--------------------------------------------------------------------------------
function DSST.saveSetTable()
	if DSST.libSetsReady == true then
		local setTable = LibSets.GetAllSetIds()
		for set in pairs(setTable) do
			if LibSets.IsCraftedSet(set) == false then
				if LibSets.GetSetName(set) then
					table.insert(DSST.fullSetTable, LibSets.GetSetName(set))	
				end
			end
		end
    end
end
--------------------------------------------------------------------------------
-- TOGGLE 2 H WEAPON COLLUMNS
--------------------------------------------------------------------------------
function DSST.show2H(iBool)
	if iBool == true then
		DSST.collumns = 22
		DSST.width = 450+32*22
	else if iBool == false then
		DSST.collumns = 18
		DSST.width = 450+32*18
	end end
	DSST.savedVariables.show2h = iBool
	DSST.s2h = iBool
end
--------------------------------------------------------------------------------
-- ADD SETS TO CUSTOM LIST
--------------------------------------------------------------------------------
function DSST.addSet(iSetName)
	local lSetId = nil
	local lDuplicate = false
	for setname in string.gmatch(iSetName, "[^,]+") do
		if DSST.libSetsReady == true then
			lSetId, _ = LibSets.GetSetByName(setname, "en")
		else
			DSST.lsLoaded()		
			d("LibSets is currently Loading please try again in a few seconds")
		end
		if lSetId then
			for _,colSet in pairs(DSST.custSetList) do
				if colSet.id == lSetId then
					lDuplicate = true
					ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, setname.." is already in the Collection")
					break
				end
			end
			if lDuplicate == false then
				table.insert(DSST.custSetList, {name = setname, id = lSetId})
				DSST.accSavedVariables.customSetList = DSST.custSetList
				d(setname.. " added to the Collection")
			end 
		else
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, setname.." is not a valid set name")
		end
	end
end

--------------------------------------------------------------------------------
-- REMOVE SETS FROM CUSTOM LIST
--------------------------------------------------------------------------------
function DSST.removeSet(iSetName)
	local lSetId = nil
	local lDuplicate = false
	for setname in string.gmatch(iSetName, "[^,]+") do
		if DSST.libSetsReady == true then
			lSetId, _ = LibSets.GetSetByName(setname, "en")
		else
			DSST.lsLoaded()		
			d("LibSets is currently Loading please try again in a few seconds")
		end
		if lSetId then
			for x,colSet in ipairs(DSST.custSetList) do
				if colSet.id == lSetId then
					lDuplicate = true
					table.remove(DSST.custSetList,x)
					DSST.accSavedVariables.customSetList = DSST.custSetList
					d(setname.. " was removed from the Collection")	
					break
				end
			end
			if lDuplicate == false then
				d(setname.. " removed from the Collection")
			end 
		else
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, setname.." is not a valid set name")
		end
	end
end
--------------------------------------------------------------------------------
-- SLASH COMMANDS
--------------------------------------------------------------------------------
SLASH_COMMANDS["/dsst"] = function (extra)
	-- toggle window on command
	DSST.showWindow()
end


--------------------------------------------------------------------------------
-- INITIALIZE ADD ON 
--------------------------------------------------------------------------------
function DSST:Initialize()
	EVENT_MANAGER:RegisterForEvent(self.name)
	-- SET UP SAVE VARIABLES
	self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("DSSTSavedVariables", DSST.variableVersion, nil, {})
	self.accSavedVariables = ZO_SavedVars:NewAccountWide("DSSTSavedVariables", DSST.variableVersion, setList , {} , GetWorldName())
	if not self.accSavedVariables.setList then
		self.accSavedVariables.setList = {}
	end
	DSST.s2h = self.savedVariables.show2h or false
	DSST.show2H(DSST.s2h)
	DSST.custSetList = DSST.accSavedVariables.customSetList or {}
	-- READ SET LIST FROM SAVED VARIABLE
	DSST.gSetList = self.savedVariables.setList or 'Default_Tank'
	DSST.delCurrCharGear()
	-- CHECK BAGS FOR UNSAVED ITEMS
	DSST.checkBags()
	-- CREATE FIRST PART OF THE UI 
	DSST.CreateMainWindowControl() 	
	DSST.CreateScrollListControl() 
	DSST.CreateScrollListDataType() 

	-- GENERATE THE ADDON SETTINGS WITH LIBADDONMENU
	DSST.setupSettings()
	-- GENERATE REST OF THE UI
	DSST.generateHeadder(gSetList)
	--DSST.UpdateScrollList(DSST.cScrollList, sets[gSetList], 1) -- TODO: REMOVE WHEN FINISHED
	-- CHECK IF LIB SETS LOADED PROPPERLY
	DSST.lsLoaded()
	DSST.saveSetTable()
	-- ADD HANDLERS FOR RESIZE AND MOVE TO THE MAIN WINDOW
	DSST.cMainWindow:SetHandler("OnResizeStop", function(self)
		if DSST.gSetList ~= "Custom" then
			DSST.UpdateScrollList(DSST.cScrollList, DSST.sets[DSST.gSetList], 1) 
		else
			DSST.UpdateScrollList(DSST.cScrollList, DSST.custSetList, 1) 
		end	
	end) 
	DSST.cMainWindow:SetHandler("OnMoveStop", function(self) DSST.OnIndicatorMoveStop()  end) 
	-- RESTORE THE SAVED POSITION OF THE WINDOW
	self:RestorePosition()
end


 


function DSST.OnAddOnLoaded(event, addonName)

  if addonName == DSST.name then
    DSST:Initialize()
  end
end
 
ZO_CreateStringId("SI_BINDING_NAME_DSST_TOGGLE",  "HIDE UI")
EVENT_MANAGER:RegisterForEvent(DSST.name, EVENT_ADD_ON_LOADED, DSST.OnAddOnLoaded)