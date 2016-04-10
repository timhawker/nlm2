--Nested layer manager button events
(
	struct nestedLayerManagerButtonEventsStruct (
		
		
		---------------------------------------------------------
		-- INITIALISE / REMOVE EVENTS
		---------------------------------------------------------
		
		function initialiseEvents = (
			
			try (
				
				--Declare shortcuts to ui
				local ui = nestedLayerManager.ui
				
				function topPanelButtonPress s e = (
					
					case s.name of (
						"CreateLayer" : nestedLayerManager.buttonFunctions.createLayer()
						"CreateFolder" : nestedLayerManager.buttonFunctions.createFolder()
						"DeleteSelected" : nestedLayerManager.buttonFunctions.deleteNodes()
						"AddSelObjToLyr" : nestedLayerManager.buttonFunctions.addObjectsToLayer()
						"SelObjWiSelLyrFdr" : nestedLayerManager.buttonFunctions.SelObjWiSelLyrFdr()
						"SelLyrFdrOfSelObj" : nestedLayerManager.buttonFunctions.SelLyrFdrOfSelObj()
						"HideUnhideAll" : nestedLayerManager.buttonFunctions.hideUnhideAll()
						"FreezeUnfreezeAll" : nestedLayerManager.buttonFunctions.freezeUnfreezeAll()
						"CollapseExpandAll" : nestedLayerManager.buttonFunctions.expandCollapseAll()
						"Settings" : nestedLayerManager.buttonFunctions.settings()
						"Information" : nestedLayerManager.buttonFunctions.information()
					)
					
				)
				
				--Initialise button event handlers
				dotNet.addEventHandler nestedLayerManager.ui.topPanel "ButtonClick" topPanelButtonPress
				
				if nestedLayerManager.showLog do format "[NLM] Button Events Added\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonEvents.ms > initialiseEvents()"
			)
			
		),
		
		--Remove event handlers
		function removeEvents = (
			
			try (
				
				--Declare shortcuts to ui
				dotNet.removeAllEventHandlers nestedLayerManager.ui.topPanel
				
				if nestedLayerManager.showLog do format "[NLM] Button Events Removed\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonEvents.ms > removeEvents()"
			)
			
		)
		
	)--End Struct
	
	nestedLayerManager.buttonEvents = nestedLayerManagerButtonEventsStruct()
	
)