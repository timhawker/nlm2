--Nested Layer Manager Maxform Events Struct
(
	
	--Maxform Events Struct
	struct nestedLayerManagerMfEventsStruct (
	
	
	-------------------------------------------------------------
	-- GENERAL MAXFORM (NON EVENT) FUNCTIONS
	-------------------------------------------------------------
		
	--Show max form window
	function showMaxForm = (
		
		try (
			
			local mf = nestedLayerManager.ui.mf
			
			if not mf.visible do (
				--Add panel to maxform in case it was previously in rollout. Close rollout if it is open.
				mf.controls.add nestedLayerManager.ui.nlmPanel
				
				--Set background color to that of 3ds max background
				bg = colorman.getColor #background * 255
				mf.backColor = (dotNetClass "System.Drawing.Color").FromArgb bg[1] bg[2] bg[3]
				
				--Set size of nlmPanel to same as mf
				nestedLayerManager.ui.nlmPanel.size = dotNetObject "System.Drawing.Size" mf.width mf.height
				
				--Parent form to 3dsmax handle and create dialog
				sysPointer=dotNetObject "system.intPtr" (windows.getMaxHWND())
				maxHandle=dotNetObject "maxCustomControls.win32HandleWrapper" sysPointer
				mf.show maxHandle
				
				--Close dialog, set window open values
				nestedLayerManager.dialogDockOpen = false
				nestedLayerManager.maxFormOpen = true
				try(cui.unRegisterDialogBar nestedLayerManager.ui.nlmRoll)catch()
				try(destroyDialog nestedLayerManager.ui.nlmRoll)catch()
			)
			
			if nestedLayerManager.showLog do format "[NLM] Showing MaxForm\n"
			
		) catch (
			if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > showMaxForm()"
		)
		
	),
	
	
	function refreshTree = (
		
		try (
			
			--Save treeview structure
			nestedLayerManager.io.save()
				
			--Clear treelist and delete all node data
			nestedLayerManager.io.resetNLMClean()
			
			--Fill in treelist
			nestedLayerManager.io.resetNLMPopulate()
			
			if nestedLayerManager.showLog do format "[NLM] TreeList Refreshed\n"
				
			--Return true
			true
			
		) catch (
			if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > refreshTree()"
		)
		
	),
		
	function reload = (
		
		try (
			nestedLayerManager.io.close()
			
			startupProFile = nestedLayerManagerPath + "startup.ms"
			startupFreeFile = nestedLayerManagerPath + "startup.mse"
				
			if doesFileExist startupProFile do (
				format "[NLM] Reloading...\n"
				fileIn startupProFile
			)
			if doesFileExist startupFreeFile do (
				format "[NLM] Reloading...\n"
				fileIn startupFreeFile
			)
			
			--Return true
			true
			
		) catch (
			if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > reload()"
		)
		
	),
	
	
	
	---------------------------------------------------------
	-- EVENT FUNCTIONS
	---------------------------------------------------------
	
	--Run function on window close
	function close mf event = (
		
		try (
			
			start = timeStamp()
			
			if nestedLayerManager.ui.mf.visible then (
				--Define local shortcuts
				local mf = nestedLayerManager.ui.mf
				
				--Cancel window closing event and hide instead
				if event != undefined do event.cancel = true
				
				--Ensure window sate is normal so that size is properly saved (the more elegent restoreBounds just isn't working grr!)
				mf.windowState = mf.windowState.Normal
				
				--Hide maxform
				nestedLayerManager.ui.mf.hide()
				
				--Save all data
				nestedLayerManager.io.closing()
				
			)
			
			finish = timeStamp()
			if nestedLayerManager.showLog do format ("[NLM] Closed in " + ((finish - start) / 1000.0) as string + " Seconds\n")		
			
		) catch (
			nestedLayerManager.error.scriptError message:"maxFormEvents.ms > close mf event"
		)
		
	),
	
	--If max is shut down with NLM open do the following
	function preSystemShutdownClose = (
		
		try (
			
			--Stop the timer
			nestedLayerManager.callbacks.layerParamsTimer.stop()
			
			--Ensure window sate is normal so that size is properly saved (the more elegent restoreBounds just isn't working grr!)
			nestedLayerManager.ui.mf.windowState = nestedLayerManager.ui.mf.windowState.Normal
			
			--Save ini prefs 
			nestedLayerManager.io.saveIniPrefs()
			
			--Remove all callbacks and event handlers. (preSave callback fires before preShutDown, so NLM is already saved)
			nestedLayerManager.io.removeAllEventHandlersAndCallbacks()
			
		) catch (
			if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > preSystemShutdownClose()"
		)
		
	),
		
	--Set dialog position (needs to be run after maxform.show() event otherwise window will not take position)
	function setWindowPos = (
		
		try (
			
			nestedLayerManager.ui.mf.location.x = nestedLayerManager.posX
			nestedLayerManager.ui.mf.location.y = nestedLayerManager.posY
			
		) catch (
			if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > setWindowPos()"
		)
		
	),
	
	
	
	
	---------------------------------------------------------
	-- INITIALISE / REMOVE EVENTS
	---------------------------------------------------------
	
	function initialiseEvents = (
			
			try (
				
				--Declare shortcuts to ui
				local mf = nestedLayerManager.ui.mf			
				local tl = nestedLayerManager.ui.tl
				local ui = nestedLayerManager.ui
				
				--Initialise maxform event handlers
				dotNet.addEventHandler mf "Closing" close
				dotNet.addEventHandler mf "load" setWindowPos
				
				if nestedLayerManager.showLog do format "[NLM] MaxForm Events Added\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > initialiseEvents()"
			)
			
		),
		
		--Remove event handlers
		function removeEvents = (
			
			try (
				mf = nestedLayerManager.ui.mf
				dotNet.removeAllEventHandlers mf
				if nestedLayerManager.showLog do format "[NLM] Button Events Removed\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > removeEvents()"
			)
			
		)
	
	)--End Struct
	
	nestedLayerManager.mfEvents = nestedLayerManagerMfEventsStruct()
	
)