--Nested layer manager treelist events struct
(
	struct nestedLayerManagerTreeEventsStruct (
		
		
		-------------------------------------------------------------
		-- GENERAL TREELIST (NON EVENT) FUNCTIONS
		-------------------------------------------------------------
		
		--Remove illegal characters (Currently % and /)
		function removeIllegalCharacters str = (
			
			--Various methods tested, and this is by FAR the quickest. Loop took 172ms, this method takes 11ms when looping 10000 times
			try (
				str = substituteString str "%" "_"
				str = substituteString str "/" "_"
				--Return string
				str
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > removeIllegalCharacters str"
			)
			
		),
		
		--Find node under mouse
		function nodeUnderMouse tl = (
			
			try (
				result = (tl.calcHitInfo (tl.PointToClient tl.MousePosition)).node
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > nodeUnderMouse tl"
			)
			
		),
		
		--Find cell under mouse
		function colUnderMouse tl = (
			
			try (
				result = (tl.calcHitInfo (tl.PointToClient tl.MousePosition)).column
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > colUnderMouse tl"		
			)
			
		),
		
		--Sort column, feed in column name and order of sort
		function sortColumn col order = (
			
			try (
				local tl = nestedLayerManager.ui.tl
				case order of (
					ascending : tl.columns.item[col].sortOrder = tl.columns.item[col].sortOrder.Ascending
					descending : tl.columns.item[col].sortOrder = tl.columns.item[col].sortOrder.Decending
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > sortColumn col order"
			)
			
		),
		
		--Recursive function to change parent folder checkbox state on selected cell
		--Try/Catch not used as this is recursive and called many times.
		function changeParentFolderCellRecursive tl node col value = (
			
			local parentNode = node.parentNode
			if parentNode != undefined do (
				case value of (
					grayed : parentNode.setValue col grayed
					default : (
						local checkState = value
						local childNodes = parentNode.nodes
						for a=0 to childNodes.count-1 while checkState == value do (
							if (childNodes.item[a].item[col]) != value do checkState = grayed
						)
						parentNode.setValue col checkState
					)
				)
				changeParentFolderCellRecursive tl parentNode col checkState
			)
			
		),
		
		--Recursive function to change parent folder to value. Same as above function but does not account for grayed boxes. Used to turn every parent node OFF or ON.
		--Try/Catch not used as this is recursive and called many times.
		function changeParentFolderCellValueRecursive tl node col value = (
			
			local parentNode = node.parentNode
			if node.parentNode != undefined do (
				parentNode.setValue col value
				changeParentFolderCellValueRecursive tl parentNode col value
			)
			
		),
		
		--Recursive function to change child node checkbox states on selected cell
		--Try/Catch not used as this is recursive and called many times.
		function changeChildCellRecursive tl node col value = (
			
			local childNodes = node.nodes
			local getLayerHndByNode = nestedLayerManager.io.getLayerHndByNode
			local gabh = getAnimByHandle
			for a=0 to childNodes.count-1 do (
				item = childNodes.item[a]
				item.setValue col value
				case item.imageIndex of (
					2 : (
							case col.caption of (
								"Visible" : if (hnd = getLayerHndByNode item) != undefined do (gabh hnd).on = value
								"Freeze" : if (hnd = getLayerHndByNode item) != undefined do (gabh hnd).isFrozen = value
								"Render" : if (hnd = getLayerHndByNode item) != undefined do (gabh hnd).renderable = value
								"Box" : if (hnd = getLayerHndByNode item) != undefined do (gabh hnd).boxMode = value
							)
					)
					1 : changeChildCellRecursive tl item col value
				)
			)
			
		),
		
		--Change current layer
		function changeCurrentLayer tl newNode = (
			
			try (
				
				if nestedLayerManager.currentLayerNode != undefined  and newNode != undefined do (
					
					tl.beginUnboundLoad()
					
					--Set old current layer icon to false, recursively work on parent folders.
					nestedLayerManager.currentLayerNode.setValue "Current" false
					changeParentFolderCellRecursive tl nestedLayerManager.currentLayerNode "Current" false
					
					--Set new current layer icon to true, recursively work on parent folders.
					newNode.setValue "Current" true
					layerHnd = nestedLayerManager.io.getLayerHndByNode newNode
					if layerHnd != undefined do (getAnimByHandle layerHnd).current = true
					nestedLayerManager.currentLayerNode = newNode
					changeParentFolderCellRecursive tl newNode "Current" grayed
					
					tl.endUnboundLoad()
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > changeCurrentLayer tl newNode"
			)
			
		),
		
		--Move objects in scene to new layer
		function moveObjectsNewLayer tl dropNode = (
			
			try (
				
				local getLayerHndByNode = nestedLayerManager.io.getLayerHndByNode
				local getObjectHndByNode = nestedLayerManager.io.getObjectHndByNode
				local gabh = getAnimByHandle
				
				local dropNodeLayerHnd = getLayerHndByNode dropNode
				
				for a=0 to tl.selection.count-1 do (
					local dragNodeObjectHnd = getObjectHndByNode tl.selection.item[a]
					if dropNodeLayerHnd != undefined and dragNodeObjectHnd != undefined do 
						(gabh dropNodeLayerHnd).addNode (gabh dragNodeObjectHnd)
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > moveObjectsNewLayer tl dropNode"
			)
			
		),
		
		--Expand all parent nodes so that node is visible
		--Try/Catch not used as this is always called from other functions.
		function expandParents node = (
			pn = node.parentNode
			if pn != undefined do (
				pn.expanded = true
				expandParents pn
			)
		),
		
		
		---------------------------------------------------------
		-- EVENT FUNCTIONS
		---------------------------------------------------------
		
		
		--Mouse down function to fire other functions
		function mouseDown tl event = (
			
			try (
			
				start = timeStamp()
				
				--Left click
				if event.button == event.button.left do (
					
					local col = nestedLayerManager.treeEvents.colUnderMouse tl --hitInfo.column
					local node = nestedLayerManager.treeEvents.nodeUnderMouse tl --hitInfo.node
					
					if col != undefined and node != undefined do (
						
						local value = if node.item[col] == false then value = false else true
						local colName = col.caption
						local newcolor
						
						local gabh = getAnimByHandle
						local getObjectHndByNode = nestedLayerManager.io.getObjectHndByNode
						local getLayerHndByNode = nestedLayerManager.io.getLayerHndByNode
						
						local changeChildCellRecursive = nestedLayerManager.treeEvents.changeChildCellRecursive
						local changeParentFolderCellRecursive = nestedLayerManager.treeEvents.changeParentFolderCellRecursive
						
						case node.imageIndex of (
							0 : ()
							1 : ()
							2 : ()
							default : (if tlSelCount == nestedLayerManager.selectionCount and colName == "Layers" and nestedLayerManager.selectObjectsInScene do clearSelection())
						)
						
						--Mousedown event fires before focusedNode changes, which makes the wrong nodes change value. This loop below fixes that.
						--Yeah it's pretty horrible, but the UI is much more responsive when a mouseDown event is used and this hack/workaround is required.
						withinSel = false
						for a=0 to tl.selection.count while not withinSel do (
							if tl.selection.item[a] == node do withinSel = true
						)
						if not withinSel do (
							local klmk = (dotNetClass "system.windows.forms.control").modifierKeys
							if klmk != klmk.control and klmk != klmk.shift do (
								tl.selection.set node
								nestedLayerManager.selectionCount = 1
							)
						)
						
						local tlSel = tl.selection
						local tlSelCount = tlSel.count
						
						case colName of (
							
							"Current" : (
								tl.beginUpdate()
								local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
								if node.imageIndex == 2 do nestedLayerManager.treeEvents.changeCurrentLayer tl node
								tl.topVisibleNodeIndex = topNodeInd
								tl.endUpdate()
							)
							
							"Visible" : (
								undo "Visibility Change" on (
									local layers = #()
									local objArr = #()
									tl.beginUpdate()
									local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
									tl.beginUnboundLoad()
									nestedLayerManager.handlersActive = false
									for a=0 to tlSelCount-1 do (
										local loopNode = tlSel.item[a]
										local nextLoopNode = if a < tlSelCount-1 do tlSel.item[a+1]
										case loopNode.imageIndex of (
											1 : (
												loopNode.setValue col (not value)
												changeChildCellRecursive tl loopNode col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do (
													changeParentFolderCellRecursive tl loopNode col (not value)
												)
											)
											2 : (
												loopNode.setValue col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do
													nestedLayerManager.treeEvents.changeParentFolderCellRecursive tl loopNode col (not value)
												if (hnd = getLayerHndByNode loopNode) != undefined do append layers (gabh hnd)
											)
											default : (
												loopNode.setValue col (not value)
												if (hnd = getObjectHndByNode loopNode) != undefined do append objArr (gabh hnd)
											)
										)
									)
									tl.endUnboundLoad()
									tl.topVisibleNodeIndex = topNodeInd
									tl.endUpdate()
									tl.refresh() --Refresh UI asap to reflect changes, continue to change values in max
									for a in layers do a.on = not value
									for a in objArr do if isValidNode a do a.isNodeHidden = value
								)
								nestedLayerManager.handlersActive = true
							)
							
							"Freeze" : (
								undo "Freeze Change" on (
									local layers = #()
									local objArr = #()
									tl.beginUpdate()
									local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
									tl.beginUnboundLoad()
									nestedLayerManager.handlersActive = false
									for a=0 to tlSelCount-1 do (
										local loopNode = tlSel.item[a]
										local nextLoopNode = if a < tlSelCount-1 do tlSel.item[a+1]
										case loopNode.imageIndex of (
											1 : (
												loopNode.setValue col (not value)
												changeChildCellRecursive tl loopNode col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do (
													changeParentFolderCellRecursive tl loopNode col (not value)
												)
											)
											2 : (
												loopNode.setValue col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do
													changeParentFolderCellRecursive tl loopNode col (not value)
												if (hnd = getLayerHndByNode loopNode) != undefined do append layers (gabh hnd)
											)
											default : (
												loopNode.setValue col (not value)
												if (hnd = getObjectHndByNode loopNode) != undefined do append objArr (gabh hnd)
											)
										)
									)
									tl.endUnboundLoad()
									tl.topVisibleNodeIndex = topNodeInd
									tl.endUpdate()
									tl.refresh() --Refresh UI asap to reflect changes, continue to change values in max
									for a in layers do a.isFrozen = not value
									for a in objArr do if isValidNode a do a.isNodeFrozen = not value
									nestedLayerManager.handlersActive = true
								)
							)
							
							"Render" : (
								local layers = #()
								local objArr = #()
								tl.beginUpdate()
								local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
								tl.beginUnboundLoad()
								nestedLayerManager.handlersActive = false
								for a=0 to tlSelCount-1 do (
									local loopNode = tlSel.item[a]
									local nextLoopNode = if a < tlSelCount-1 do tlSel.item[a+1]
									case loopNode.imageIndex of (
										1 : (
											loopNode.setValue col (not value)
											changeChildCellRecursive tl loopNode col (not value)
											if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do (
												changeParentFolderCellRecursive tl loopNode "Render" (not value)
											)
										)
										2 : (
											loopNode.setValue col (not value)
											if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do
												changeParentFolderCellRecursive tl loopNode col (not value)
											if (hnd = getLayerHndByNode loopNode) != undefined do append layers (gabh hnd)
										)
										default : (
											loopNode.setValue col (not value)
											if (hnd = getObjectHndByNode loopNode) != undefined do append objArr (gabh hnd)
										)
									)
								)
								tl.endUnboundLoad()
								tl.topVisibleNodeIndex = topNodeInd
								tl.endUpdate()
								tl.refresh() --Refresh UI asap to reflect changes, continue to change values in max
								for a in layers do a.renderable = not value
								for a in objArr do if isValidNode a do a.renderable = not value
								nestedLayerManager.handlersActive = true
							)
							
							"Color" : (
								local dnCol = node.item["Color"]
								local newcolor
								local layers = #()
								local objArr = #()
								if dnCol != false do newcolor = colorPickerDlg (color dnCol.r dnCol.g dnCol.b) "" pos:[(mouse.screenpos[1]-380),(mouse.screenpos[2]+10)]
								if newcolor != undefined do (
									tl.beginUpdate()
									local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
									tl.beginUnboundLoad()
									nestedLayerManager.handlersActive = false
									for a=0 to tlSelCount-1 do (
										local loopNode = tlSel.item[a]
										case loopNode.imageIndex of (
											1 : (
												loopNode.setValue col ((dotNetClass "System.Drawing.Color").FromArgb newcolor.r newcolor.g newcolor.b)
											)
											2 : (
												loopNode.setValue col ((dotNetClass "System.Drawing.Color").FromArgb newcolor.r newcolor.g newcolor.b)
												if (hnd = getLayerHndByNode loopNode) != undefined do append layers (gabh hnd)
												
											)
											default : (
												loopNode.setValue col ((dotNetClass "System.Drawing.Color").FromArgb newcolor.r newcolor.g newcolor.b)
												if (hnd = getObjectHndByNode loopNode) != undefined do append objArr (gabh hnd)
											)
										)
									)
									tl.endUnboundLoad()
									tl.topVisibleNodeIndex = topNodeInd
									tl.endUpdate()
									tl.refresh() --Refresh UI asap to reflect changes, continue to change values in max
									for a in (layers + objArr) do a.wireColor = newcolor
									nestedLayerManager.handlersActive = true
								)
							)
							
							"Box" : (
								undo "Display as Box Change" on (
									local layers = #()
									local objArr = #()
									tl.beginUpdate()
									local topNodeInd = tl.topVisibleNodeIndex --Stop scrollbar from trying to move to focused Node.
									tl.beginUnboundLoad()
									nestedLayerManager.handlersActive = false
									for a=0 to tlSelCount-1 do (
										local loopNode = tlSel.item[a]
										local nextLoopNode = if a < tlSelCount-1 do tlSel.item[a+1]
										case loopNode.imageIndex of (
											1 : (
												loopNode.setValue col (not value)
												changeChildCellRecursive tl loopNode col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do (
													changeParentFolderCellRecursive tl loopNode col (not value)
												)
											)
											2 : (
												loopNode.setValue col (not value)
												if loopNode.parentNode != (if nextLoopNode != undefined do nextLoopNode.parentNode) do
													changeParentFolderCellRecursive tl loopNode col (not value)
												if (hnd = getLayerHndByNode loopNode) != undefined do append layers (gabh hnd)
											)
											default : (
												loopNode.setValue col (not value)
												if (hnd = getObjectHndByNode loopNode) != undefined do append objArr (gabh hnd)
											)
										)
									)
									tl.endUnboundLoad()
									tl.topVisibleNodeIndex = topNodeInd
									tl.endUpdate()
									tl.refresh() --Refresh UI asap to reflect changes, continue to change values in max
									for a in layers do a.boxMode = not value
									for a in objArr do if isValidNode a do a.boxMode = not value
									nestedLayerManager.handlersActive = true
								)
							)
							
						)
						
					)					
				)
				
				end = timeStamp()
				
				if nestedLayerManager.showLog do format ("[NLM] Mouse Click function completed in " + ((end-start) / 1000.00) as string + " seconds\n")
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > mouseDown tl event"
			)
			
		),
		
		--Mouse click mouse up function
		function mouseUp tl event = (
			
			try (
				
				--tl.selection does not change until mouseup, so selecting nodes if in the layers column only works here
				local hitInfo = tl.calcHitInfo event.location
				local getObjectHndByNode = nestedLayerManager.io.getObjectHndByNode
				local gabh = getAnimByHandle
				
				if event.button == event.button.left do (
					if hitInfo.column == tl.columns.item["Layers"] do (
						if tl.selection.count == nestedLayerManager.selectionCount do (
							tl.selection.set hitInfo.node
						)
						if nestedLayerManager.selectObjectsInScene do (
							
							selectArr = #()
							for a=0 to tl.selection.count-1 do (
								local loopNode = tl.selection.item[a]
								case loopNode.imageIndex of (
									0 : ()
									1 : ()
									2 : ()
									default : (
										if (hnd = getObjectHndByNode loopNode) != undefined do append selectArr (gabh hnd)
									)
								)
							)
							--Select function disables editor from working, only select objects if editor will not be shown
							if selectArr.count > 0 do (
								if selection[1] != selectArr[selectArr.count] do select selectArr
								nestedLayerManager.runSelObjFn = false  --Prevents callback from selecting everything in treelist
							)
						)
					)
					
					--If user clicks on nothing, deselect everything
					nestedLayerManager.selectionCount = tl.selection.count
					if (hitInfo.hitInfoType == hitInfo.hitInfoType.Empty) do (
						nestedLayerManager.ui.tl.selection.set undefined 
						nestedLayerManager.ui.tl.closeEditor()
						if nestedLayerManager.selectObjectsInScene do clearSelection()
					)
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > mouseUp tl event"
			)
			
		),
		
		function selectImageClick tl event = (
			
			try (
				case event.node.imageIndex of (
					0 : ()
					1 : ()
					2 : ( nestedLayerManager.ui.layerPropertiesDialog() )
					default : (
						local objHnd = nestedLayerManager.io.getObjectHndByNode event.node
						if objHnd != undefined do select (getAnimByHandle objHnd)
						max properties
					)
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > selectImageClick tl event"
			)
			
		),
		
		--Set drag node icon
		function dragNodeIcons tl event = (
			
			try (
				
				event.imageIndex = -1
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > dragNodeIcons tl event"
			)
			
		),
		
		--Node drag (Stop nodes from moving to incorrect parents)
		function nodeDrag tl event = (
			
			try (
				
				--local varialbes
				local dragDropEffects = dotNetClass "System.Windows.Forms.DragDropEffects" --properties are all, copy, link, move, none, scroll
				local dropNode = nestedLayerManager.treeEvents.nodeUnderMouse tl
				local dragNode = tl.selection.item[0] --If nothing is selected, focusedNode is not set so drop fails. Set focus node here.
				local effect
				
				if dragNode != undefined and dropNode != undefined then (
					
					--Set focused node if it is undefined
					if tl.focusedNode == undefined do tl.focusedNode = dragNode
					
					--Stop root and layer 0 from being dragged
					for a=0 to tl.selection.count-1 do (
						itemName = tl.selection.item[a].item[0]
						if itemName == "0" or itemName == "Root:" do effect = dragDropEffects.none
						
						--Prevent drop if more than one type of node is selected (only folders, layers or objects can be dragged at one time)
						--Root is index 0, Folder is index 1, Layer is index 2, Object is index 3 - 8
						local x = tl.selection.item[0].imageIndex
						local y = tl.selection.item[a].imageIndex
						
						case x of (
							
							1 : if x != y do effect = dragDropEffects.none
							2 : if x != y do effect = dragDropEffects.none
							default : case y of (
								1 : dragDropEffects.none
								2 : dragDropEffects.none
							)
							
						)
						
					)
					
					--Prevent drop during certain conditions (folders only in folders or root, layers only in folders, objects only in layers)
					if effect != dragDropEffects.none do (
						
						case dragNode.imageIndex of (
							
							1 : case dropNode.imageIndex of (
								
								0 : effect = dragDropEffects.move
								1 : effect = dragDropEffects.move
								2 : effect = dragDropEffects.move
								default : effect = dragDropEffects.none
								
							)
							
							2 : case dropNode.imageIndex of (
								
								0 : effect = dragDropEffects.move
								1 : effect = dragDropEffects.move
								2 : effect = dragDropEffects.move
								default : effect = dragDropEffects.none
								
							)
							
							default : case dropNode.imageIndex of (
								
								0 : effect = dragDropEffects.none
								1 : effect = dragDropEffects.none
								2 : effect = dragDropEffects.move
								default : effect = dragDropEffects.move
								
							)
							
						)
						
					)
				)
				else (
					effect = dragDropEffects.none
				)
				
				--Finally after all the checks, supply true or false variable to event
				event.effect = effect
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > nodeDrag tl event"
			)
			
		),
		
		--Find node under mouse on node drop, move nodes to new parent
		function moveDropNodes tl event = (
			
			try (
				
				start = timeStamp()
				
				--First, cancel the single node drop event (Even though autoChangeParent is set to false, the drop event still needs to be cancelled. Yeah... er ok)
				dragDropEffects = dotNetClass "System.Windows.Forms.DragDropEffects" --all, copy, link, move, none, scroll
				event.effect = dragDropEffects.none
				
				--Second, move all selected nodes to drop location
				local dragNode = tl.focusedNode
				local dropNode = nestedLayerManager.treeEvents.nodeUnderMouse tl
				
				--Check that dragNode and dropNode are defined
				if dragNode != undefined and dropNode != undefined do (
					
					local dropNodeIi = dropNode.imageIndex
					local dropNodePn = dropNode.parentNode
					local dragNodeIi = dragNode.imageIndex
					local dragNodePn = dragNode.parentNode
					
					--Dropnode changes depending on dragnode and dropnode conditions
					case dragNode.imageIndex of (
						
						1 : if dropNodeIi == 2 do dropNode = dropNodePn
						2 : if dropNodeIi == 2 do dropNode = dropNodePn
						default : ( 
							case dropNodeIi of (
								1 : ()
								2 : ()
								default : dropNode = dropNodePn
							)
						)
						
					)
					
					--Start UI Update
					tl.beginUnboundLoad()
					
					--Move nodes to new dropnode parent
					local moveNodes = true
					
					--Move nodes to new directory
					undo "Move Nodes" on (
						for a=tl.selection.count-1 to 0 by -1 do (
							
							local dragNode = tl.selection.item[a]
							local allowMove = true
							local mergeNode
							
							if dragNode.parentNode != dropNode do ( --don't do anything if the dragnode is already a child of the dropnode
								
								--Check if dropnode child contains any folders with the same name as drag node folders
								if dragNode.imageIndex == 1 do (
									for b=0 to dropNode.nodes.count-1 do (
										dropNodeChild = dropNode.nodes.item[b]
										if dropNodeChild.imageIndex == 1 do (
											if dropNodeChild.item["Layers"] != dropNode.item["Layers"] do (
												if dropNodeChild.item["Layers"] == dragNode.item["Layers"] then (
													allowMove = false
													mergeNode = dropNodeChild
												)
											)
										)
									)
								)
								
								if allowMove then (
									tl.moveNode dragNode dropNode
								)
								else (
									--Obtain unique new name for folder
									folInd = 1
									reLoop = true
									while reLoop do (
										for b=0 to dropNode.nodes.count-1 do (
											if dropNode.nodes.item[b].item["Layers"] == (dragNode.item["Layers"] + " (" + folInd as string + ")") then (
												folInd += 1
											) else (
												if b == dropNode.nodes.count-1 do (
													reLoop = false
												)
											)
										)
									)
									newFolderNameUnique = (dragNode.item["Layers"] + " (" + folInd as string + ")")
									--Query user on options
									case (yesNoCancelBox ("This destination already contains a folder named '" + mergeNode.item["Layers"] + "'.\n\nWould you like to merge the folder contents, or rename the folder being moved to '" + newFolderNameUnique +"'?\n\nYes will merge the two folders. No will rename the folder.") title:"Nested Layer Manager") of (
										#Yes : (
											for b=dragNode.nodes.count-1 to 0 by -1 do (
												tl.moveNode dragNode.nodes.item[b] mergeNode
											)
											for b=1 to nestedLayerManager.folderNodes.count do (
												if dragNode == nestedLayerManager.folderNodes[b] do (
													deleteItem nestedLayerManager.folderNodes b
												)
											)
											tl.deleteNode dragNode
										)
										#No : (											
											
											dragNode.setValue "Layers" newFolderNameUnique
											tl.moveNode dragNode dropNode
										)
									)
								)
							)
						)
						
						--Link to main functions, move any objects to reflect changes in UI
						if dragNode.imageIndex >= 3 and dragNode.imageIndex <=8 do (
							nestedLayerManager.treeEvents.moveObjectsNewLayer tl dropNode
						)
						
					)
					
					--Recursively work through treelist and find correct folder icon states
					nestedLayerManager.io.setFolderStates()
					
					--Resume UI
					tl.endUnboundLoad()
					
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Drop Node Event Completed in % Seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > moveDropNodes tl event"
			)
			
		),
		
		--Disable label edit of layer zero and root
		--Disable accelerators for correct key entry
		function showingEditor tl event = (
			
			try (
				
				case tl.focusedNode.item["Layers"] of (
					"0" : event.cancel = true
					"Root:" : event.cancel = true
				)
				
				if event.cancel != true do enableaccelerators = false
				
			) catch (
				enableaccelerators = true
				nestedLayerManager.error.scriptError message:"treeEvents.ms > disableEditorLayer0 tl event"
			)
			
		),
		
		--Parse text after label edit complete. If layer name exists then fail, if folder name exists in dir then fail.
		function validatingEditor tl event = (
			
			try (
				
				local newName = event.value
			
				case tl.focusedNode.imageIndex of (
					
					1 : (
						if newName != "" then (
							event.value = nestedLayerManager.treeEvents.removeIllegalCharacters newName
							event.errorText = "A folder with that name already exists in this directory."
							for a=0 to tl.focusedNode.parentNode.nodes.count-1 do (
								loopNode = tl.focusedNode.parentNode.nodes.item[a]
								if loopNode != tl.focusedNode do (
									if loopNode.imageIndex ==1 and loopNode.item["Layers"] == newName do event.valid = false
								)
							)
						) else (
							event.ErrorText = "An empty folder name is not allowed."
							event.valid = false
						)
					)
					
					2 : (
						if newName != "" then (
							
							event.ErrorText = "A layer with that name already exists."
							
							--Max layer rename function does not allow a layer to be renamed if it is same with different case :/
							--This fix resolves the issue by renaming the layer with _  as suffix, then back to desired name.
							layerHnd = nestedLayerManager.io.getLayerHndByNode tl.focusedNode
							if layerHnd != undefined do (
								layer = getAnimByHandle layerHnd
								if layer.name != newName and layer.name as name == newName as name then (
									layer.setName (newName + "_")
									event.valid = layer.setName newName
								) else (
									event.valid = layer.setName newName
								)
							)
							
						) else (
							event.ErrorText = "An empty layer name is not allowed."
							event.valid = false
						)
					)
					
					3 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					4 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					5 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					6 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					7 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					8 : if (hnd = nestedLayerManager.io.getObjectHndByNode tl.focusedNode) != undefined do (getAnimByHandle hnd).name = newName
					
				)
				
				if event.valid do enableaccelerators = true
				
			) catch (
				enableaccelerators = true
				nestedLayerManager.error.scriptError message:"treeEvents.ms > nodeNameEdit tl event"
			)
				
		),
		
		function editorKeyUp tl event = (
			try (
				dnKeys = dotNetClass "System.Windows.Forms.Keys"
				case event.keyCode of (
					(dnKeys.enter) : tl.postEditor()
					(dnKeys.escape) : tl.cancelCurrentEdit()
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > editorKeyUp tl event()"
			)
		),
			
		--Disable some of the icons for certain types of node.
		function customDrawCells tl event = (
				
			try (
					
				case event.node.imageIndex of (
					0 : if event.column.caption != "Layers" do event.handled = true
					1 : ()
					2 : ()
					default : if event.column.caption == "Current" do event.handled = true
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > customDrawCells tl event"
			)
			
		),
		
		--Expand all children recursively
		--Try/Catch not used as this recursive function is always called inside other functions
		function expandChildrenRecursive node = (
			
			if node.imageIndex == 1 do (
				node.expanded = true
				for a=0 to node.nodes.count-1 do nestedLayerManager.treeEvents.expandChildrenRecursive node.nodes.item[a]
			)
			
		),
		
		--Expand all children when shift is being pressed
		function expandChildren tl event = (
			
			try (
				
				keyLog = dotNetClass "system.windows.forms.control"
				if keyLog.modifierKeys == keyLog.modifierKeys.shift do (
					nestedLayerManager.ui.tl.beginUpdate()
					nestedLayerManager.treeEvents.expandChildrenRecursive event.node
					nestedLayerManager.ui.tl.endUpdate()
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > expandChildren tl event"
			)
			
		),
		
		--Collapse all children recursively
		function collapseChildrenRecursive node = (
			
			node.expanded = false
			for a=0 to node.nodes.count-1 do nestedLayerManager.treeEvents.collapseChildrenRecursive node.nodes.item[a]
			
		),
		
		--Collapse all children when shift is being pressed
		--Try/Catch not used as this recursive function is always called inside other functions
		function collapseChildren tl event = (
			
			try (
				
				keyLog = dotNetClass "system.windows.forms.control"
				if keyLog.modifierKeys == keyLog.modifierKeys.shift do (
					nestedLayerManager.treeEvents.collapseChildrenRecursive event.node
				)
				
				tl.topVisibleNodeIndex = nestedLayerManager.topNodeIndex
				tl.endUpdate()
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > collapseChildren tl event"
			)
			
		),
		
		--Populate layer node with objects before it expands
		function populateObjectsExpand tl event = (
			
			try (
				
				if event.node.imageIndex == 2 do (
					start = timeStamp()
					layerHnd = nestedLayerManager.io.getLayerHndByNode event.node
					if layerHnd != undefined do (
						layer = getAnimByHandle layerHnd
						layer.nodes &objArr
						if objArr.count > 100 do setWaitCursor()
						topNodeInd = tl.topVisibleNodeIndex --For some reason unboundload makes tree lose scroll position
						tl.beginUpdate()
						tl.beginUnboundLoad()
						nestedLayerManager.io.addObjNodes tl objArr
						tl.endUnboundLoad()
						tl.topVisibleNodeIndex = topNodeInd
						tl.endUpdate()
					)
					end = timeStamp()
					if nestedLayerManager.showLog do format ("[NLM] Populate objects completed in " + (end-start) as string + "ms\n")
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > populateObjectsExpand tl event"
			)
			
		),
		
		--Remove layer node's objects after it collapses
		function removeObjectsCollapse tl event = (
			
			try (
				
				tl.beginUpdate()
				nestedLayerManager.topNodeIndex = tl.topVisibleNodeIndex
				
				if event.node.imageIndex == 2 do (
					start = timeStamp()
					
					local layerNode = event.node
					local ghba = getHandleByAnim
					local getObjectHndHt = nestedLayerManager.io.getObjectHndHt
					local getObjectNodeHt = nestedLayerManager.io.getObjectNodeHt
					local getObjectHndByNode = nestedLayerManager.io.getObjectHndByNode
					
					tl.beginUnboundLoad()
					for a=layerNode.nodes.count-1 to 0 by -1 do (
						local objNode = layerNode.nodes.item[a]
						local objHnd = getObjectHndByNode objNode
						getObjectHndHt.remove objNode
						getObjectNodeHt.remove objHnd
						if focusedNode == objNode do tl.focusedNode = layerNode
						tl.deleteNode objNode
					)
					layerNode.hasChildren = true
					tl.endUnboundLoad()
					
					end = timeStamp()
					if nestedLayerManager.showLog do format ("[NLM] Remove objects completed in " + (end-start) as string + "ms\n")
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > removeObjectsCollapse tl event"
			)
			
		),
		
		---------------------------------------------------------
		-- INITIALISE / REMOVE EVENTS
		---------------------------------------------------------
		
		function initialiseEvents = (
			
			try (
				
				--Declare shortcuts to ui		
				local tl = nestedLayerManager.ui.tl
				
				--Initialise treelist event handlers
				dotNet.addEventHandler tl "mouseDown" mouseDown
				dotNet.addEventHandler tl "mouseUp" mouseUp
				dotNet.addEventHandler tl "CalcNodeDragImageIndex" dragNodeIcons
				dotNet.addEventHandler tl "DragOver" nodeDrag
				dotNet.addEventHandler tl "DragDrop" moveDropNodes
				dotNet.addEventHandler tl "ShowingEditor" showingEditor
				dotNet.addEventHandler tl "validatingEditor" validatingEditor
				dotNet.addEventHandler tl "EditorKeyUp" EditorKeyUp
				dotNet.addEventHandler tl "CustomDrawNodeCell" customDrawCells
				dotNet.addEventHandler tl "AfterExpand" expandChildren
				dotNet.addEventHandler tl "AfterCollapse" collapseChildren
				dotNet.addEventHandler tl "AfterExpand" populateObjectsExpand
				dotNet.addEventHandler tl "BeforeCollapse" removeObjectsCollapse
				dotNet.addEventHandler tl "SelectImageClick" selectImageClick
				
				if nestedLayerManager.showLog do format "[NLM] Tree Events Added\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > initialiseEvents()"
			)
			
		),
		
		--Remove event handlers
		function removeEvents = (
			
			try (
				
				local tl = nestedLayerManager.ui.tl
				dotNet.removeAllEventHandlers tl
				
				if nestedLayerManager.showLog do format "[NLM] Tree Events Removed\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"treeEvents.ms > removeEvents()"
			)
			
		)
		
	)
	
	nestedLayerManager.treeEvents = nestedLayerManagerTreeEventsStruct()
	
)