--Nested layer manager search bar events struct
(
	
	struct nestedLayerManagerSearchEventsStruct (
		
		hook = dotNetObject "NestedLayerManager.MaxDialog.WindowHook",
		
		function gotFocus s e = (
			try (
				selectAll = true
				enableaccelerators = false
				nestedLayerManager.searchEvents.hook.AssignHandle (dotNetObject "IntPtr" s.handle)
			) catch (
				enableaccelerators = true
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > gotFocus()"
			)
		),
		
		function lostFocus s e = (
			try (
				enableaccelerators = true
				nestedLayerManager.searchEvents.hook.releaseHandle()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > lostFocus()"
			)
		),
		
		function clearSearchBar = (
			try (
				nestedLayerManager.ui.topPanel.searchBarText = ""
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > clearSearchBar()"
			)
		),
		
		function keyDown s e = (
			
			try (
				
				if (e.keyCode == e.keyCode.return) do (
					
					local tl = nestedLayerManager.ui.tl
					local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
					local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
					
					if s.text == "" then (
						
						tl.beginUpdate()
						for a in nestedLayerManager.folderNodes do a.visible = true
						for a=0 to layerManager.count-1 do (
							local layer = (layerManager.getLayer a).layerAsRefTarg
							local layerNode = getNodeByLayerHnd (getHandleByAnim layer)
							if layerNode != undefined do (
								layerNode.visible = true
							)
						)
						tl.endUpdate()
					
					) else (
						
						local searchString = "*" + s.text + "*"
						local start = timeStamp()
						local searchNodes = makeUniqueArray nestedLayerManager.folderNodes
						
						tl.beginUnboundLoad()
						tl.selection.set undefined
						tl.focusedNode = undefined
						
						--Add layer nodes to search array. Check to see if object nodes need to be created and add them too.
						for a=0 to layerManager.count-1 do (
							local layer = (layerManager.getLayer a).layerAsRefTarg
							local layerNode = getNodeByLayerHnd (getHandleByAnim layer)
							if layerNode != undefined do (
								append searchNodes layerNode
								layer.nodes &objArr
								for b in objArr do (
									if matchPattern b.name pattern:searchString do (
										layerNode.expanded = true
										objNode = getNodeByObjectHnd (getHandleByAnim b)
										if objNode != undefined do (
											append searchNodes objNode
										)
									)
								)
							)
						)
						
						--Search through all items in searchNodes array
						for a in searchNodes do (
							if matchPattern (a.item["Layers"]) pattern:searchString then (
								pNode = a
								while pNode.parentNode.level != 0 do (
									pNode = pNode.parentNode
									pNode.expanded = true
									pNode.visible = true
								)
								a.visible = true
								a.selected = true
							) else (
								a.visible = false
							)
						)
						
						tl.endUnboundLoad()
						tl.focus()
						
						local end = timeStamp()
						if nestedLayerManager.showLog do format ("[NLM] Completed in " + ((end-start) / 1000.00) as string + " seconds\n")
						
					)
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > keyDown s e"
			)
		),
		
		
		
		function initialiseEvents = (
			try (
				local tp = nestedLayermanager.ui.topPanel
				dotNet.addEventHandler tp "searchBarGotFocus" gotFocus
				dotNet.addEventHandler tp "searchBarLostFocus" lostFocus
				dotNet.addEventHandler tp "searchBarKeyDown" keyDown
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > initialiseEvents()"
			)
		),
		
		function removeEvents = (
			try (
				local tp = nestedLayermanager.ui.topPanel
				dotNet.removeEventHandlers tp "searchBarGotFocus"
				dotNet.removeEventHandlers tp "searchBarLostFocus"
				dotNet.removeEventHandlers tp "searchBarKeyDown"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"searchEvents.ms > removeEvents()"
			)
		)
		
	)-- End Struct
	
	nestedLayerManager.searchEvents = nestedLayerManagerSearchEventsStruct()
	
)