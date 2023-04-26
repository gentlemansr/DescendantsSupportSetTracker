local vXOffset = 20
--------------------------------------------------------------------------------
-- FUNCTIONS TO CREATE A WINDOW IN XML
-- THIS WAS TAKEN AND ADJUSTED FROM SCROLLLIST EXAMPLE
-- HTTPS://WWW.ESOUI.COM/DOWNLOADS/INFO569-DSST.HTML
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS FOR THE UI
--------------------------------------------------------------------------------
local function ControlOnMouseEnter(iControl)
	iControl:SetColor(unpack(TEXT_COLOR_CONTEXT_HIGHLIGHT))
end
local function ControlOnMouseExit(iControl)
	iControl:SetColor(255/255,216/255,23/255,1)
end
--------------------------------------------------------------------------------
-- CREATE MAIN WINDOW IN XML
--------------------------------------------------------------------------------
function DSST.CreateMainWindowControl()


	-- Create a top level window.  User can adjust size, placement, and other settings later using the control we store.
	-- See: https://wiki.esoui.com/Controls and https://wiki.esoui.com/UI_XML
	-- See: https://wiki.esoui.com/Controls#WindowManager for more info
	DSST.cMainWindow = WINDOW_MANAGER:CreateTopLevelWindow("DSSTWindow")
	DSST.cMainWindow:SetAnchor(CENTER, GuiRoot, CENTER) 
	DSST.cMainWindow:SetDimensions(DSST.width , 700) 
	DSST.cMainWindow:SetHidden(true)
	DSST.cMainWindow:SetMovable(true)	
	DSST.cMainWindow:SetMouseEnabled(true)
	
	-- ADD handler to resize for main window
	DSST.cMainWindow:SetResizeHandleSize(5)
	
	-- Create a background (optional)  -  See https://wiki.esoui.com/Controls#BackdropControl for more info
	DSST.cMainWindowBackground = WINDOW_MANAGER:CreateControlFromVirtual("DSSTWindowBg", DSST.cMainWindow, "ZO_DefaultBackdrop")
	DSST.cMainWindowBackground:SetAnchorFill(DSST.cMainWindow)
	-- I have found that creating the background from virtual, that I could adjust the alpha, but not the color.
	-- If you would like to be able to change the background color you could also use:
	-- DSST.cMainWindowBackground = WINDOW_MANAGER:CreateControl("DSSTWindowBg", DSST.cMainWindow, CT_BACKDROP)
end
--------------------------------------------------------------------------------
-- CREATE SCROLL LIST IN XML
--------------------------------------------------------------------------------
function DSST.CreateScrollListControl()
	local yOffset = 70
	local xOffSet = vXOffset
	DSST.cScrollList = WINDOW_MANAGER:CreateControlFromVirtual("DSSTList", DSST.cMainWindow, "ZO_ScrollList")
	local width, height = DSST.cMainWindow:GetDimensions()
	DSST.cScrollList:SetDimensions((width-xOffSet),(height-yOffset-10))
	DSST.cScrollList:SetAnchor(TOPLEFT, DSSTWindow , TOPLEFT, (xOffSet/2), yOffset)
	DSST.cScrollList:SetAnchor(BOTTOMRIGHT, DSSTWindow , BOTTOMRIGHT,-(xOffSet/2),-(xOffSet/2) )
end


--------------------------------------------------
-- MAKE THE SCROLL LIST DATA TYPE
--------------------------------------------------
function DSST.CreateScrollListDataType()
	--[[
		https://github.com/esoui/esoui/blob/e554eb0d0a24ad9b49c0a775a1e18babf8ef54d4/esoui/libraries/zo_templates/scrolltemplates.lua#L789
		ZO_ScrollList_AddDataType(control self, number typeId, string templateName, number height, function setupCallback, function hideCallback, dataTypeSelectSound, function:nilable resetControlCallback)
		This function registers a data type for the list to display.
		The typeId must be unique to this data type. It's okay if data types in completely different scroll lists have the same identifiers.
		The templateName is the name of the virtual control that will be used to create list item controls for this data type.
		The setupFunction is a function that will be used to set up a list item control. It will be passed two arguments: the list item control, and the list item data.
		The dataTypeSelectSound will be played when a row of this type is selected.
		The resetControlCallback will be called when a list item control goes out of use.
	]]
	local control = DSST.cScrollList
	local typeId = 1
	local templateName = "DSSTListTemplate"
	local height = 30 -- height of the row, not the window
	local setupFunction = DSST.LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil

	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
