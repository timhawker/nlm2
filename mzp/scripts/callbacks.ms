--Layer paramater callback change, used for parts of layer params that have a callback.
--This needs to be kept in global scope outside of struct for redraw viewport callback scope issues.
function nestedLayerManager_layerParamChange = (
	
	try (			
		start = timeStamp()
		
		cb = nestedLayerManager.callbacks
		tl = nestedLayerManager.ui.tl
		dnCol = (dotNetClass "System.Drawing.Color")
		ghba = getHandleByAnim
		gabh = getAnimByHandle
		
		tl.beginUnboundLoad()
		
		/*
			Loop through array built up by paramChanged general event handler
			Setting values in listview is slow, only set if they are different
			Only run recursive folder state function if required. If next item in queue has the same parent do not run.
		*/
		
		for a=1 to cb.layerParamChangeQueue.count do (
			
			local layerHnd = cb.layerParamChangeQueue[a]
			local layer = if layerHnd != undefined do gabh layerHnd
			local layerNode = if layer != undefined do nestedLayerManager.io.getNodeByLayerHnd layerHnd
			
			local nextLayerHnd = cb.layerParamChangeQueue[(a+1)]
			local nextLayer = if nextLayerHnd != undefined do gabh nextLayerHnd
			local nextLayerNode = if nextLayer != undefined do nestedLayerManager.io.getNodeByLayerHnd(ghba nextLayer)
			
			if layer != undefined and layerNode != undefined do (
				if layer.on != layerNode.item["Visible"] do (
					layerNode.setValue "Visible" layer.on
					if layerNode.parentNode != (if nextLayerNode != undefined do nextLayerNode.parentNode) do 
						nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl layerNode "Visible" layer.on
				)
				if layer.isFrozen != layerNode.item["Freeze"] do (
					layerNode.setValue "Freeze" layer.isFrozen
					if layerNode.parentNode != (if nextLayerNode != undefined do nextLayerNode.parentNode) do 
						nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl layerNode "Freeze" layer.isFrozen
				)
				if layer.renderable != layerNode.item["Render"] do (
					layerNode.setValue "Render" layer.renderable
					if layerNode.parentNode != (if nextLayerNode != undefined do nextLayerNode.parentNode) do 
						nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl layerNode "Render" layer.renderable
				)
				layerCol = layer.wireColor
				layerColDn = dnCol.fromArgb layerCol.r layerCol.g layerCol.b
				if layerColDn != layerNode.item["Color"] do (
					layerNode.setValue "Color" layerColDn
				)
				if layer.boxMode != layerNode.item["Box"] do (
					layerNode.setValue "Box" layer.boxMode
					if layerNode.parentNode != (if nextLayerNode != undefined do nextLayerNode.parentNode) do 
						nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl layerNode "Box" layer.boxMode
				)
			)
		)
		tl.endUnboundLoad()
		
		--nestedLayerManager.selectionCount = tl.selection.count --Why is this here?
		unRegisterRedrawViewsCallback nestedLayerManager_layerParamChange
		cb.layerParamChangeQueue = #()
		
		end = timeStamp()
		if nestedLayerManager.showLog do format ("[NLM] Layer Param Change Completed in " + ((end-start) / 1000.00) as string + " Seconds\n")
		
	) catch (
		unRegisterRedrawViewsCallback nestedLayerManager_layerParamChangeLink
		if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nestedLayerManager_layerParamChange()"
	)
	
)


