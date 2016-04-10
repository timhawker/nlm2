--Nested Layer Manager IO Functions
(
	--Local io.ms values used in multiple functions
	local folderNodeDirs = #()
	local folderNodeIds = #()

	--IO Struct
	struct nestedLayerManagerGTStruct (
		
		-------------------------------------------------------------------------
		-- HASH TABLE DATABASE (Used to tie objects and tree nodes)
		-------------------------------------------------------------------------
		
		--Options were to use anim handle or dotNetMXSValue. Both are extremely quick, but anim handle avoids deleted nodes being kept in memory as reference.
		
		--getLayerHndHt stores #(treeNode, layer handle)
		getLayerHndHt = dotNetObject "System.Collections.HashTable",
		function getLayerHndByNode node = (
			if node != undefined do (
				getLayerHndHt.item[node]
			)
		),
		function setLayerHndByNode layerNode layerHnd = (
			if getLayerHndHt.item[layerNode] == undefined do (
				getLayerHndHt.add layerNode layerHnd
			)
		),
		
		--getLayerNodeHt stores #(layer handle, treeNode)
		getLayerNodeHt = dotNetObject "System.Collections.HashTable",
		function getNodeByLayerHnd layer = (
			if layer != undefined do (
				getLayerNodeHt.item[layer]
			)
		),
		function setNodeByLayerHnd layerHnd layerNode = (
			if getLayerNodeHt.item[layerHnd] == undefined do (
				getLayerNodeHt.add layerHnd layerNode
			)
		),
		
		--getObjectHndHt stores #(treeNode, object handle)
		getObjectHndHt = dotNetObject "System.Collections.HashTable",
		function getObjectHndByNode node = (
			getObjectHndHt.item[node]
		),
		function setObjectHndByNode objectNode objectHnd = (
			if getObjectHndHt.item[objectNode] == undefined do (
				getObjectHndHt.add objectNode objectHnd
			)
		),
		
		--getObjectNodeHt stores #(object handle, treeNode)
		getObjectNodeHt = dotNetObject "System.Collections.HashTable",
		function getNodeByObjectHnd obj = (
			getObjectNodeHt.item[obj]
		),
		function setNodeByObjectHnd objectHnd objectNode = (
			if getObjectNodeHt.item[objectHnd] == undefined do (
				getObjectNodeHt.add objectHnd objectNode
			) 
		),
		
		-------------------------------------------------------------------------
		-- SET UP CUSTOM ATTRIBUTES FOR PERSISTENT SAVING
		-------------------------------------------------------------------------
		
		--Initialise rootNode
		function initRN = (
			
			try (
				
				if not (isProperty rootNode #nestedLayerManager) do (
					nestedLayerManagerRootNode = attributes "nestedLayerManager" (
						parameters main (
							folderDirs type:#StringTab tabSizeVariable:true	animatable:false
							foldercolours type:#ColorTab tabSizeVariable:true animatable:false
							layerDirs type:#StringTab tabSizeVariable:true	animatable:false
							layerRefs type:#MaxObjectTab tabSizeVariable:true animatable:false
							dataVersion type:#Float animatable:false
						)
						
						function cleanLayerCA = (
							try (
								layerRefs = rootNode.nestedLayerManager.layerRefs
								layerDirs = rootNode.nestedLayerManager.layerDirs
								layers = for a=0 to layerManager.count-1 collect (layerManager.getLayer a).layerAsRefTarg
								for a=layerRefs.count to 1 by -1 do (
									if findItem layers layerRefs[a] == 0 do (
										deleteItem layerRefs a
										deleteItem layerDirs a
									)
								)
								rootNode.nestedLayerManager.layerRefs = layerRefs
								rootNode.nestedLayerManager.layerDirs = layerDirs
								if isProperty nestedLayerManager "showLog" do (
									if nestedLayerManager.showLog == true do (
										format "[NLM] Undefined Layer Refs Removed\n"
									)
								)
								true
							) catch(false)
						)
						
					)
					custAttributes.add rootNode nestedLayerManagerRootNode
				)
				if nestedLayerManager.showLog do format "[NLM] Init NLM Custom Attributes\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > initRN()"
			)
			
		),
		
		
		
		-------------------------------------------------------------------------
		-- LOAD NESTED LAYER MANAGER DATA ON OPEN
		-------------------------------------------------------------------------
		
		function open = (
			
			try (
				
				local showDialog = true
				
				if nestedLayerManager.windowOpen then (
					nestedLayerManager.ui.mf.focus()
					if nestedLayerManager.ui.nlmRoll != undefined do setFocus nestedLayerManager.ui.nlmRoll
				)
				else (
					
					--Ensure that NLM is definetely closed.
					try (
						if nestedLayerManager.windowOpen do nestedLayerManager.close()
					) catch ()
					
					--Timestamp for debugging/optimisation
					start = timestamp()
					
					local tl = nestedLayerManager.ui.tl
					
					--Check that nested data in 3ds max file is compatible with currently installed NLM
					if (isProperty rootNode #nestedLayerManager) do (
						if rootNode.nestedLayerManager.dataVersion > nestedLayerManager.dataVersion() do (
							allowOpen = false
							messageBox "Nested Layer Manager Data saved in this 3ds Max file was created with a newer version of Nested Layer Manager and is not compatible. Please update Nested Layer Manager to the latest version." title:"Nested Layer Manager"
						)
					)

					--Create loading dialogBar
					if showDialog do nestedLayerManager.ui.progressDialog()
					
					--Clear all previous data if present
					nestedLayerManager.io.clearAllNodeData
					
					--Local ui shortcuts
					tl = nestedLayerManager.ui.tl
					
					--Fill in treelist
					tl.beginUnboundLoad()
					nestedLayerManager.io.initRN() 							; if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 10
					nestedLayerManager.io.buildTreeNodes tl 				; if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 30
					nestedLayerManager.io.setLayerExpandState tl 	; if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 50
					nestedLayerManager.io.setFolderStates()				; if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 70
					nestedLayerManager.treeEvents.sortColumn "Layers" ascending
					tl.endUnboundLoad()
					nestedLayerManager.ui.tl.nodes.item[0].expanded = true
					if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 80
					
					--Initialise Events and callbacks
					nestedLayerManager.io.addAllEventHandlersAndCallbacks()
					if showDialog do nestedLayerManager.ui.progressRoll.percent.value = 100
					
					--Stop rootNode from being focused on load
					tl.focusedNode = undefined
					tl.selection.set undefined
					
					--Load maxform
					case nestedLayerManager.windowMode of (
						#standard : nestedLayerManager.mfEvents.showMaxForm()
						#dock_left : nestedLayerManager.buttonFunctions.dockToLeft()
						#dock_right : nestedLayerManager.buttonFunctions.dockToRight()
						default : nestedLayerManager.mfEvents.showMaxForm()
					)
					
					--Set window open value to true in struct
					nestedLayerManager.windowOpen = true
						
					--Close loading window
					if showDialog do destroyDialog nestedLayerManager.ui.progressRoll
					
					updateToolBarButtons()
					tl.focus()
					
					finish = timestamp()
					if nestedLayerManager.showLog do format ("[NLM] Loaded in " + ((finish - start) / 1000.0) as string + " Seconds\n")	
				)
				
				--Return true
				true
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"maxFormEvents.ms > open()" reOpen:false
			)
			
		),
		
		--Load function loads all nodes into treelist and sets all values correctly
		function buildTreeNodes tl = (
			
			try (
				
				--Create root node
				--Append node method #(layers, current, visible, freeze, render, color, box) parentID imageIndex selectImageIndex stateImageIndex
				tl.appendNode #("Root:", false, false, false, false, false, false) 0 0 0 -1
				
				--Build folder and layer rows in datatable (objects are created for each layer)
				nestedLayerManager.io.buildFolderNodes tl
				nestedLayerManager.io.buildLayerNodes tl
				
				if nestedLayerManager.showLog do format "[NLM] Build Tree Nodes Completed\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > load tl"
			)
			
		),
		
		--Build folder nodes into treelist on load
		function buildFolderNodes tl = (
			
			try (
			
				start = timeStamp()
				
				--Obtain info from rootNode
				local folderDirs = rootNode.nestedLayerManager.folderDirs
				local foldercolors = rootNode.nestedLayerManager.folderColours
				
				--Clear arrays and set local values
				folderNodeDirs = #()
				folderNodeIds = #()
				local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
				
				--Loop through saved folder data call a recursive function
				for a=1 to folderDirs.count do (
					
					local dir = folderDirs[a]
					local dirArr = filterstring dir "\\"
					local parentId = tl.nodes.item[0].id
					
					for b=1 to dirArr.count do (
						folderDir = stringStream ""
						for c=1 to b do format (dirArr[c]+"\\") to:folderDir
						folderDir = folderDir as string
						if (index = findItem folderNodeDirs folderDir) == 0 then (
							c = foldercolors[a]
							--Append node method #(layers, current, visible, freeze, render, color, box) parentID imageIndex selectImageIndex stateImageIndex
							folderNode = tl.appendNode #(dirArr[b], false, false, false, false, (dnCol c.r c.g c.b), false) parentId 1 1 -1
							parentId = folderNode.id
							append folderNodeDirs folderDir
							append folderNodeIds parentId
							append nestedLayerManager.folderNodes folderNode
						) else (
							parentId = folderNodeIds[index]
						)
					)				
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Build folder nodes completed in % seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > buildFolderNodes tl"
			)
			
		),
		
		--Build layer nodes into treelist on load
		function buildLayerNodes tl = (
			
			try (
			
				start = timeStamp()
				
				--Define local variables
				local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
				local getLayerNodeHt = nestedLayerManager.io.getLayerNodeHt
				local getLayerHndHt = nestedLayerManager.io.getLayerHndHt
				local setLayerHndByNode = nestedLayerManager.io.setLayerHndByNode
				local setNodeByLayerHnd = nestedLayerManager.io.setNodeByLayerHnd
				
				--Obtain saved info from rootNode
				local layerDirs = rootNode.nestedLayerManager.layerDirs
				local layerRefs = rootNode.nestedLayerManager.layerRefs
				
				--Add any layers currently in scene but not in saved layerRefs array. LayerDirs will return undefined, and as a result of findItem returning 0 they will be added to the root.
				for a in (for b=0 to layerManager.count-1 collect (layerManager.getLayer b).layerAsRefTarg) do appendIfUnique layerRefs a
				
				for a=1 to layerRefs.count do (
					
					local layer = layerRefs[a]
					local layerHnd = getHandleByAnim layer
					local index = findItem folderNodeDirs layerDirs[a]
					local parentId = if index == 0 then tl.nodes.item[0].id else folderNodeIds[index]
					local c = layer.wireColor
					--Append node method #(layers, current, visible, freeze, render, color, box) parentID imageIndex selectImageIndex stateImageIndex
					local layerNode = tl.appendNode #(layer.name, layer.current, layer.on, layer.isFrozen, layer.renderable, (dnCol c.r c.g c.b), layer.boxMode) parentId 2 2 -1
					if layer.current do nestedLayerManager.currentLayerNode = layerNode
					setNodeByLayerHnd layerHnd layerNode
					setLayerHndByNode layerNode layerHnd
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Build layer nodes completed in % seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > buildLayerNodes tl"
			)
		),
		
		
		-------------------------------------------------------------------------
		-- ADD NODES TO TREELIST 
		-------------------------------------------------------------------------
		
		function createLayerNode tl layer parentNode = (
			
			try (
			
				--Define local variables
				local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
				local getLayerNodeHt = nestedLayerManager.io.getLayerNodeHt
				local getLayerHndHt = nestedLayerManager.io.getLayerHndHt
				local setLayerHndByNode = nestedLayerManager.io.setLayerHndByNode
				local setNodeByLayerHnd = nestedLayerManager.io.setNodeByLayerHnd
				local layerNode
				
				--Add layer nodes
				local layerHnd = getHandleByAnim layer
				local c = layer.wireColor
				--Append node method #(layers, current, visible, freeze, render, color, box) parentID imageIndex selectImageIndex stateImageIndex
				layerNode = tl.appendNode #(layer.name, layer.current, layer.on, layer.isFrozen, layer.renderable, (dnCol c.r c.g c.b), layer.boxMode) parentNode 2 2 -1
				setNodeByLayerHnd layerHnd layerNode
				setLayerHndByNode layerNode layerHnd
				
				if nestedLayerManager.showLog do format "[NLM] Creating Layer Node\n"
				
				--Return last layer node created
				layerNode
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > createLayerNode tl layer parentNode"
			)
			
		),
		
		function createLayerInDir layerName dir = (
			
			try (
			
				if classOf layerName == string and classOf dir == string and layerName != "" then (
					
					--Create layer, if layer exists then return false, else continue
					local layer = layerManager.newLayerFromName layerName
					
					if  layer != undefined then (
						
						--Local values
						local tl = nestedLayerManager.ui.tl
						local node = tl.nodes.item[0]
						local fArr = filterString dir "/\\"
						local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
						
						--Build folders
						for level = 1 to fArr.count do (
							local notFound = true
							local fNode = undefined
							for a=0 to node.nodes.count-1 while notFound do (
								if node.nodes.item[a].imageIndex == 1 do (
									if node.nodes.item[a].item["Layers"] == fArr[level] do (
										fNode = node.nodes.item[a]
										notFound = false
									)
								)
							)
							if fNode == undefined then (
								col = dnCol (random 0 255) (random 0 255) (random 0 255)
								node = nestedLayerManager.io.createFolderNode tl fArr[level] col node.id
							) else (
								node = fNode
							)
						)
						
						--Move layer to parent folder node
						layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer.layerAsRefTarg)
						if layerNode != undefined do (
							tl.moveNode layerNode node
						)
						
						--Refresh folders
						nestedLayerManager.io.setFolderStates()
						
						--Return true
						true
						
					) else (
						--Return false
						false
					)
					
				) else (
					--Return false
					false
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > createLayerInDir layerName dir"
			)
			
		),
		
		function createFolderFromDir dir = (
			
			try (
			
				if classOf dir == string and dir != "" then (
					
					--Local values
					local tl = nestedLayerManager.ui.tl
					local node = tl.nodes.item[0]
					local fArr = filterString dir "/\\"
					local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
					
					--Build folders
					for level = 1 to fArr.count do (
						local notFound = true
						local fNode = undefined
						for a=0 to node.nodes.count-1 while notFound do (
							if node.nodes.item[a].imageIndex == 1 do (
								if node.nodes.item[a].item["Layers"] == fArr[level] do (
									fNode = node.nodes.item[a]
									notFound = false
								)
							)
						)
						if fNode == undefined then (
							col = dnCol (random 0 255) (random 0 255) (random 0 255)
							folderName = nestedLayerManager.treeEvents.removeIllegalCharacters fArr[level]
							node = nestedLayerManager.io.createFolderNode tl folderName col node.id
						) else (
							node = fNode
						)
					)
					
					--Refresh folders
					nestedLayerManager.io.setFolderStates()
					
					--Return true
					true
					
				) else (
					--Return false
					false
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > createFolderFromDir dir"
			)
			
		),
		
		function moveLayerToDir layerName dir = (
			
			try (
			
				if classOf layerName == string and classOf dir == string then (
					
					--Create layer, if layer exists then return false, else continue
					local layer = layerManager.getLayerFromName layerName
					
					if  layer != undefined then (
						
						--Local values
						local tl = nestedLayerManager.ui.tl
						local node = tl.nodes.item[0]
						local fArr = filterString dir "/\\"
						local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
						
						--Build folders
						for level = 1 to fArr.count do (
							local notFound = true
							local fNode = undefined
							for a=0 to node.nodes.count-1 while notFound do (
								if node.nodes.item[a].imageIndex == 1 do (
									if node.nodes.item[a].item["Layers"] == fArr[level] do (
										fNode = node.nodes.item[a]
										notFound = false
									)
								)
							)
							if fNode == undefined then (
								col = dnCol (random 0 255) (random 0 255) (random 0 255)
								node = nestedLayerManager.io.createFolderNode tl fArr[level] col node.id
							) else (
								node = fNode
							)
						)
						
						--Move layer to parent folder node
						layerNode = nestedLayerManager.io.getNodeByLayerHnd (getHandleByAnim layer.layerAsRefTarg)
						if layerNode != undefined do (
							tl.moveNode layerNode node
						)
						
						--Refresh folders
						nestedLayerManager.io.setFolderStates()
						
						--Return true
						true
						
					) else (
						--Return false
						false
					)
					
				) else (
					--Return false
					false
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > moveLayerToDir layerName dir"
			)
			
		),
		
		function createFolderNode tl nodeName col parentNodeID = (
			
			if nestedLayerManager.showLog do format "[NLM] Creating Folder Node\n"
			folderNode = tl.appendNode #(nodeName, false, false, false, false, col, false) parentNodeId 1 1 -1
			append nestedLayerManager.folderNodes folderNode
			folderNode
			
		),
		
		-------------------------------------------------------------------------
		-- SAVE NESTED LAYER MANAGER DATA
		-------------------------------------------------------------------------
		function close = (
			
			try (
			
				if nestedLayerManager.showLog do format "[NLM] Closing MaxForm and Dialogs\n"
				
				if nestedLayerManager.maxFormOpen do (
					nestedLayerManager.mfEvents.close undefined undefined
				)
				if nestedLayerManager.dialogDockOpen do (
					try(cui.unRegisterDialogBar nestedLayerManager.ui.nlmRoll)catch()
					try(destroyDialog nestedLayerManager.ui.nlmRoll)catch()
				)
				
				--Return true
				true
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > close()"
			)
			
		),
		
		function closing = (
			
			try (
				
				if nestedLayerManager.showLog do format "[NLM] Clearing All Data\n"
				
				--Clear Search Bar
				nestedLayerManager.searchEvents.clearSearchBar()
				
				--Save treeview structure
				nestedLayerManager.io.save()
				
				--Remove events and callbacks, clear all nodes from tree and hashtables.
				nestedLayerManager.io.removeAllEventHandlersAndCallbacks()
				nestedLayerManager.io.clearAllNodeData()
				
				--Save ini preferences
				nestedLayerManager.io.saveIniPrefs()
			
				--Set window open value to false in struct
				nestedLayerManager.maxFormOpen = false
				nestedLayerManager.dialogDockOpen = false
				nestedLayerManager.windowOpen = false
			
				--Update toolbar button
				updateToolbarButtons()
				
				--Destroy extra dialogues
				try (destroyDialog nestedLayerManager.ui.settingsRoll) catch ()
				try (destroyDialog nestedLayerManager.ui.infoRoll) catch ()
				try (destroyDialog nestedLayerManager.ui.layerPropertiesRoll) catch ()
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > closing()"
			)
			
		),
		
		function save = (
			
			try (
			
				start = timeStamp()
				
				--Local values
				local tl = nestedLayerManager.ui.tl
				local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd 
				local layerDirs = #()
				local layerRefs = #()
				local folderDirs = #()
				local foldercolors = #()
				local layerDirsStr = stringStream ""
				local folderDirStr = stringStream ""
				local folderColStr = stringStream ""
				
				--Build layer information to save
				for a=0 to layerManager.count-1 do (
					layerRef = (layerManager.getLayer a).layerAsRefTarg
					layerHnd = getHandleByAnim layerRef
					layerNode = getNodeByLayerHnd layerHnd
					layerDir = ""
					if layerNode != undefinded do (
						parentNode = layerNode.parentNode
						while parentNode.level != 0 do (
							layerDir = (parentNode.item["Layers"] + "\\")+layerDir
							parentNode = parentNode.parentNode
						)
						format "%%{|}" layerDir layerRef.name to:layerDirsStr
						append LayerRefs layerRef
						append layerDirs layerDir
					)
				)
				
				--Build folder information to save
				for folderNode in nestedLayerManager.folderNodes do (
					folderDir = ""
					parentNode = folderNode.parentNode
					while parentNode.level != 0 do (
						folderDir = (parentNode.item["Layers"] + "\\")+folderDir
						parentNode = parentNode.parentNode
					)
					folderDir += folderNode.item["Layers"] + "\\"
					fCol = folderNode.item["Color"]
					format "%{|}" folderDir to:folderDirStr
					format "%{|}" (color fCol.r fCol.g fCol.b) to:folderColStr
					append folderDirs folderDir
					append foldercolors (color fCol.r fCol.g fCol.b)
				)
				
				--Save data to rootNode 
				rootNode.nestedLayerManager.layerDirs = layerDirs
				rootNode.nestedLayerManager.layerRefs = layerRefs
				rootNode.nestedLayerManager.folderDirs = folderDirs
				rootNode.nestedLayerManager.folderColours = foldercolors
				rootNode.nestedLayerManager.dataVersion = nestedLayerManager.dataVersion()
				
				--Save data to persistent global. This is not the main storage solution as it is very unsafe, but it does work with file > merge :-)
				persistent global nestedLayerManager_mergeData = #(layerDirsStr as string, folderDirStr as string, folderColStr as string)
				
				--Print info to listener if showlog is true
				end = timeStamp()
				if nestedLayerManager.showLog do format ("[NLM] Data version set to version " + nestedLayerManager.dataVersion() as string + "\n")
				if nestedLayerManager.showLog do format "[NLM] Saved all data to rootNode in % seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.saveError()
			)
			
		),
		
		
		-------------------------------------------------------------------------
		-- CLEAN AND RESET FUNCTIONS FOR NLM
		-------------------------------------------------------------------------
		
		function resetNLMClean = (
			try (
				--Remove events and callbacks, clear all nodes from tree and hashtables.
				nestedLayerManager.io.removeAllEventHandlersAndCallbacks removePostCallbacks:false
				nestedLayerManager.io.clearAllNodeData()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > resetNLMClean()"
			)
		),
		
		function resetNLMPopulate = (
			try (
				local tl = nestedLayerManager.ui.tl
				tl.beginUnboundLoad()
				nestedLayerManager.io.initRN()
				nestedLayerManager.io.buildTreeNodes tl
				nestedLayerManager.io.setLayerExpandState tl
				nestedLayerManager.io.setFolderStates()
				nestedLayerManager.treeEvents.sortColumn "Layers" ascending
				tl.endUnboundLoad()
				nestedLayerManager.ui.tl.nodes.item[0].expanded = true
				--Initialise Events and callbacks
				nestedLayerManager.io.addAllEventHandlersAndCallbacks()
				--Stop rootNode from being focused on load
				tl.focusedNode = undefined
				tl.selection.set undefined
				if nestedLayerManager.showLog do format "[NLM] Populated Treelist\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > resetNLMPopulate()"
			)
		),
		
		function clearAllNodeData = (
			try (
				--Clear Search Bar
				nestedLayerManager.searchEvents.clearSearchBar()
				--Values containing row/node references
				nestedLayerManager.callbacks.layerParamChangeQueue = #()
				nestedLayerManager.currentLayerNode = undefined
				nestedLayerManager.folderNodes = #()
				--Hash tables
				nestedLayerManager.io.getLayerHndHt.clear()
				nestedLayerManager.io.getLayerNodeHt.clear()
				nestedLayerManager.io.getObjectHndHt.clear()
				nestedLayerManager.io.getObjectNodeHt.clear()
				--Data treelist
				nestedLayerManager.ui.tl.clearNodes()
				if nestedLayerManager.showLog do format "[NLM] All node data cleared\n"
					
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > clearAllNodeData()"
			)
		),
		
		function addAllEventHandlersAndCallbacks = (
			try (
				nestedLayerManager.buttonEvents.initialiseEvents()
				nestedLayerManager.rc.initialiseEvents() 
				nestedLayerManager.treeEvents.initialiseEvents()
				nestedLayerManager.mfEvents.initialiseEvents()
				nestedLayerManager.searchEvents.initialiseEvents()
				nestedLayerManager.callbacks.addCallbacks()
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > addAllEventHandlersAndCallbacks()"
			)
		),
		
		function removeAllEventHandlersAndCallbacks removePostCallbacks:true = (
			try (
				nestedLayerManager.callbacks.removeCallbacks()
				if removePostCallbacks do nestedLayerManager.callbacks.removePostCallbacks()
				nestedLayerManager.buttonEvents.removeEvents()
				nestedLayerManager.rc.removeEvents()
				nestedLayerManager.treeEvents.removeEvents()
				nestedLayerManager.mfEvents.removeEvents()
				nestedLayerManager.searchEvents.removeEvents()
				if nestedLayerManager.showLog do format "[NLM] All event handlers and callbacks removed\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > removeAllEventHandlersAndCallbacks()"
			)
		),
		
		
		-------------------------------------------------------------------------
		-- SET CELL STATES FOR FOLDERS
		-------------------------------------------------------------------------
		
		--Set states of folders
		function setFolderStates = (
			
			try (
			
				local start = timeStamp()
				local tl = nestedLayerManager.ui.tl
				
				--List of columns to recursively check, columnVals are further in loop
				local columns = #("Current", "Visible", "Freeze", "Render", "Box")
				
				for folderNode in nestedLayerManager.folderNodes do (
					local noChildFolder = true
					local folderNodeNodes = folderNode.nodes
					for a=0 to folderNodeNodes.count-1 while noChildFolder do (
						if folderNodeNodes.item[a].imageIndex == 1 do noChildFolder = false
					)
					if noChildFolder do (
						local columnVals = for a=1 to columns.count collect false
						while folderNode.parentNode != undefined do (
							folderNodeNodes = folderNode.nodes
							if folderNode.hasChildren do (
								zeroNode = folderNodeNodes.item[0]
								for a=1 to columns.count do (
									columnVals[a] = zeroNode.item[columns[a]]
									for b=1 to folderNodeNodes.count-1 do (
										if folderNodeNodes.item[b].item[columns[a]] != columnVals[a] do columnVals[a] = "Grayed"
									)	
								)
							)
							for a=1 to columns.count do (
								folderNode.setValue columns[a] columnVals[a]
							)
							folderNode = folderNode.parentNode
						)
					)
				)
				
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Set folder state completed in % seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > setFolderStates()"
			)
		),
		
		
		-------------------------------------------------------------------------
		-- DYNAMIC OBJECT LOADING/UNLOADING FUNCTIONS
		-------------------------------------------------------------------------
		
		--Set expand state to layers in treelist. Object nodes are dynamically created on expand
		function setLayerExpandState tl = (
			
			try (
				
				local start = timeStamp()
				local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
				local ghba = getHandleByAnim
				
				for a=0 to layerManager.count-1 do (
					local layer = (layerManager.getLayer a).layerAsRefTarg
					local layerNode = getNodeByLayerHnd (ghba layer)
					if layerNode != undefined do (
						layer.nodes &objArr
						if objArr != undefined do (
							if objArr.count > 0 then layerNode.hasChildren = true else layerNode.hasChildren = false
						)
					)
				)
				end = timeStamp()
				if nestedLayerManager.showLog do format "[NLM] Set layer expand state completed in % seconds\n" ((end-start)/1000.0)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > setLayerExpandState"
			)
			
		),
		
		
		--Add obj nodes to treelist
		--Array contains #(layer, color, parentID, imageIndex, selectImageIndex)
		--Append node method #(Node object column info) parentID imageIndex selectImageIndex stateImageIndex
		function addObjNodes tl objectArr = (
			
			try (
				
				local ghba = getHandleByAnim
				local getObjectHndHt = nestedLayerManager.io.getObjectHndHt
				local getObjectNodeHt = nestedLayerManager.io.getObjectNodeHt
				local getNodeByLayerHnd = nestedLayerManager.io.getNodeByLayerHnd
				local getNodeByObjectHnd = nestedLayerManager.io.getNodeByObjectHnd
				local setObjectHndByNode = nestedLayerManager.io.setObjectHndByNode
				local setNodeByObjectHnd = nestedLayerManager.io.setNodeByObjectHnd
				local dnCol = (dotNetClass "System.Drawing.Color").fromARGB
				local index = 3
								
				for obj in objectArr do (
					if getNodeByObjectHnd (ghba obj) == undefined do (
						case (superClassOf obj) of (
							GeometryClass : (
								case (classOf obj) of (
									targetObject : index = 7
									boneGeometry : index = 9
									biped_object : index = 9
									default : index = 3
								)
							)
							shape : index = 4
							light : index = 5
							camera : index = 6
							helper : index = 7
							spaceWarpObject : index = 8
						)
						layerNode = getNodeByLayerHnd (ghba obj.layer.layerAsRefTarg)
						objCol = obj.wireColor
						col = dnCol objCol.r objCol.g objCol.b
						--Append node method #(layers, current, visible, freeze, render, color, box) parentID imageIndex selectImageIndex stateImageIndex
						node = tl.appendNode #(obj.name, false, (not obj.isNodeHidden), obj.isNodeFrozen, obj.renderable, col, obj.boxMode) layerNode.id index index -1
						--Append node information to hash tables for fast referencing
						hnd = ghba obj
						setObjectHndByNode node hnd
						setNodeByObjectHnd hnd node
					)
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > addObjNodes tl objArr"
			)
			
		),
		
		
		-------------------------------------------------------------------------
		-- GET/SET INI PREFS
		-------------------------------------------------------------------------
		
		--Get ini preferences and assign them to appropriate control.
		function loadIniPrefs = (
			
			try (
			
				iniFile = getDir #userScripts + "\\nestedLayerManagerPrefs.ini"
				if (doesFileExist iniFile) do (
					
					nlm = nestedLayerManager
					
					--Get and set window size and pos
					posX = getINISetting iniFile "MaxFormSettings" "PosX" ; if posX != "" do nlm.posX = posX as integer
					posY = getINISetting iniFile "MaxFormSettings" "PosY" ; if posY != ""do nlm.posY = posY as integer
					width = getINISetting iniFile "MaxFormSettings" "Width" ; if width != "" do nlm.width = width as integer
					height = getINISetting iniFile "MaxFormSettings" "Height" ; if height != "" do nlm.height = height as integer
					windowMode = getINISetting iniFile "MaxFormSettings" "WindowMode" ; if windowMode != "" do nlm.windowMode = windowMode as name
					
					--Get and set column width
					layersColWidth = getINISetting iniFile "columnWidths" "Layers" ; if layersColWidth != "" do nlm.layersColWidth = layersColWidth as integer
					currentColWidth = getINISetting iniFile "columnWidths" "Current" ; if currentColWidth != "" do nlm.currentColWidth = currentColWidth as integer
					visibleColWidth = getINISetting iniFile "columnWidths" "Visible" ; if visibleColWidth != "" do nlm.visibleColWidth = visibleColWidth as integer
					freezeColWidth = getINISetting iniFile "columnWidths" "Freeze" ; if freezeColWidth != "" do nlm.freezeColWidth = freezeColWidth as integer
					renderColWidth = getINISetting iniFile "columnWidths" "Render" ; if renderColWidth != "" do nlm.renderColWidth = renderColWidth as integer
					colorColWidth = getINISetting iniFile "columnWidths" "Color" ; if colorColWidth != "" do nlm.colorColWidth = colorColWidth as integer
					boxColWidth = getINISetting iniFile "columnWidths" "Box" ; if boxColWidth != "" do nlm.boxColWidth = boxColWidth as integer
					
					--Get and set column visibilty
					currentColEnabled = getINISetting iniFile "columnEnabled" "Current" ; if currentColWidth != "" do nlm.currentColEnabled = currentColEnabled as booleanClass
					visibleColEnabled = getINISetting iniFile "columnEnabled" "Visible" ; if visibleColWidth != "" do nlm.visibleColEnabled = visibleColEnabled as booleanClass
					freezeColEnabled = getINISetting iniFile "columnEnabled" "Freeze" ; if freezeColWidth != "" do nlm.freezeColEnabled = freezeColEnabled as booleanClass
					renderColEnabled = getINISetting iniFile "columnEnabled" "Render" ; if renderColWidth != "" do nlm.renderColEnabled = renderColEnabled as booleanClass
					colorColEnabled = getINISetting iniFile "columnEnabled" "Color" ; if colorColWidth != "" do nlm.colorColEnabled = colorColEnabled as booleanClass
					boxColEnabled = getINISetting iniFile "columnEnabled" "Box" ; if boxColWidth != "" do nlm.boxColEnabled = boxColEnabled as booleanClass
					
					--Get and set column order
					layersColOrder = getINISetting iniFile "columnOrder" "Layers" ; if layersColOrder != "" do nlm.layersColOrder = layersColOrder as integer
					currentColOrder = getINISetting iniFile "columnOrder" "Current" ; if currentColOrder != "" do nlm.currentColOrder = currentColOrder as integer
					visibleColOrder = getINISetting iniFile "columnOrder" "Visible" ; if visibleColOrder != "" do nlm.visibleColOrder = visibleColOrder as integer
					freezeColOrder = getINISetting iniFile "columnOrder" "Freeze" ; if freezeColOrder != "" do nlm.freezeColOrder = freezeColOrder as integer
					renderColOrder = getINISetting iniFile "columnOrder" "Render" ; if renderColOrder != "" do nlm.renderColOrder = renderColOrder as integer
					colorColOrder = getINISetting iniFile "columnOrder" "Color" ; if colorColOrder != "" do nlm.colorColOrder = colorColOrder as integer
					boxColOrder = getINISetting iniFile "columnOrder" "Box" ; if boxColOrder != "" do nlm.boxColOrder = boxColOrder as integer
					
					--Get and set Nested layer manager settings
					autoWidth = getINISetting iniFile "NLMSettings" "AutoWidth" ; if autoWidth != "" do nlm.autoWidth = autoWidth as booleanClass
					selectObjectsInScene = getIniSetting iniFile "NLMSettings" "selectObjectsInScene" ; if selectObjectsInScene != "" do nestedLayerManager.selectObjectsInScene = selectObjectsInScene as booleanClass
					selectObjectsInTree = getIniSetting iniFile "NLMSettings" "selectObjectsInTree" ; if selectObjectsInTree != "" do nestedLayerManager.selectObjectsInTree = selectObjectsInTree as booleanClass
					selectLayersInTree = getIniSetting iniFile "NLMSettings" "selectLayersInTree" ; if selectLayersInTree != "" do nestedLayerManager.selectLayersInTree = selectLayersInTree as booleanClass
					loadFoldersOnXref = getIniSetting iniFile "NLMSettings" "loadFoldersOnXref" ; if loadFoldersOnXref != "" do nestedLayerManager.loadFoldersOnXref = loadFoldersOnXref as booleanClass
					makeNewLayerCurrent = getIniSetting iniFile "NLMSettings" "makeNewLayerCurrent" ; if makeNewLayerCurrent != "" do nestedLayerManager.makeNewLayerCurrent = makeNewLayerCurrent as booleanClass
					loadFoldersOnMerge = getIniSetting iniFile "NLMSettings" "loadFoldersOnMerge" ; if loadFoldersOnMerge !="" do nestedLayerManager.loadFoldersOnMerge = loadFoldersOnMerge as booleanClass
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > loadINIPrefs()"
			)
			
		),
		
		--Save nested layer manager current apperance state to preferences file
		function saveIniPrefs = (
			
			try (
				
				--Local values
				local iniFile = getDir #userScripts + "\\nestedLayerManagerPrefs.ini"
				local mf = nestedLayerManager.ui.mf
				local col = nestedLayerManager.ui.tl.columns
				local nlm = nestedLayerManager
				
				--Set window size and pos
				setINISetting iniFile "MaxFormSettings" "Width" (mf.width as string)
				setINISetting iniFile "MaxFormSettings" "Height" (mf.height as string)
				setINISetting iniFile "MaxFormSettings" "PosX" (mf.location.x as string)
				setINISetting iniFile "MaxFormSettings" "PosY" (mf.location.y as string)
				setINISetting iniFile "MaxFormSettings" "WindowMode" (nlm.windowMode as string)
				
				--Set column width
				setINISetting iniFile "columnWidths" "Layers" (col.item["Layers"].width as string)
				setINISetting iniFile "ColumnWidths" "Current" (col.item["Current"].width as string)
				setINISetting iniFile "ColumnWidths" "Visible" (col.item["Visible"].width as string)
				setINISetting iniFile "ColumnWidths" "Freeze" (col.item["Freeze"].width as string)
				setINISetting iniFile "ColumnWidths" "Render" (col.item["Render"].width as string)
				setINISetting iniFile "ColumnWidths" "Color" (col.item["Color"].width as string)
				setINISetting iniFile "ColumnWidths" "Box" (col.item["Box"].width as string)
				
				--Set column visibilty
				setINISetting iniFile "columnEnabled" "Current" (col.item["Current"].visible as string)
				setINISetting iniFile "columnEnabled" "Visible" (col.item["Visible"].visible as string)
				setINISetting iniFile "columnEnabled" "Freeze" (col.item["Freeze"].visible as string)
				setINISetting iniFile "columnEnabled" "Render" (col.item["Render"].visible as string)
				setINISetting iniFile "columnEnabled" "Color" (col.item["Color"].visible as string)
				setINISetting iniFile "columnEnabled" "Box" (col.item["Box"].visible as string)
				
				--Get and set column order
				setINISetting iniFile "columnOrder" "Layers" (col.item["Layers"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Current" (col.item["Current"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Visible" (col.item["Visible"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Freeze" (col.item["Freeze"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Render" (col.item["Render"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Color" (col.item["Color"].visibleIndex as string)
				setINISetting iniFile "columnOrder" "Box" (col.item["Box"].visibleIndex as string)
				
				--Get and set Nested Settings
				setIniSetting iniFile "NLMSettings" "AutoWidth" (nlm.autoWidth as string)
				setIniSetting iniFile "NLMSettings" "selectObjectsInScene" (nlm.selectObjectsInScene as string)
				setIniSetting iniFile "NLMSettings" "selectObjectsInTree" (nlm.selectObjectsInTree as string)
				setIniSetting iniFile "NLMSettings" "selectLayersInTree" (nlm.selectLayersInTree as string)
				setIniSetting iniFile "NLMSettings" "loadFoldersOnXref" (nlm.loadFoldersOnXref as string)
				setIniSetting iniFile "NLMSettings" "makeNewLayerCurrent" (nlm.makeNewLayerCurrent as string)
				setIniSetting iniFile "NLMSettings" "loadFoldersOnMerge" (nlm.loadFoldersOnMerge as string)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"io.ms > saveINIPrefs()"
			)
			
		)

	)-- End struct
	
	nestedLayerManager.io = nestedLayerManagerGTStruct()
)