end


--------------------------------------------------------------------------------
-- UPDATE THE SCROLL LIST
--------------------------------------------------------------------------------
function DSST.UpdateScrollList(control, data, rowType)
	
	local dataCopy = ZO_DeepTableCopy(data)
	local dataList = ZO_ScrollList_GetDataList(control)
	
	-- UPDATE HEADER ROW SET LIST
	local cSLIST = DSST.cMainWindow:GetNamedChild("SetList")
	if cSLIST then
		cSLIST:SetText("SetList:  |cffd817"..DSST.gSetList.."|r")
	end
	
	-- CLEARS OUT THE SCROLL LIST.  DONT' WORRY, WE MADE A COPY CALLED DATALIST.
	ZO_ScrollList_Clear(control)
	
	for _, lSet in ipairs(dataCopy) do
		local entry = ZO_ScrollList_CreateDataEntry(rowType, lSet)
		table.insert(dataList, entry) -- BY USING TABLE.INSERT, WE ADD TO WHATEVER DATA MAY ALREADY BE THERE.
	end
	ZO_ScrollList_Commit(control)
end
function DSST.generateSetListDropDown()
	
end
--------------------------------------------------------------------------------
-- GENERATE HEADDER ICON ROW 
--------------------------------------------------------------------------------
function DSST.generateHeadder()
	-- vars
	local yOffset = 35
	local xOffSet = vXOffset/2
	
	-- CREATE ADDON TITLE
	local cTitle = CreateControl("$(parent)Titel", DSSTWindow, CT_LABEL)
	cTitle:SetAnchor(nil , DSSTWindow, nil )
	cTitle:SetWidth(DSST.width)
	cTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	cTitle:SetFont("ZoFontAnnounceMedium")
	cTitle:SetText("|cffd817Descendants Support Set Tracker|r")
	
	--GENERATE PALYER NAME TOP LEFT
	local cPlName = CreateControl("$(parent)PlayerName", DSSTWindow, CT_LABEL)
	cPlName:SetAnchor(TOPLEFT , DSSTWindow, TOPLEFT, xOffSet, xOffSet/2  )
	cPlName:SetFont("ZoFontGameSmall")
	cPlName:SetText("|cffd817"..GetUnitDisplayName('player').."|r")
	--generate Total amount transmutes
	local cTotTrans = CreateControl("$(parent)TotalTransmutes", DSSTWindow, CT_LABEL)
	cTotTrans:SetAnchor(TOPLEFT , DSSTWindow, TOPLEFT, xOffSet, 2*xOffSet+5  )
	cTotTrans:SetFont("ZoFontGameSmall")
	cTotTrans:SetText("|t16:16:esoui/art/currency/icon_seedcrystal.dds|t"..GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT))
	-- GENERATE CLOSE BUTTON IN THE TOP RIGHT
	local cCloseButton = CreateControl("$(parent)CloseButton", DSSTWindow, CT_BUTTON)
	cCloseButton:SetDimensions(20,20)
	cCloseButton:SetAnchor(TOPRIGHT, DSSTWindow, TOPRIGHT, -xOffSet, xOffSet)
	cCloseButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	cCloseButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	cCloseButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	cCloseButton:SetHandler("OnMouseDown", function(self) DSST.showWindow() end) 
	cCloseButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(cCloseButton, LEFT, "Close") end )
	cCloseButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end )
	
	-- GENERATE UPDATE BUTTON IN THE TOP RIGHT
	local cUpdateButton = CreateControl("$(parent)UpdateButton", DSSTWindow, CT_BUTTON)
	cUpdateButton:SetDimensions(20,20)
	cUpdateButton:SetAnchor(TOPRIGHT, DSSTWindow, TOPRIGHT, -3*xOffSet, xOffSet)
	cUpdateButton:SetNormalTexture("/esoui/art/chatwindow/chat_scrollbar_endarrow_up.dds")
	cUpdateButton:SetMouseOverTexture("/esoui/art/chatwindow/chat_scrollbar_endarrow_over.dds")
	cUpdateButton:SetPressedTexture("/esoui/art/chatwindow/chat_scrollbar_endarrow_down.dds")
	cUpdateButton:SetHandler("OnMouseDown", function(self) 
		DSST.delCurrCharGear(GetCurrentCharacterId())
		DSST.delCurrCharGear(BAG_BACKPACK)
		DSST.delCurrCharGear(BAG_BANK)
		DSST.delCurrCharGear(BAG_SUBSCRIBER_BANK)
		DSST.delCurrCharGear(BAG_WORN)
		-- ONLY CHECKS HOUSE BANKS WHEN YOU ARE IN ONE OF YOUR HOUSES
		if GetUnitDisplayName('player') == GetCurrentHouseOwner() then
			DSST.delCurrCharGear(BAG_HOUSE_BANK_TEN)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_NINE)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_EIGHT)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_SEVEN)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_SIX)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_FIVE)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_FOUR)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_THREE)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_TWO)
			DSST.delCurrCharGear(BAG_HOUSE_BANK_ONE)
		end
		DSST.checkBags();
		if DSST.gSetList ~= "Custom" then
			DSST.UpdateScrollList(DSST.cScrollList, DSST.sets[DSST.gSetList], 1) 
		else
			DSST.UpdateScrollList(DSST.cScrollList, DSST.custSetList, 1) 
		end
	end) 
	cUpdateButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(cUpdateButton, LEFT, "Force Update") end )
	cUpdateButton:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end )
	
	
	-- GENERATE SET LIST NAME TOP LEFT 
	local cList = CreateControl("$(parent)SetList", DSSTWindow, CT_LABEL)
	cList:SetAnchor(TOPLEFT, DSSTWindow, TOPLEFT, xOffSet, 4*xOffSet+5)
	cList:SetFont("ZoFontGameSmall")
	cList:SetText("SetList:  |cffd817"..DSST.gSetList.."|r")
	xOffSet = xOffSet+DSST.nameWidth
	
	-- GENERATE HEADDER GEAR ICONS
	for y=1, DSST.collumns do 
		if y ~= 0 then
			-- IF NOT FIRST RUN THROUGH SHOW SLOT ICONS
			local cIcon = CreateControl("$(parent)Piece"..y, DSSTWindow, CT_BUTTON)
			cIcon:SetDimensions(30, 30)
			cIcon:SetNormalTexture(DSST.icons[y].link)
			cIcon:SetAnchor(TOPLEFT, DSSTWindow, TOPLEFT, xOffSet, yOffset)
			cIcon:SetNormalFontColor(255/255,216/255,23/255,1)
			cIcon:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(cIcon, LEFT, DSST.icons[y].name) end )
			cIcon:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end )
			xOffSet = xOffSet+30
		else
			-- IF FIRST RUN THROUGH SHOW WHICH SET LIST IS SELCTED 

		end
	end
