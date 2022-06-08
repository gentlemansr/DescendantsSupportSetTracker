--------------------------------------------------------------------------------
-- LIBRARY IMPORTS
--------------------------------------------------------------------------------
local LAM = LibAddonMenu2
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
        type = "description",
        text = "Open the addon window with |caeba00/dsst|r\n\n",
        width = "full",	
		},

	}


	DSST.optionsPanel = LAM:RegisterAddonPanel(settingName, settingData)
	LAM:RegisterOptionControls(settingName, menuData)
end