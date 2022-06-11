--------------------------------------------------------------------------------
-- LIBRARY IMPORTS
--------------------------------------------------------------------------------
local LAM = LibAddonMenu2

--------------------------------------------------------------------------------
-- FUNCTIONS FOR THE SETTINGS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SAVE A FULL LIST OF ALL SET NAMES INTO A LIST
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
-- CREATE SETTING MENU WITH LIBADDONMENU
--------------------------------------------------------------------------------

function DSST.setupSettings()
	local settingName = "Descendants Support Set Tracker"
	local settingData = {
		type = "panel",
		name = "|caeba00Descendants Support Set Tracker|r",
		author = "|caeba00@Sven_re|r",
		feedback = "https://github.com/gentlemansr/DescendantsSupportSetTracker/issues",
		registerForDefaults = true,
		slashCommand = "/dsst opt"
	}

	local menuData = {
		{
            type = "button",
            name = "Show / Hide",
            tooltip = "Shows/Hides the Window",
            width = "half",
            func = DSST.showWindow,
        },
			    {
			type = "dropdown",
			name = "Set List",
			tooltip = "Select a Set List to Display",
			default = 'Default_Tank',
			choices = {"Default_Healer", "Default_Tank" ,"DOTD_Healer", "DOTD_Tank","IP_Healer_U33","IP_Tank_U33", "Custom"},
			getFunc = function() return DSST.gSetList end,
			setFunc = function(value) 
				DSST.gSetList = value 
				DSST.savedVariables.setList = value
				if DSST.hidden == false then
					if value ~= "Custom" then
						DSST.UpdateScrollList(DSST.cScrollList, DSST.sets[DSST.gSetList], 1) 
					else
						DSST.UpdateScrollList(DSST.cScrollList, DSST.custSetList, 1) 
					end
				end
			end
		},
		{
			type = "divider",
			width = "full",
		},
		{
            type = "checkbox",
            name = "Show 2h Weapons",
            tooltip = "Show 2 Handed Weapons in the Set List",
            getFunc = function() return DSST.s2h end,
            setFunc = function(value) 
				DSST.show2H(value)
				ReloadUI() 
			end,
			requiresReload = true,
        },
	    {
            type = "header",
            name = "Custom Set List",
            description = "You can add mulitple Sets by comma seperating them for example:\nSpell Power Cure,Master Architect",
        },
		{
			type = "dropdown",
			name = "Set Name",
			tooltip = "Add/Remove Set to/from the custom Collection",
			choices = DSST.fullSetTable,
			scrollable = true,
			sort = "name-up",
			getFunc = function() return nil end,
			setFunc = function(value) 
				if value then 
					setDump = value
				end 
			end
		},
		{
            type = "editbox",
            name = "Set Names",
            tooltip = "Add/Remove Set to/from the custom Collection (English Names only)",
            getFunc = function() return setDump end,
            setFunc = function(value) 
				if value then 
					setDump = value
				end 
			end,
            isMultiline = false,
            isExtraWide = true,
        },
		{
            type = "button",
            name = "Add Set",
            tooltip = "Adds a Set fromn the Custom List",
            width = "half",
            func = function() 
				DSST.addSet(setDump) 
				setDump = ""
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", DSST.optionsPanel)
			end,
        },
		{
            type = "button",
            name = "Remove Set",
            tooltip = "Removes a Set fromn the Custom List",
            width = "half",
            func = function() 
				DSST.removeSet(setDump) 
				setDump = ""
				CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", DSST.optionsPanel)
			end,
        },
		{
			type = "divider",
			width = "full",
		},
		{
        type = "description",
        text = "Open the addon window with |caeba00/dsst|r\n\n",
        width = "full",	
		},

	}


	DSST.optionsPanel = LAM:RegisterAddonPanel(settingName, settingData)
	LAM:RegisterOptionControls(settingName, menuData)
end