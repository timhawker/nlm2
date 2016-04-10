--Nested Layer Manager Button Functions Struct. All functions for buttons and right click menu.
(
	
	--Local values used throughout struct
	local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
	
	--Button Functions Struct
	struct nestedLayerManagerButtonFunctionsStruct (
		
		---------------------------------------------------------
		-- BUTTON AND RIGHT CLICK FUNCTIONS
		---------------------------------------------------------
		
		--Create layer button
		function createLayer addSel:true = (
			
			try (
				
				--Button press true, used to determine difference between callback and button press. If button press the layer will be created within a selected folder, if callback it will be created in root.
				nestedLayerManager.buttonPress = true
				nestedLayerManager.addSelToLayer = addSel
				
				--Create layer (Callback is fired immediately, layer is created in NLM)
				layerManager.newLayer()
				
				nestedLayerManager.buttonPress = false
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > createLayer()"
			)
			
		),
			
		--On folder creation, find unique name for new folder.
		function folderUniqueName = (
				
			try (
				
				folderNames = for a=1 to nestedLayerManager.folderNodes.count collect (nestedLayerManager.folderNodes[a].item["Layers"])
				folderIndex = 1
				unique = false
				
				for i in folderNames while unique == false do (
					if findItem folderNames ("Folder "+folderIndex as string) !=0 then (
						folderIndex += 1
					)
					else unique = true
				)
				
				--Return
				"Folder "+folderIndex as string
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > folderUniqueName()"
			)
			
		),
		
		--Create folder function
		function createFolder = (
			
			try (
					
				--Button press true, used to move folder into whatever node is selected
				nestedLayerManager.buttonPress = true
				
				--Assign shortcuts
				tl = nestedLayerManager.ui.tl
				local parentNodeID = 0
				if nestedLayerManager.buttonPress do (
					if tl.focusedNode != undefined do (
						case tl.focusedNode.imageIndex of (
							1: parentNodeID = tl.focusedNode.id
							2: parentNodeID = tl.focusedNode.parentNode.id
						)
					)
				)
				
				--Create folder node
				--Array contains #(name, current, visible, freeze, render, color, parentID, imageIndex, selectImageIndex)
				nodeName = nestedLayerManager.buttonFunctions.folderUniqueName()
				col = (dotNetClass "System.Drawing.Color").FromArgb (random 0 255) (random 0 255) (random 0 255)
				folderNode = nestedLayerManager.io.createFolderNode tl nodeName col parentNodeID
				
				--Select folder node and deselect everything else
				for a = tl.selection.count-1 to 0 by -1 do tl.selection.item[a].selected = false
				folderNode.selected = true
				tl.focusedNode = folderNode
				
				--Show editor for instant editing
				nestedLayerManager.ui.tl.showEditor()
				
				--Button press false
				nestedLayerManager.buttonPress = false
				
				if nestedLayerManager.showLog do format "[NLM] Folder Create Event Triggered\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > createFolder()"
			)
			
		),
		
		--Function used to determine if any selected layers to be delted have objects in them. If true, a yes no cancel box will be shown.
		--Try/Catch not required as this function is referenced by deleteNodes function
		function needQueryCheck theNode = (
			case theNode.imageIndex of (
				1 : for a=0 to theNode.nodes.count-1 do needQueryCheck theNode.nodes.item[a]
				2 : if theNode.hasChildren do nestedLayerManager.deleteQuery = true
				default :  nestedLayerManager.deleteQuery = true
			)
		),
		
		--Delete object node
		--Try/Catch not required as this function is referenced by deleteNodes function
		function deleteObjectNodes tl node = (
			
			if node.imageIndex > 2 do (
				objHnd = nestedLayerManager.io.getObjectHndByNode node
				if objHnd != undefined do (
					obj = getAnimByHandle objHnd
					if obj != undefined do (
						if not (isDeleted obj) do (
							nestedLayerManager.io.getObjectHndHt.remove node
							nestedLayerManager.io.getObjectNodeHt.remove objHnd
							delete obj
							tl.deleteNode node
						)
					)
				)
			)
			
			for a=node.nodes.count-1 to 0 by -1 do deleteObjectNodes tl node.nodes.item[a]
				
		),
		
		--Delete layer node
		--Try/Catch not required as this function is referenced by deleteNodes function
		function deleteLayerNodes tl node = (
			
			if node.imageIndex == 2 do (
				--Find Layer
				local layerHnd = nestedLayerManager.io.getLayerHndByNode node
				if layerHnd != undefined do (
					local layer = (getAnimByHandle layerHnd)
					--Make layer 0 current if layer is current
					if layer.current do (
						layer0 = (layerManager.getLayer 0).layerAsRefTarg
						layer0Node = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer0)
						nestedLayerManager.treeEvents.changeCurrentLayer tl layer0Node
					)
					--Delete nodes in layer if any are present
					layer.nodes &layerNodes
					delete layerNodes
					--Delete layer and treelist node
					nestedLayerManager.io.getLayerHndHt.remove node
					nestedLayerManager.io.getLayerNodeHt.remove layerHnd
					layerManager.deleteLayerByName layer.name
					tl.deleteNode node
				)
			)
			
			for a=node.nodes.count-1 to 0 by -1 do deleteLayerNodes tl node.nodes.item[a]
				
		),
		
		--Delete folder node
		--Try/Catch not required as this function is referenced by deleteNodes function
		function deleteFolderNodes tl node = (
			
			for a=node.nodes.count-1 to 0 by -1 do deleteFolderNodes tl node.nodes.item[a]
			
			if node.imageIndex == 1 do (
				found = false
				for a=nestedLayerManager.folderNodes.count to 1 by -1 where nestedLayerManager.folderNodes[a] == node while not found do (
					deleteItem nestedLayerManager.folderNodes a
					tl.deleteNode node
					found = true
				)
			)
			
		),
		
		--Delete nodes function from button press
		function deleteNodes = (
			
			try (
			
				local tl = nestedLayerManager.ui.tl
				local allowDelete = true
				local queryAnswer = true
				
				for a=0 to tl.selection.count-1 do (
					nestedLayerManager.buttonFunctions.needQueryCheck tl.selection.item[a]
					case tl.selection.item[a].item["Layers"] of (
						"0" : allowDelete = false
						"Root:" : allowDelete = false
					)
				)
				
				if allowDelete do (
					
					if nestedLayerManager.deleteQuery do (
						queryAnswer = queryBox "Are you sure you want to delete the selected nodes?\nSome objects will be deleted from the scene if you press yes." title:"Nested Layer Manager"
					)
					
					if queryAnswer do (
						
						nodes = for a=0 to tl.selection.count-1 collect tl.selection.item[a]
						
						tl.beginUnboundLoad()
						
						--Delete object nodes, then layer nodes, then folder nodes (seperated to avoid errors)
						for a in nodes do nestedLayerManager.buttonFunctions.deleteObjectNodes tl a
						for a in nodes do nestedLayerManager.buttonFunctions.deleteLayerNodes tl a
						for a in nodes do nestedLayerManager.buttonFunctions.deleteFolderNodes tl a
						
						--Recursively work through treelist and find correct folder icon states
						nestedLayerManager.io.setFolderStates()
						
						tl.endUnboundLoad()
						
					)
					
				)
				
				nestedLayerManager.deleteQuery = false
				
				if nestedLayerManager.showLog do format "[NLM] Delete Nodes Event Triggered\n"
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > deleteNodes()"
			)
			
		),
		
		--Add objects to layer button. Moves any selected objects to the selected layer.
		function addObjectsToLayer = (
			
			try (
				
				if nestedLayerManager.ui.tl.selection.count == 1 then (
					
					selNode = nestedLayerManager.ui.tl.selection.item[0]
					if selNode.imageIndex == 2 then (
						local layer =  getAnimByHandle (nestedLayerManager.io.getLayerHndByNode selNode)
						for a in selection do layer.addNode a
							
					)
					else (
						messageBox "Please ensure a layer is selected" title:"Nested Layer Manager"
					)
				)
				else (
					messageBox "Please ensure one layer is selected." title:"Nested Layer Manager"
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > addObjectsToLayer()"
			)
			
		),
		
		--Which layers selected objects button function
		function SelLyrFdrOfSelObj = (
			
			try (
				
				tl = nestedLayerManager.ui.tl
				tl.beginUnboundLoad()
				
				for a = tl.selection.count-1 to 0 by -1 do tl.selection.item[a].selected = false
					
				for a in selection do (
					
					local layer = a.layer.layerAsRefTarg
					local layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer)
					
					if layerNode != undefined do (
						layerNode.selected = true
						tl.focusedNode = layerNode
					)
					
				)
				
				tl.endUnboundLoad()
				
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > SelLyrFdrOfSelObj()"
			)
			
		),
		
		--Recursive function used with which objects are in sel layers. 
		--Try/Catch not used as this is recursive and called many times. Always referenced by SelObjWiSelLyrFdr
		function SelObjWiSelLyrFdrRecursive theNode = (
			tl = nestedLayerManager.ui.tl
			case theNode.imageIndex of (
				1: for a=0 to theNode.nodes.count-1 do nestedLayerManager.buttonFunctions.SelObjWiSelLyrFdrRecursive theNode.nodes.item[a]
				2: (
					(getAnimByHandle (nestedLayerManager.io.getLayerHndByNode theNode)).nodes &objNodes
					for a in objNodes do selectMore a
				)
				3: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
				4: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
				5: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
				6: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
				7: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
				8: selectMore (getAnimByHandle (nestedLayerManager.io.getObjectHndByNode theNode))
			)
		),
		
		--Which objects are in selected layers button press function
		function SelObjWiSelLyrFdr = (
			
			try (
				
				clearSelection()
				tl = nestedLayerManager.ui.tl
				for a=0 to tl.selection.count-1 do (
					nestedLayerManager.buttonFunctions.SelObjWiSelLyrFdrRecursive tl.selection.item[a]
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > SelObjWiSelLyrFdr()"
			)
			
		),
		
		--Hide unhide all layers button press function
		function hideUnhideAll = (
			
			try (
				
				start = timeStamp()
				
				undo "Visibility Change" on (
					
					local layers = for a=0 to layerManager.count-1 collect (layerManager.getLayer a).layerAsRefTarg
					
					visible = false
					for a in layers while not visible do (
						if a.on do visible = true
					)
					
					if visible then (
						for a in layers do a.on = false
					)
					else (
						for a in layers do a.on = true
					)
					
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Hide/Unhide All Button Completed in % Seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > hideUnhideAll()"
			)
			
		),
		
		--Freeze unfreeze all button press function
		function freezeUnfreezeAll = (
			
			try (
				
				start = timeStamp()
				
				undo "Freeze State Change" on (
					
					local layers = for a=0 to layerManager.count-1 collect (layerManager.getLayer a).layerAsRefTarg
					
					frozen = false
					for a in layers while not frozen do (
						if a.isFrozen do frozen = true
					)
					
					if frozen then (
						for a in layers do a.isFrozen = false
					)
					else (
						for a in layers do a.isFrozen = true
					)
					
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Freeze/Unfreeze All Button Completed in % Seconds\n" ((end-start)/1000.0)
				
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > freezeUnfreezeAll()"
			)
			
		),
		
		--Expand collapse all button press function
		function expandCollapseAll = (
			
			try (
				
				start = timeStamp()
				
				nestedLayerManager.ui.tl.beginUnboundLoad()
				
				local expanded = false
				local layerNodes = for a=0 to layerManager.count-1 collect nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim (layerManager.getLayer a).layerAsRefTarg)
				
				for a in (nestedLayerManager.folderNodes + layerNodes) while not expanded where a.expanded and a.hasChildren do (
					expanded = true
				)
				if expanded then (
					for a in (nestedLayerManager.folderNodes + layerNodes) do a.expanded = false
				)
				else (
					for a in nestedLayerManager.folderNodes do a.expanded = true
				)
				
				nestedLayerManager.ui.tl.endUnboundLoad()
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Expand/Collapse All Button Completed in % Seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > expandCollapseAll()"
			)
			
		),
		
		--Find unique name for duplicated layer
		function findDuplicateLayerName newlayerName = (
			
			try (
				
				--Initialse values
				layerIndex = 1
				unique = false
				
				--Loop through by number of layer counts, if unique name is found then exit
				for a=1 to layerManager.count-1 while unique == false do (
					if layerManager.getLayerFromName (newLayerName+layerIndex as string) != undefined then (
						layerIndex = a
					)
					else unique = true
				)
				
				--Return result
				newLayername+layerIndex as string
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > findDuplicateLayerName newlayerName index"
			)
			
		),
		
		--Duplicate Layer, Instance All Objects
		function duplicateLayer cloneType = (
			
			try (
			
				local tl = nestedLayerManager.ui.tl
				local node = tl.selection.item[0]
				
				if tl.selection.count == 1 then (
					
					if node.imageIndex == 2 then (
						
						local layer = getAnimByHandle (nestedLayerManager.io.getLayerHndByNode node)
						
						--Create new layer name						
						newLayerName = case cloneType of (
							"Instance" : layer.name + " - Instance "
							"Copy" : layer.name + " - Copy "
						)
						--Get new layer name with index number on end to make sure it is unique
						newUniqueLayer = nestedLayerManager.buttonFunctions.findDuplicateLayerName newlayerName
						newLayer = layerManager.newLayerFromName newUniqueLayer
						
						--Obtain array of nodes to copy/instance
						layer.nodes &nodes
						
						--Copy/instance nodes, move them to new layer and update nested layer manager interface
						local newNodes
						case cloneType of (
							"Instance" : maxOps.cloneNodes nodes cloneType:#instance newNodes:&newNodes
							"Copy" :  maxOps.cloneNodes nodes cloneType:#copy newNodes:&newNodes
						)
						for a in newNodes do (
							newLayer.addNode a
						)
						
						newLayerNode = nestedLayerManager.io.getNodeByLayerHnd (GetHandleByAnim newLayer.layerAsRefTarg)
						tl.moveNode newLayerNode node.parentNode
						
					)
					else (
						messageBox "Please ensure a layer is selected." title:"Nested Layer Manager"
					)
				)
				else (
					messageBox "Please ensure one layer is selected." title:"Nested Layer Manager"
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > duplicateLayer cloneType"
			)
			
		),
		
		--Move selected nodes to root
		function moveToRoot = (
			
			try (
			
				local tl = nestedLayerManager.ui.tl
				
				tl.beginUnboundLoad()
				
				--Move nodes to root
				for a=tl.selection.count-1 to 0 by -1 do (
					case tl.selection.item[a].imageIndex of (
						1 : tl.moveNode tl.selection.item[a] tl.nodes.item[0]
						2 : tl.moveNode tl.selection.item[a] tl.nodes.item[0]
						default : ()
					)
				)
				
				--Recursively work through treelist and find correct folder icon states
				nestedLayerManager.io.setFolderStates()
				
				tl.endUnboundLoad()
				
				if nestedLayerManager.showLog do format "[NLM] Move nodes function fired\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > moveToRoot()"
			)
			
		),
		
		--Remove all nested layer manager data from scene function
		function removeAllNestedData = (
		
			try (
				
				--Nested Layer Manager. Remove ALL data from scene.
				result = queryBox "This will remove ALL nested data from the currently loaded 3ds Max file and cannot be undone. \nAre you sure you would like to continue?" \
				title:"Nested Layer Manager"
				
				if result do (
					
					--Close window if open
					try (nestedLayerManager.close()) catch()
					
					--Remove custom attributes
					for a=rootNode.custAttributes.count to 1 by-1 do (
						if rootNode.custAttributes[a].name == "nestedLayerManager" do (
							deleteItem rootNode.custAttributes a
							format "[NLM] Custom Attributes Removed\n"
						)
					)
					
					--Remove callback
					callbacks.removeScripts id:#nestedLayerManagerPersistent
					format "[NLM] Callbacks Removed\n"
					
					--Result
					messageBox "All data has been removed and Nested Layer Manager has been closed.\nIf you open Nested Layer Manager, layer and folder data will be saved again."\
					title:"Nested Layer Manager"
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > removeAllNestedData()"
			)
		),
		
		--Settings button pressed
		function settings = (
			try (
				nestedLayerManager.ui.settings()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > settings()"
			)
		),
		
		--Information button pressed
		function information = (
			
			try (
				nestedLayerManager.ui.information()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"buttonFunctions.ms > information()"
			)
			
		),
		
		--Delete all empty layers in scene
		function deleteAllEmptyLayers = (
			
			try (
				
				if queryBox "Are you sure you want to delete all empty layers? This is not undoable." title:"Nested Layer Manager" do (
					
					for a=layerManager.count-1 to 1 by -1 do (
						layer = (layerManager.getLayer a)
						if layer.current do (layerManager.getLayer 0).current = true
						LayerManager.deleteLayerByName layer.name
					)
					
					nestedLayerManager.mfEvents.refreshTree()
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > deleteAllEmptyLayers()"
			)
			
		),
		
		--Delete all empty folders in scene
		function deleteAllEmptyFolders = (
			
			try (
				
				if queryBox "Are you sure you want to delete all empty folders? This is not undoable." title:"Nested Layer Manager" do (
					
					local folderNodes = nestedLayerManager.folderNodes
					local tl = nestedLayerManager.ui.tl
					
					function sortLevels v1 v2 = (
						local d = (v1.level)-(v2.level)
						case of (
							(d < 0.): 1
							(d > 0.): -1
							default: 0
						)
					)
					qsort folderNodes sortLevels
					
					local fNodesToDel = #()
					for a in folderNodes do (
						if not a.hasChildren do (
							append fNodesToDel a
							tl.deleteNode a
						)
					)
					
					for a in fNodesToDel do (
						deleteItem nestedLayerManager.folderNodes (findItem nestedLayerManager.folderNodes a)
					)
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > deleteAllEmptyFolders()"
			)
			
		),
		
		--Undock
		function undock = (
			try (
				if nestedLayerManager.showLog do format "[NLM] Undocking\n"
				nestedLayerManager.mfEvents.showMaxForm()
				nestedLayerManager.windowMode = #standard
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > undock()"
			)
		),
		
		--Dock to left
		function dockToLeft = (
			try (
				nestedLayerManager.ui.nlmDialog()
				cui.dockDialogBar nestedLayerManager.ui.nlmRoll #cui_dock_left
				nestedLayerManager.windowMode = #dock_left
				if nestedLayerManager.showLog do format "[NLM] Docking to Left\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > dockToLeft()"
			)
		),
		
		--Dock to right
		function dockToRight = (
			try (
				nestedLayerManager.ui.nlmDialog()
				cui.dockDialogBar nestedLayerManager.ui.nlmRoll #cui_dock_right
				nestedLayerManager.windowMode = #dock_right
				if nestedLayerManager.showLog do format "[NLM] Docking to Right\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > dockToRight()"
			)
		),
		
		--Save folder hierarchy into layer name
		function saveFolderIntoLayerName = (
			try (
				for a=1 to layerManager.count-1 do (
					layer = (layerManager.getLayer a).layerAsRefTarg
					layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer)
					layerName = layer.name
					parentNode = layernode.parentNode
					while parentNode.level > 0 do (
						layerName = append (parentNode.item[0] + " | ") layerName
						parentNode = parentNode.parentNode
					)
					print layerName
					layer.setName layerName
				)
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > saveFolderIntoLayerName()"
			)
		)
		
	)--End Struct
	
	nestedLayerManager.buttonFunctions = nestedLayerManagerButtonFunctionsStruct()
	
)