--Nested layer manager callback struct
(
	struct nestedLayerManagerCallbackStruct (
		
		
		-----------------------------------------------------------------------------
		-- LAYER CALLBACKS
		-----------------------------------------------------------------------------
		
		--Layer Created Function
		function layerCreated a = (
			
			try (
				
				--shortcut treelist link
				local tl = nestedLayerManager.ui.tl
				local parentNodeID = 0
				local layerHnd = getHandleByAnim a
				
				if nestedLayerManager.buttonPress do (
					if tl.focusedNode != undefined do (
						case tl.focusedNode.imageIndex of (
							1: parentNodeID = tl.focusedNode.id
							2: parentNodeID = tl.focusedNode.parentNode.id
						)
					)
				)
				
				tl.beginUnboundLoad()
				
				--Add new layer node
				local layerNode = nestedLayerManager.io.createLayerNode tl a parentNodeID
				tl.focusedNode = layerNode
				
				--Recursive parent folder state check
				for b=0 to tl.columns.count-1 do (
					case tl.columns.item[b].caption of (
						"Layers" : ()
						"Current" : ()
						"Color" : ()
						default : nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl layerNode tl.columns.item[b] (layerNode.item[tl.columns.item[b].caption])
					)
				)
				
				if nestedLayerManager.buttonPress do (
					--Deselect everything selected
					for b = tl.selection.count-1 to 0 by -1 do tl.selection.item[b].selected = false
					if layerNode != undefined do (
						layerNode.selected = true
						if nestedLayerManager.makeNewLayerCurrent do (
							nestedLayerManager.treeEvents.changeCurrentLayer tl layerNode
						)
						--Move selected objects to new layer
						if nestedLayerManager.addSelToLayer do (
							for b in selection do (
								a.addNode b
							)
							nestedLayerManager.io.setLayerExpandState tl 
						)
					)
				)
				
				tl.endUnboundLoad()
				
				--Enable edit mode for label editing after layer creation.
				if nestedLayerManager.buttonPress do tl.showEditor()
					
				--Add param change handler to layer to be used as a calback
				nestedLayerManager.callbacks.layerParamChangeHandler a
				
				if nestedLayerManager.showLog do format "[NLM] Layer Created Callback Triggered\n"
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerCreated a"
			)
				
		),
		
		--Layer Deleted Function
		function layerDeleted a = (
			
			try (
				
				--shortcut treelist link
				tl = nestedLayerManager.ui.tl
				
				--Delete layer node from tree
				tl.beginUnboundLoad()
				local layerHnd = getHandleByAnim a
				local layerNode = nestedLayerManager.io.getNodeByLayerHnd layerHnd
				if layerNode != undefined do (
					--Make layer 0 current if layer is current
					if layerNode == nestedLayerManager.currentLayerNode do (
						nestedLayerManager.treeEvents.changeCurrentLayer tl (nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim (layerManager.getLayer 0).layerAsRefTarg))
					)
					--Delete Node
					nestedLayerManager.io.getLayerHndHt.remove layerNode
					nestedLayerManager.io.getLayerNodeHt.remove layerHnd
					tl.deleteNode layerNode
				)
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] Layer Deleted Callback Triggered\n"
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerDeleted()"
			)
				
		),
		
		
		--Layer Paramater Changed (Visible, Freeze, Render, color)
		layerParamChangeQueue = #(),
		function layerParamChangeHandler theLayer = (
			
			try (
				when parameters theLayer change id:#nestedLayerManager theLayer do (
					if nestedLayerManager.handlersActive do (
						append nestedLayerManager.callbacks.layerParamChangeQueue (getHandleByAnim theLayer)
						registerRedrawViewsCallback nestedLayerManager_layerParamChange
					)
				)	
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerParamChangeHandler theLayer"
			)
			
		),
		
		--DotNet timer for layer paramaters that do not have callbacks
		layerParamsTimerThread = dotNetObject "CSharpUtilities.SynchronizingBackgroundWorker",
		layerParamsTimer = dotnetobject "System.Windows.Forms.Timer",
		function layerParamsCheckSynced s e = (
			
			try (
				
				local start = timeStamp()
				local result = #()
				local match = true
				local ghba = getHandleByAnim
				
				--Check that layer counts are the same
				if layerManager.count != nestedLayerManager.io.getLayerNodeHt.count do (
					append result #("mismatch", undefined, undefined)
					format "[NLM] Layer Count Mismatch Detected\n"
				)
				
				--If layer count is same, sync layers. If error detected, resync treelist.
				if match do (
					
					local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd 
					
					try (
						for a=0 to layerManager.count-1 do (
							--Local instances to speed things up
							local layer = (layerManager.getLayer a).layerAsRefTarg
							local layerHnd = ghba layer
							local layerNode = getNodeByLayerHnd layerHnd
							--Append any changes to result. Use handle as this is safer than transferring node instances.
							if layer.name != layerNode.item["Layers"] do (
								append result #("name", layerHnd)
							)
							if layer.current do (
								if layerNode.item["Current"] != true do append result #("current", layerHnd)
							)
						)
					) catch (
						match = false
						format "[NLM] Layer Sync Error Detected\n"
					)
				)
				if not match do (
					append result #("mismatch", undefined, undefined)
				)
				
				--Send result of any changes to make to AfterWork event, which is thread safe for UI changes.
				e.result = result
				local end = timeStamp()
				if nestedLayerManager.showSyncLog do format ("[NLM] Layer Check Synced Timer Completed in " + ((end-start) / 1000.00) as string + " seconds\n")
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerParamsCheckSynced()"
			)
		),
		
		--Function for timer sync check above. If anything is not synced, it is parsed to this funciton via a dotNet worker thread.
		function layerParamsSync s e = (
			
			try (
				
				if e.result != undefined do (
				
					if e.result.count > 0 do (
						
						local start = timeStamp()
						
						nestedLayerManager.ui.tl.beginUnboundLoad()
						
						local match = true
						local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
						local gabh = getAnimByHandle
						
						for a in e.result while match do (
							case a[1] of (
								"mismatch" : (
									match = false
								)
								"name" : (
									local node = getNodeByLayerHnd a[2]
									local layer = gabh a[2]
									if node != undefined and layer != undefined do node.setValue "Layers" layer.name
								)
								"current" : (
									local node = getNodeByLayerHnd a[2]
									local layer = gabh a[2]
									if node != undefined and layer != undefined do nestedLayerManager.treeEvents.changeCurrentLayer nestedLayerManager.ui.tl node
								)
							)
						)
						if not match do (
							format "[NLM] Refreshing Treelist\n"
							nestedLayerManager.mfEvents.refreshTree()
						)
						
						local end = timeStamp()
						if nestedLayerManager.showLog do format ("[NLM] Layer Sync Completed in " + ((end-start) / 1000.00) as string + " seconds\n")
						
						nestedLayerManager.ui.tl.endUnboundLoad()
						
					)
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerParamsSync()"
			)
			
		),
		
		--DotNet timer for layer parameters check. Dotnet workerthread used as the function completes far faster.
		function layerParamsTimerTick = (
			try (
				if not nestedLayerManager.callbacks.layerParamsTimerThread.isBusy do nestedLayerManager.callbacks.layerParamsTimerThread.runWorkerASync()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > layerParamsTimerTick()"
			)
		),
		
		
		
		
		-----------------------------------------------------------------------------
		-- NODE CALLBACKS
		-----------------------------------------------------------------------------
		
		--Node added to the scene
		function nodeAdded event objHndNodes = (
			
			try (
				
				local start = timeStamp()
				
				local tl = nestedLayerManager.ui.tl
				local nodeArray = #()
				local ghba = getHandleByAnim
				local gabh = getAnimByHandle
				local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				
				for objHnd in objHndNodes do (
					
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					local node = getNodeByObjectHnd objHnd
					
					--Check to see if node is already present. If it is present do not add to treeview. 
					--Duplicate check required due to node being added by postIO callback and nodeEvent callback. (sometimes nodeEventCallback does not work hence need for postIO)
					--Sometimes a node is created and then immediately deleted, classof seems to catch deleted nodes as undefined
					--isProperty is used because Max 2013 seems to add "$<root>" to the obj handle array, which causes an error
					if obj != undefined and classOf obj != undefined and isProperty obj #layer do (
						if node == undefined do (
							parentNode = getNodeByLayerHnd (ghba obj.layer.layerAsRefTarg)
							--If layerNode has not been defined, skip as this will cause an error.
							if parentNode != undefined do (
								if parentNode.expanded do (
									append nodeArray obj
								)
							)
						)
					)
				)
				
				--Add nodes to treelist
				if nodeArray.count > 0 do (
					nestedLayerManager.io.addObjNodes tl nodeArray
				)
				
				--Recalculate expand icons
				nestedLayerManager.io.setLayerExpandState tl
				
				tl.endUnboundLoad()
				
				local end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Nodes Added Completed in % Seconds\n" ((end-start)/1000.0)
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeAdded event objHndNodes"
			)
			
		),
		
		--Node deleted from scene
		function nodeDeleted event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local getNodeByObjectHnd  = nestedLayerManager.io.getNodeByObjectHnd
				local getObjectHndHt = nestedLayerManager.io.getObjectHndHt
				local getObjectNodeHt = nestedLayerManager.io.getObjectNodeHt
				
				tl.beginUnboundLoad()
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64 --Why?! Why would you not provide an integer64?
					local node = getNodeByObjectHnd objHnd
					if node != undefined do (
						getObjectHndHt.remove node
						getObjectNodeHt.remove objHnd
						tl.deleteNode node
					)
				)
				nestedLayerManager.io.setLayerExpandState tl 
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Deleted Callback Triggered\n"
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeDeleted event objHndNodes"
			)
			
		),
		
		--Node hide state changed
		fn nodeHideStateChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local getNodeByObjectHnd  = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64 --Why?! Why would you not provide an integer64?
					local node = getNodeByObjectHnd objHnd
					if node != undefined do (
						node.setValue "Visible" (not (getAnimByHandle objHnd).isNodeHidden)
					)
				)
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Hide State Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeHideStateChanged event objHndNodes"
			)
			
		),
		
		--Node freeze state changed
		function nodeFreezeStateChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local getNodeByObjectHnd  = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64 --Why?! Why would you not provide an integer64?
					local node = getNodeByObjectHnd objHnd
					if node != undefined do (
						node.setValue "Freeze" (getAnimByHandle objHnd).isNodeFrozen
					)
				)
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Freeze State Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeFreezeStateChanged event objHndNodes"
			)
			
		),
		
		--Node Layer state changed
		function nodeLayerChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local parentNode
				local runDeleteEvent = false
				local runCreateEvent = false
				local ghba = getHandleByAnim
				local gabh = getAnimByHandle
				local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				
				for objHnd in objHndNodes do (
					
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					
					if obj != undefined do (
						/*
							The nodeEventCallback system occasionally fires a layer changed event instead of a delete or add event. 
							The if/then statements below catches this behaviour and fires the correct event.
						*/
						if classOf obj != undefined then (
							parentNode = getNodeByLayerHnd (ghba obj.layer.layerAsRefTarg)
						)
						else (
							runDeleteEvent = true
						)
						if parentNode != undefined do (
							local objNode = getNodeByObjectHnd objHnd	
							if objNode != undefined then (
								tl.moveNode objNode parentNode
							) else (
								runCreateEvent = true
							)
						)
					)
				)
				
				--Recalculate expand icons
				nestedLayerManager.io.setLayerExpandState tl
				
				if runDeleteEvent do (
					nestedLayerManager.callbacks.nodeDeleted event objHndNodes
				)
				if runCreateEvent do (
					nestedLayerManager.callbacks.nodeAdded event objHndNodes
				)
				
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Layer Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeLayerChanged event objHndNodes"
			)
			
		),
			
		--Node name changed
		function nodeNameChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local gabh = getAnimByHandle
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					local objNode = getNodeByObjectHnd objHnd
					if objNode != undefined do (
						objNode.setValue "Layers" obj.name
					)
				)
				
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Name Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeNameChanged event objHndNodes"
			)
			
		),
		
		--Node wirecolor changed
		function nodeWireColorChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local gabh = getAnimByHandle
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				function dnCol c = (dotNetClass "System.Drawing.Color").FromArgb c.r c.g c.b
				
				tl.beginUnboundLoad()
				
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					local objNode = getNodeByObjectHnd objHnd
					if objNode != undefined do (
						objNode.setValue "Color" (dnCol obj.wireColor)
					)
				)
				
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node WireColor Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeWireColorChanged event objHndNodes"
			)
			
		),
		
		--Node renderable changed
		function nodeRenderChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local gabh = getAnimByHandle
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					local objNode = getNodeByObjectHnd objHnd
					if objNode != undefined do (
						objNode.setValue "Render" obj.renderable
					)
				)
				
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Renderable State Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeRenderChanged event objHndNodes"
			)
			
		),
		
		
		
		--Node selection changed event
		function nodeSelectionChanged event objHndNodes = (
			
			try (
				
				if nestedLayerManager.selectObjectsInTree do (
					
					if nestedLayerManager.runSelObjFn then (
						
						local tl = nestedLayerManager.ui.tl
						local gabh = getAnimByHandle
						local ghba = getHandleByAnim
						local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
						local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
						local expandParents = nestedLayerManager.treeEvents.expandParents
						local objNode
						local firstObjNode
						
						tl.beginUnboundLoad()
						for a = tl.selection.count-1 to 0 by -1 do tl.selection.item[a].selected = false
						--Loop through selection rather than handles so that deselected objects are not reselected
						for obj in selection do (
							layerNode = getNodeByLayerHnd (ghba obj.layer.layerAsRefTarg)
							if layerNode != undefined do layerNode.expanded = true
							objHnd = ghba obj
							local obj = gabh objHnd
							local objNode = getNodeByObjectHnd objHnd
							if objNode != undefined do (
								objNode.selected = true
								expandParents objNode
								if firstObjNode == undefined do firstObjNode = objNode
							)
						)
						if firstObjNode != undefined do tl.focusedNode = firstObjNode
						tl.endUnboundLoad()
						
						if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Selection Changed Callback Triggered\n"
						
					) else (
						nestedLayerManager.runSelObjFn = true
					)
					
				)
				
				if nestedLayerManager.selectLayersInTree do (
					
					if nestedLayerManager.runSelObjFn then (
						
						local tl = nestedLayerManager.ui.tl
						local ghba = getHandleByAnim
						local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
						local expandParents = nestedLayerManager.treeEvents.expandParents
						local layerNode
						local firstLayerNode
						
						tl.beginUnboundLoad()
						for a = tl.selection.count-1 to 0 by -1 do tl.selection.item[a].selected = false
						for a in selection do (
							layerNode = getNodeByLayerHnd (ghba a.layer.layerAsRefTarg)
							if layerNode != undefined do (
								if not layerNode.selected do (
									layerNode.selected = true
									tl.focusedNode = layerNode
									expandParents layerNode
									if firstLayerNode == undefined do firstLayerNode = layerNode
								)
							)
						)
						if firstLayerNode != undefined do tl.focusedNode = firstLayerNode
						tl.endUnboundLoad()
						
						if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Selection Changed Callback Triggered\n"
						
					) else (
						nestedLayerManager.runSelObjFn = true
					)
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > nodeSelectionChanged event objHndNodes"
			)
			
		),
		
		
		
		
		--Function used to detect and sync display properties
		function displayPropertiesChanged event objHndNodes = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				local gabh = getAnimByHandle
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				
				tl.beginUnboundLoad()
				for objHnd in objHndNodes do (
					objHnd = objHnd as integer64
					local obj = gabh objHnd
					local objNode = getNodeByObjectHnd objHnd
					if objNode != undefined do (
						objNode.setValue "Box" obj.boxMode
					)
				)
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] NodeEventCallback Node Display Properties State Change Callback Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > displayPropertiesChanged event objHndNodes"
			)
			
		),
		
		
		
		
		
		-----------------------------------------------------------------------------
		-- GENERAL TREELIST CALLBACK FUNCTIONS
		-----------------------------------------------------------------------------
		
		function preIOoperation = (
			
			try (
				
				--Remove persistent values so merged value is loaded
				if persistents.isPersistent #nestedLayerManager_mergeData do persistents.remove #nestedLayerManager_mergeData
				nestedLayerManager_mergeData = undefined
				
				--Save layer and object count to be used for post IO operation
				nestedLayerManager.preIOlayerCount = layerManager.count
				nestedLayerManager.preIOObjectCount = $*.count
				
				--Update log if enabled
				if nestedLayerManager.showLog do format "[NLM] Pre Merge Operation Callback Triggered\n"
				
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonEvents.ms > preIOoperation()"
			)
			
		),
		
		function postIOoperation = (
			
			try (
				
				start = timeStamp()
				
				--compare preIOoperation layer count, if the count is higher add them to treelist if they are not present and add callback.
				local newLayers = for a = nestedLayerManager.preIOlayerCount + 1 to layerManager.count collect (layerManager.getLayer (a-1)).layerAsRefTarg
				local layers = #()
				local currentLayer = undefined
				local tl = nestedLayerManager.ui.tl
					
				for a in newLayers do (
					if nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim a) == undefined do (
						--Append new layer node
						append layers a
						--Check for current layer
						if a.current do currentLayer = a
					)
					--Add callback
					nestedLayerManager.callbacks.layerParamChangeHandler a
				)
				
				--Add nodes to treelist
				if layers.count > 0 do (
					tl.beginUnboundLoad()
					
					for layer in layers do nestedLayerManager.io.createLayerNode tl layer 0
					local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
					
					if nestedLayerManager.loadFoldersOnMerge do (
						--Do not run on xRef merge. Seperate callback and function is used for obtaining data in nested xRefs.
						if callbacks.notificationParam() != 1 then (
							if nestedLayerManager_mergeData != undefined do (
								local layerDirs = filterString nestedLayerManager_mergeData[1] "{|}"
								local folderDirs = filterString nestedLayerManager_mergeData[2] "{|}"
								local folderCols = filterString nestedLayerManager_mergeData[3] "{|}"
								for layerDir in layerDirs do (
									layerDirArr = filterString layerDir "\\"
									layer = layerManager.getLayerFromName layerDirArr[layerDirArr.count]
									if layer != undefined do (
										if findItem layers layer.layerAsRefTarg != 0 do (
											if layer != undefined do (
												local node = tl.nodes.item[0]
												local currentFolderDir = stringStream ""
												for a=1 to layerDirArr.count do (
													if a < layerDirArr.count then (
														makeFolder = true
														format "%\\" layerDirArr[a] to:currentFolderDir
														if node.hasChildren do (
															local nodeNodes = node.nodes
															for b=0 to nodeNodes.count-1 while makeFolder do (
																local layerDirArrStr = layerDirArr[a]
																local nodeNodesItem = nodeNodes.item[b]
																if nodeNodesItem.item["Layers"] == layerDirArrStr do (
																	node = nodeNodesItem
																	makeFolder = false
																)
															)
														)
														if makeFolder do (
															local index = findItem folderDirs (currentFolderDir as string)
															local folderColArr = filterString folderCols[index] "(color )"
															local folderColDn = dnCol (folderColArr[1] as integer) (folderColArr[2] as integer) (folderColArr[3] as integer)
															node = nestedLayerManager.io.createFolderNode tl layerDirArr[a] folderColDn node.id
														)
													) else (
														layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer.layerAsRefTarg)
														tl.moveNode layerNode node
													)
												)
											)
										)
									)
								)
								nestedLayerManager.io.setFolderStates()
							)
						)
					)
					tl.endUnboundLoad()
				)
				
				if currentLayer != undefined do (
					currentLayerNode = nestedLayerManager.io.getNodeFromLayer (getHandleByAnim currentLayer)
					nestedLayerManager.currentLayerNode = currentLayerNode
					nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl currentLayerNode "Current" grayed
				)
				
				--compare preIOoperation object count, if the count is higher add them to treelist if they are not present
				allNodes = $* as array
				newObjects = for a = nestedLayerManager.preIOObjectCount +1 to allNodes.count collect allNodes[a]
				if newObjects.count > 0 do (
					newObjectsHandle = for a in newObjects collect (getHandleByAnim a)
					nestedLayerManager.callbacks.nodeAdded undefined newObjectsHandle
				)
				
				--Update log if enabled
				end = timestamp()
				if nestedLayerManager.showLog do format "[NLM] Post Merge Operation Callback Completed in % seconds\n" ((end-start)/1000.0)
			
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > postIOOperation()"
			)
			
		),
		
		--Recursive xRef function to load data from nested xRefs
		function importNestedDataFromXrefRecursive tl xRef = (
			
			try (
					
				--Assign shortcuts
				nlmRootNode = tl.nodes.item[0]
				
				--Obtain nested data from xref
				xRefNLM = xRef.tree.custAttributes["nestedLayerManager"]
				if not xRef.disabled and xRefNLM != undefined do (
						
					--Obtain nested data from old scene
					local xfolderDirs = xRefNLM.folderDirs
					local xfoldercolors = xRefNLM.folderColours
					local xlayerDirs = xRefNLM.layerDirs
					local xlayerRefs = xRefNLM.layerRefs
					local xdataVersion = xRefNLM.dataVersion
					
					--Only run this on new layers so that empty folders are not imported. (When a layer is moved, the old folder position should not be loaded)
					local newLayers = for a = nestedLayerManager.preIOlayerCount + 1 to layerManager.count collect (layerManager.getLayer (a-1)).layerAsRefTarg
					
					for a=1 to xLayerRefs.count do (
						
						local layer = xLayerRefs[a]
						
						local buildFolders = false
						if findItem newLayers xLayerRefs[a] != 0 do buildFolders = true
						
						if layer != undefined and buildFolders then (
							
							--Local values
							local tl = nestedLayerManager.ui.tl
							local node = tl.nodes.item[0]
							local fArr = filterString xLayerDirs[a] "\\"
							local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
							local fDir = stringStream ""
							
							--Build folders
							for level = 1 to fArr.count do (
								local notFound = true
								local fNode = undefined
								format "%%" fArr[level] "\\" to:fDir
								
								for b=0 to node.nodes.count-1 while notFound do (
									if node.nodes.item[b].imageIndex == 1 do (
										if node.nodes.item[b].item["Layers"] == fArr[level] do (
											fNode = node.nodes.item[b]
											notFound = false
										)
									)
								)
								if notFound then (
									local fCol = random [0,0,0] [255,255,255] as color
									for b=1 to xFolderDirs.count do (
										if xFolderDirs[b] == fDir as string do (
											fCol = xFolderColors[b]
										)
									)
									fDncol = dnCol fCol.r fCol.g fCol.b
									node = nestedLayerManager.io.createFolderNode tl fArr[level] fDnCol node.id
								) else (
									node = fNode
								)
							)
							
							--Move layer to parent folder node
							layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer)
							if layerNode != undefined do (
								tl.moveNode layerNode node
							)
						
						)
						
					)
					
				)
				
				for a=1 to (xrefs.getXRefFileCount root:xRef) do (
					nestXRef = xrefs.getXRefFile a root:xRef
					if xRef != undefined do nestedLayerManager.callbacks.importNestedDataFromXrefRecursive tl nestXRef
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > importNestedDataFromXrefRecursive()"
			)
			
		),
		
		--Access custom attribute data from xRef scenes and update nlm on xRef callback fire
		function importNestedDataFromXref = (
			
			try (
				
				if nestedLayerManager.loadFoldersOnXref then (
					
					start = timeStamp()
					
					--Assign shortcuts
					tl = nestedLayerManager.ui.tl
					nlmRootNode = tl.nodes.item[0]
					
					tl.beginUnboundLoad()
					
					--Loop through each xRef 
					for a=1 to (xrefs.getXRefFileCount()) do (
						--access rootnode of xref scene. 
						xRef = xrefs.getXRefFile a
						--Run recursive xRef function
						nestedLayerManager.callbacks.importNestedDataFromXrefRecursive tl xRef
					)
					
					--Recursively work through treelist and find correct folder row states
					nestedLayerManager.io.setFolderStates()			
					
					tl.endUnboundLoad()
					
					--Update log if enabled
					end = timeStamp()
					if nestedLayerManager.showLog do  format "[NLM] xRef Scene Callback Completed in % seconds\n" ((end-start)/1000.0)
						
				) else (
					if nestedLayerManager.showLog do format "[NLM] Xref Update Callback Triggered - DISABLED in Settings\n"
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > importNestedDataFromXref()"
			)
		),
		
		--Add all callbacks on loading
		function addCallbacks = (
			
			try (
				
				--Callbacks shortuct link
				cb = nestedLayerManager.callbacks
				
				
				-----------------------------------------------------------------------------
				-- ASSIGN LAYER CALLBACK FUNCTIONS
				-----------------------------------------------------------------------------
				
				--Shortcut link to callbacks
				cb = nestedLayerManager.callbacks
				
				--Callbacks
				callbacks.addScript #layerCreated "nestedLayerManager.callbacks.layerCreated (callbacks.notificationParam())" id:#nestedLayerManager
				callbacks.addScript #layerDeleted "nestedLayerManager.callbacks.layerDeleted (callbacks.notificationParam())" id:#nestedLayerManager
				
				--Add when construct change handler to all layers
				for a=0 to layerManager.count-1 do layerParamChangeHandler (LayerManager.getLayer a).layerAsRefTarg
				
				--LayerParam DotNet timer for parameters that do not have callbacks (name, current)
				cb.layerParamsTimer.interval = 2000 -- every two seconds
				function layerParamsCheckSyncedLink s e = nestedLayerManager.callbacks.layerParamsCheckSynced s e
				function layerParamsSyncLink s e = nestedLayerManager.callbacks.layerParamsSync s e
				dotNet.addEventHandler cb.layerParamsTimerThread "doWork" layerParamsCheckSyncedLink
				dotNet.addEventHandler cb.layerParamsTimerThread "runWorkerCompleted" layerParamsSyncLink
				function layerParamsTimerTickLink = if nestedLayerManager != undefined do nestedLayerManager.callbacks.layerParamsTimerTick()
				dotnet.addEventHandler cb.layerParamsTimer "Tick" layerParamsTimerTickLink
				cb.layerParamsTimer.start()
				
				
				-----------------------------------------------------------------------------
				-- ASSIGN NODE CALLBACK FUNCTIONS
				-----------------------------------------------------------------------------
				
				function nodeHideStateChangedLink event nodes = nestedLayerManager.callbacks.nodeHideStateChanged event nodes
				function nodeFreezeStateChangedLink event nodes = nestedLayerManager.callbacks.nodeFreezeStateChanged event nodes
				function nodeLayerChangedLink event nodes = nestedLayerManager.callbacks.nodeLayerChanged event nodes
				function nodeNameChangedLink event nodes = nestedLayerManager.callbacks.nodeNameChanged event nodes
				function nodeWireColorChangedLink event nodes = nestedLayerManager.callbacks.nodeWireColorChanged event nodes
				function nodeRenderChangedLink event nodes = nestedLayerManager.callbacks.nodeRenderChanged event nodes
				function nodeAddedLink event nodes = nestedLayerManager.callbacks.nodeAdded event nodes
				function nodeDeletedLink event nodes = nestedLayerManager.callbacks.nodeDeleted event nodes
				function nodeSelectionChangedLink event nodes = nestedLayerManager.callbacks.nodeSelectionChanged event nodes
				function displayPropertiesChangedLink event nodes = nestedLayerManager.callbacks.displayPropertiesChanged event nodes
				
				nestedLayerManager.nodeCallback = NodeEventCallback \
				added: nodeAddedLink \
				deleted: nodeDeletedLink \
				hideChanged: nodeHideStateChangedLink \
				freezeChanged: nodeFreezeStateChangedLink \
				layerChanged: nodeLayerChangedLink \
				nameChanged: nodeNameChangedLink \
				wireColorChanged: nodeWireColorChangedLink \
				renderPropertiesChanged: nodeRenderChangedLink \
				selectionChanged: nodeSelectionChangedLink \
				displayPropertiesChanged: displayPropertiesChangedLink
				
				-----------------------------------------------------------------------------
				-- ASSIGN SYSTEM CALLBACK FUNCTIONS
				-----------------------------------------------------------------------------
				
				--Save nested layer manager on file save
				callbacks.addScript #filePreSave "nestedLayerManager.io.save()" id:#nestedLayerManager
				
				--Close nested layer manager on new, reset and open
				callbacks.addScript #systemPreNew "nestedLayerManager.io.resetNLMClean()" id:#nestedLayerManager
				callbacks.addScript #systemPreReset "nestedLayerManager.io.resetNLMClean()" id:#nestedLayerManager
				callbacks.addScript #filePreOpen "nestedLayerManager.io.resetNLMClean()" id:#nestedLayerManager
				callbacks.addScript #systemPostNew "nestedLayerManager.io.resetNLMPopulate()" id:#nestedLayerManagerPostReset
				callbacks.addScript #systemPostReset "nestedLayerManager.io.resetNLMPopulate()" id:#nestedLayerManagerPostReset
				callbacks.addScript #filePostOpen "nestedLayerManager.io.resetNLMPopulate()" id:#nestedLayerManagerPostReset
				
				--Check layer count in nested layer manager on merge and import as callbacks are sometimes not fired.
				callbacks.addScript #filePreMerge "nestedLayerManager.callbacks.preIOoperation()" id:#nestedLayerManager
				callbacks.addScript #preImport "nestedLayerManager.callbacks.preIOoperation()" id:#nestedLayerManager
				callbacks.addScript #filePostMerge "nestedLayerManager.callbacks.postIOoperation()" id:#nestedLayerManager
				callbacks.addScript #postImport "nestedLayerManager.callbacks.postIOoperation()" id:#nestedLayerManager
				
				--Add nested data to scene on post xref scene update and post scene merge
				callbacks.addScript #sceneXrefPostMerge "nestedLayerManager.callbacks.importNestedDataFromXref()" id:#nestedLayerManager
				
				--Save ini prefs on max close
				callbacks.addScript #preSystemShutdown "nestedLayerManager.mfEvents.preSystemShutdownClose()" id:#nestedLayerManager
				
				
				-----------------------------------------------------------------------------
				-- ASSIGN PERSISTANT CALLBACK FUNCTIONS
				-----------------------------------------------------------------------------
				
				--Permanant Callback to remove layer references that have been deleted, fired on save.
				callbacks.removeScripts id:#nestedLayerManagerPersistent
				callbacks.addScript #filePreSave "try(rootNode.nestedLayerManager.cleanLayerCA())catch(format\"[NLM] CA Clean Function Not Defined\")" id:#nestedLayerManagerPersistent persistent:true
				
				if nestedLayerManager.showLog do format "[NLM] Callbacks Added\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > addCallbacks()"
			)
			
		),
		
		function removeCallbacks = (
			
			try (
				callbacks.RemoveScripts id:#nestedLayerManager
				deleteAllChangeHandlers id:#nestedLayerManager
				--Layer timer and assosciated thread
				nestedLayerManager.callbacks.layerParamsTimer.Stop()
				dotnet.removeAllEventHandlers nestedLayerManager.callbacks.layerParamsTimerThread
				dotNet.removeAllEventHandlers nestedLayerManager.callbacks.layerParamsTimer
				--NodeEventCallback removal - make varialble undefined and manually run a garbage collection
				nestedLayerManager.nodeCallback = undefined
				gc light:true
				if nestedLayerManager.showLog do format "[NLM] Callbacks Removed\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"callbacks.ms > removeCallbacks()"
			)
			
		),
		
		function removePostCallbacks = (
			callbacks.RemoveScripts id:#nestedLayerManagerPostReset
		)
		
	)
	
	nestedLayerManager.callbacks = nestedLayerManagerCallbackStruct()	
)