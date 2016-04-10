--Nested Layer Manager Right Click Struct
(
	struct nestedLayerManagerRCStruct (
		
		
		
		
		------------------------------------------------------------
		-- TREELIST COLUMN HEADER RIGHT CLICK MENU EVENT
		------------------------------------------------------------
		
		--Column right click menu function runs when show column menu event is fired
		function columnContextMenu tree event = (
			
			try (
				
				--Check to see if mouse is over column header
				hitInfoType = (tree.calcHitInfo (tree.PointToClient tree.MousePosition)).HitInfoType 
				if hitInfoType == hitInfoType.column or hitInfoType == hitInfoType.behindColumn do (
				
					--Remove all default buttons in menu
					for a=0 to event.menu.items.count-1 do (
						event.menu.items.item[a].visible = false
					)
					
					--Column visibility buttons
					showHideCurrent = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					showHideVisible = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					showHideFreeze = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					showHideRender = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					showHidecolor = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					showHideBox = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					
					--Build Array of column visibility buttons and names, apply settings
					btnArr = #(showHideCurrent,ShowHideVisible,ShowHideFreeze,ShowHideRender,ShowHidecolor,ShowHideBox)
					btnTagArr = #("Current","Visible","Freeze","Render","Color","Box")
					for a=1 to btnArr.count do (
						btnArr[a].caption = btnTagArr[a]
						btnArr[a].tag = btnTagArr[a]
						btnArr[a].checked = tree.columns.item[btnTagArr[a]].visible
					)
					
					--Reset columns button, apply settings and add to button array
					resetColWidth = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					resetColWidth.caption = "Reset Column Widths"
					resetColWidth.BeginGroup = true
					append btnArr resetColWidth
					
					--Reset column order button, apply settings and add to button array
					resetColOrder = dotNetObject "DevExpress.Utils.Menu.DXMenuCheckItem"
					resetColOrder.caption = "Reset Column Order"
					append btnArr resetColOrder
					
					--Add new menu items
					for btn in btnArr do event.menu.items.add btn
					
					--Reset Column Width Function
					function resetColWidthFn = (
						
						--Shortcuts
						tl = nestedLayerManager.ui.tl
						mf = nestedLayerManager.ui.mf
						
						--Reset column widths
						tl.columns.item["Layers"].width = tl.width-((tl.visibleColumnCount-1)*55)-19
						tl.columns.item["Current"].width = 45
						tl.columns.item["Visible"].width = 45
						tl.columns.item["Freeze"].width = 45
						tl.columns.item["Render"].width = 45
						tl.columns.item["Color"].width = 45
						tl.columns.item["Box"].width = 45
						
					)
					
					--Reset Column Order Function
					function resetColOrderFn = (
						
						--Shortcuts
						tl = nestedLayerManager.ui.tl
						
						--Reset column widths
						tl.columns.item["Layers"].visibleIndex = 0
						tl.columns.item["Current"].visibleIndex = 1
						tl.columns.item["Visible"].visibleIndex = 2
						tl.columns.item["Freeze"].visibleIndex = 3
						tl.columns.item["Render"].visibleIndex = 4
						tl.columns.item["Color"].visibleIndex = 5
						tl.columns.item["Box"].visibleIndex = 6
						
					)
					
					--Show hide colulmns function
					function showHideCol s e = (
						--Get column from button tag and reverse its visibility.
						col = nestedLayerManager.ui.tl.columns.item[s.tag]
						case (col.visible = not col.visible) of (
							true : nestedLayerManager.ui.tl.columns.item["Layers"].width += -col.width
							false : nestedLayerManager.ui.tl.columns.item["Layers"].width += col.width
						)
					)
					
					--Add event handler to new menu items
					dotNet.addEventHandler resetColWidth "click" resetColWidthFn
					dotNet.addEventHandler resetColOrder "click" resetColOrderFn
					dotNet.addEventHandler showHideCurrent "click" showHideCol
					dotNet.addEventHandler showHideVisible "click" showHideCol
					dotNet.addEventHandler showHideFreeze "click" showHideCol
					dotNet.addEventHandler showHideRender "click" showHideCol
					dotNet.addEventHandler showHidecolor "click" showHideCol
					dotNet.addEventHandler showHideBox "click" showHideCol
					
				)
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > columnContextMenu tree event"
			)
			
		),
		
		
		------------------------------------------------------------
		-- DOTNET EVENTS
		------------------------------------------------------------
		
		--Initialse right click event handlers
		function initialiseEvents = (
			
			try (
				--Shortcuts
				local rc = nestedLayerManager.rc
				local mf = nestedLayerManager.ui.mf			
				local tl = nestedLayerManager.ui.tl
				
				--Right click reference functions (dotNet cannot parse params, so linked functions are used)
				function createLayerLink = nestedLayerManager.buttonFunctions.createLayer addSel:false
				function createLayerAddSelLink = nestedLayerManager.buttonFunctions.createLayer addSel:true
				function createFolderLink = nestedLayerManager.buttonFunctions.createFolder()
				function addObjectsToLayerLink = nestedLayerManager.buttonFunctions.addObjectsToLayer()
				function whichObjectsSelLayersLink = nestedLayerManager.buttonFunctions.SelObjWiSelLyrFdr()
				function whichLayersSelObjectsLink = nestedLayerManager.buttonFunctions.SelLyrFdrOfSelObj()
				function deleteNodesLink = nestedLayerManager.buttonFunctions.deleteNodes()
				function deleteEmptyLayersLink = nestedLayerManager.buttonFunctions.deleteAllEmptyLayers()
				function deleteEmptyFoldersLink = nestedLayerManager.buttonFunctions.deleteAllEmptyFolders()
				function duplicateLayerInstanceLink = nestedLayerManager.buttonFunctions.duplicateLayer "Instance"
				function duplicateLayerCopyLink = nestedLayerManager.buttonFunctions.duplicateLayer "Copy"
				function moveToRootLink = nestedLayerManager.buttonFunctions.moveToRoot()
				function undockLink = nestedLayerManager.buttonFunctions.undock()
				function dockToLeftLink = nestedLayerManager.buttonFunctions.dockToLeft()
				function dockToRightLink = nestedLayerManager.buttonFunctions.dockToRight()
				function saveFolderIntoLayerNameLink = nestedLayerManager.buttonFunctions.saveFolderIntoLayerName()
				
				--Add event handlers.
				for a in rc.menuItems do (
					case a.text of (
						"Create Layer" : 											dotNet.addEventHandler a "click" createLayerLink
						"Create Layer (Add Selection)" : 					dotNet.addEventHandler a "click" createLayerAddSelLink
						"Create Folder" : 											dotNet.addEventHandler a "click" createFolderLink
						"Delete Selected" : 										dotNet.addEventHandler a "click" deleteNodesLink
						"Delete Empty Layers" : 								dotNet.addEventHandler a "click" deleteEmptyLayersLink
						"Delete Empty Folders" :								dotNet.addEventHandler a "click" deleteEmptyFoldersLink
						"Add Selected Objects to Layer" : 					dotNet.addEventHandler a "click" addObjectsToLayerLink
						"Highlight Layers of Selected Objects" :		 	dotNet.addEventHandler a "click" whichLayersSelObjectsLink
						"Select Objects Within Highlighted Selection" : 	dotNet.addEventHandler a "click" whichObjectsSelLayersLink
						"Duplicate Layer, Instance All Objects" :		 	dotNet.addEventHandler a "click" duplicateLayerInstanceLink
						"Duplicate Layer, Copy All Objects" : 				dotNet.addEventHandler a "click" duplicateLayerCopyLink
						"Move to Root" :											dotNet.addEventHandler a "click" moveToRootLink
						"Undock" : 													dotNet.addEventHandler a "click" undockLink
						"Dock to Left" :											dotNet.addEventHandler a "click" dockToLeftLink
						"Dock to Right" : 											dotNet.addEventHandler a "click" dockToRightLink
						"Save Folder Hierarchy into Layer Name" :			dotNet.addEventHandler a "click" saveFolderIntoLayerNameLink
					)
				)
				
				--Initialise column right click event handler
				function columnContextMenuLink s e = nestedLayerManager.rc.columnContextMenu s e
				dotNet.addEventHandler tl "ShowTreeListMenu" columnContextMenuLink
				
				if nestedLayerManager.showLog do format "[NLM] Right Click Events Added\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > initialiseEvents"
			)
		),
			
		--Remove right click event handlers
		function removeEvents = (
			
			try (
				--Remove event handlers
				for a in nestedLayerManager.rc.menuItems do dotNet.removeAllEventHandlers a
				if nestedLayerManager.showLog do format "[NLM] Right Click Events Removed\n"
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > removeEvents"
			)
			
		),
		
		
		
		-----------------------------------------------------
		-- TREELIST RIGHT CLICK MENU
		-----------------------------------------------------
		
		--DotNet right click context menu
		rightClickMenu = dotNetObject "System.Windows.Forms.ContextMenu",
		menuItems = #(),
		menuItemNames = #( 
			"Create Layer",
			"Create Layer (Add Selection)",
			"Create Folder",
			"-",
			"Delete Selected",
			"Delete Empty Layers",
			"Delete Empty Folders",
			"-",
			"Add Selected Objects to Layer",
			"Select Objects Within Highlighted Selection",
			"Highlight Layers of Selected Objects",
			"-",
			"Duplicate Layer, Instance All Objects",
			"Duplicate Layer, Copy All Objects",
			"-",
			"Move to Root",
			"-",
			"Undock",
			"Dock to Left",
			"Dock to Right",
			"-",
			"Save Folder Hierarchy into Layer Name"
		)
		
	)--End Struct
	
	nestedLayerManager.rc = nestedLayerManagerRCStruct()
	
	--Add right click buttons
	try (
		
		--Shortcut link
		local tl = nestedLayerManager.ui.tl 
		local rc = nestedLayerManager.rc
		
		--Buttons to be added to context menu
		local dnMenuItem = dotNetObject "System.Windows.Forms.MenuItem"
		for a in rc.menuItemNames do append rc.menuItems (dotNetObject "System.Windows.Forms.MenuItem" a)
		for a in rc.menuItems do rc.rightClickMenu.menuItems.add a
		
		--Add rc menu to treelist
		tl.contextMenu = rc.rightClickMenu
		
	) catch (
		if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"rightClick.ms > Add right click buttons"
	)
	
	nestedLayerManagerRCStruct
)