end

--------------------------------------------------------------------------------
-- FUNCTIONS TO ADJUST THE WINDOW
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
-- SHOW/HIDE THE WINDOW
--------------------------------------------------------------------------------
function DSST.showWindow()
	DSST.delCurrCharGear(GetCurrentCharacterId())
	DSST.delCurrCharGear(BAG_BACKPACK)
	DSST.delCurrCharGear(BAG_BANK)
	DSST.delCurrCharGear(BAG_SUBSCRIBER_BANK)
	DSST.delCurrCharGear(BAG_WORN)
	-- ONLY CHECKS HOUSE BANKS WHEN YOU ARE IN ONE OF YOUR HOUSES
	if GetUnitDisplayName('player') == GetCurrentHouseOwner() then
		DSST.delCurrCharGear(BAG_HOUSE_BANK_TEN)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_NINE)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_EIGHT)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_SEVEN)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_SIX)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_FIVE)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_FOUR)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_THREE)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_TWO)
		DSST.delCurrCharGear(BAG_HOUSE_BANK_ONE)
	end
	DSST.checkBags()
	if DSSTWindow:IsControlHidden() then
		SCENE_MANAGER:SetInUIMode(true)
	else
		SCENE_MANAGER:SetInUIMode(false)
	end
	if DSST.gSetList ~= "Custom" then
		DSST.UpdateScrollList(DSST.cScrollList, DSST.sets[DSST.gSetList], 1) 
	else
		DSST.UpdateScrollList(DSST.cScrollList, DSST.custSetList, 1) 
	end	
	
	DSSTWindow:SetHidden(not DSSTWindow:IsControlHidden())
end