--Nested Layer Manager UI
(
	-------------------------------------------
	--UI STRUCT
	-------------------------------------------
	
	struct nestedLayerManagerUIStruct (
		
		-------------------------------------------
		--Variables to contain dotNet objects
		-------------------------------------------
		
		--Standard windows form is now used instead of maxform so that keyboard shortcuts are still passed through to 3ds max
		--mf = dotNetObject "MaxCustomControls.MaxForm",
		mf = dotNetObject "System.Windows.Forms.Form",
		topPanel = dotNetObject"NestedLayerManager.UI.TopPanel",
		tl = dotNetObject "DevExpress.XtraTreeList.TreeList",
		tlPanel = dotNetObject "Panel",
		nlmPanel = dotNetObject "Panel",
		
		--Store instances of rollouts so they can be accessed and/or destroyed
		nlmRoll,
		progressRoll,
		layerPropertiesRoll,
		settingsRoll,								
		infoRoll,										
		errorRoll,
		
		-------------------------------------------
		--Functions
		-------------------------------------------
		
		function nlmDialog = (
			
			try (
			
				rollout nlmRoll "Nested Layer Manager" (
					dotNetControl panel "MaxCustomControls.MaxUserControl" width:(nestedLayerManager.ui.nlmPanel.width-16) height:(nestedLayerManager.ui.nlmPanel.height-38) pos:[0,0]
					on nlmRoll open do (
						bg = colorman.getColor #background * 255
						panel.backColor = (dotNetClass "System.Drawing.Color").FromArgb bg[1] bg[2] bg[3]
						panel.controls.add nestedLayerManager.ui.nlmPanel
						nestedLayerManager.ui.mf.hide()
						cui.registerDialogBar nlmRoll minsize:[333,250] maxsize:[nestedLayerManager.ui.nlmPanel.width,5000] style:#(#cui_dock_vert , #cui_handles, #cui_floatable)
						nestedLayerManager.dialogDockOpen = true
						nestedLayerManager.maxFormOpen = false
					)
					on nlmRoll close do (
						if not nestedLayerManager.maxFormOpen do (
							nestedLayerManager.io.closing()
						)
					)
					on nlmRoll resized size do (
						panel.size = dotNetObject "System.Drawing.Size" size[1] size[2]
					)
					local doRefresh = true
					on panel Paint args do (
						if doRefresh then (
						   doRefresh = false
						   panel.refresh()
						   doRefresh = true
						 )
					)
				)
				
				nestedLayerManager.ui.nlmRoll = nlmRoll
				width = nestedLayerManager.ui.nlmPanel.width-16
				height = nestedLayerManager.ui.nlmPanel.height-38
				createDialog nlmRoll width height style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_minimizebox, #style_maximizebox)
				
				if nestedLayerManager.showLog do format "[NLM] Showing Dockable Dialog\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"ui.ms >  nlmDialog()"
			)
		),
		
		-- Progress dialog
		function progressDialog = ( 
			
			try (destroyDialog nestedLayerManager.ui.progressRoll) catch ()
			
			rollout progressRoll "Loading Nested Layer Manager" (
				dotNetControl percent "Windows.Forms.Progressbar" width:240 height:30 offset:[-8,0]
				on progress open do (
					nestedLayerManager.progressRoll.percent.style = nestedLayerManager.progressRoll.percent.style.continuous
				)
			)
			nestedLayerManager.ui.progressRoll = progressRoll
			
			createDialog progressRoll 250 40
		),
		
		--Layer properties dialog
		function layerPropertiesDialog = (
			
			try(
			
				try (destroyDialog nestedLayerManager.ui.layerPropertiesRoll) catch ()
				
				rollout layerPropertiesRoll "Layer Properties" (
					
					--Top groupbox
					groupBox gb_layerInfo "Layer Information" width:380 height:100 pos:[10,5]
					--Left groupboxes
					groupBox gb_interactivity "Interactivity" width:185 height:65 pos:[10,110]
					groupBox gb_displayProperties "Display Properties" width:185 height:225 pos:[10,180]
					--Right groupboxes
					groupBox gb_renderingControl "Rendering Control" width:185 height:205 pos:[205,110]
					groupBox gb_motionBlur "Motion Blur" width:185 height:85 pos:[205,320]
					
					--Layer Information Controls
					editText et_layerName "Name:" height:20 labelOnTop:true across:2 width:205 pos:[20,25]
					dropDownList dd_display "Display:" items: #("Viewport", "Bounding Box", "Wireframe", "Shaded") width:145 pos:[235,25]
					colorPicker cp_layerColor "Active Color:" pos:[20,75]
					
					--Interactivity Controls
					checkBox cb_hide "Hide" pos:[20,130]
					checkBox cb_freeze "Freeze" pos:[20,150]
					
					--Display Controls
					checkBox cb_seeThrough "See-Through" pos:[20,200]
					checkBox cb_displayAsBox "Display As Box" pos:[20,220]
					checkBox cb_backfaceCull "Backface Cull" pos:[20,240]
					checkBox cb_edgesOnly "Edges Only" pos:[20,260]
					checkBox cb_vertexTicks "Vertex Ticks" pos:[20,280]
					checkBox cb_trajectory "Trajectory" pos:[20,300]
					checkBox db_ignoreExtents "Ignore Extents" pos:[20,320]
					checkBox db_showFrozenInGray "Show Frozen in Gray" pos:[20,340]
					checkBox cb_neverDegrade "Never Degrade" pos:[20,360]
					checkBox cb_vertexColors "Vertex Colors" pos:[20,380]
					checkButton cb_vertexColorsShaded "Shaded" pos:[130,380] height:16 width:50
					
					--Rendering Controls
					spinner spn_visibility "Visibility: " pos:[215,130] align:#left width:60
					checkBox cb_renderable "Renderable" pos:[215,150]
					checkBox cb_inheritVisibility "Inherit Visibility" pos:[215,170]
					checkBox cb_visibleToCamera "Visible to Camera" pos:[215,190]
					checkBox cb_visibleToRefRaf "Visible to Reflection/Refraction" pos:[215,210]
					checkBox cb_receiveShadows "Receive Shadows" pos:[215,230]
					checkBox cb_castShadows "Cast Shadows" pos:[215,250]
					checkBox cb_applyAtmospherics "Apply Atmospherics" pos:[215,270]
					checkBox cb_renderOccObjects "Render Occluded Objects" pos:[215,290]
					
					--Motion Blur Controls
					checkBox cb_motionBlurEnabled "Enabled" pos:[215,340]
					spinner spn_motionBlurMultiplier "Multiplier: " pos:[215,360] align:#left width:60
					radioButtons rb_motionBlurType "" labels:#("None", "Object", "Image")pos:[215,380]
					
					--OK Cancel Buttons
					button btn_ok "OK" width:70 height:25 pos:[240,415]
					button btn_cancel "Cancel" width:70 height:25 pos:[320,415]
					
					--Events
					on layerPropertiesRoll open do (
						--Functions
						function getCheckState property layers reversed:false = (
							local checkState = false
							local allTrue = true
							for a in layers do (
								case (getProperty a property) of (
									true : if reversed then allTrue = false else checkState = true
									false : if reversed then checkState = true else allTrue = false
								)
							)
							--Return checkstate
							if not checkState then 0 else if allTrue then 1 else 2
						)
						--Get selected layers in NLM
						local layerNodes = nestedLayerManager.ui.tl.selection
						local layers = for a=0 to layerNodes.count-1 while layerNodes.item[a].imageIndex == 2 collect (
							getAnimByHandle (nestedLayerManager.io.getLayerHndByNode layerNodes.item[a])
						)
						--Layer Information
						if layers.count == 1 then (
							--Layer name
							et_layerName.text = layers[1].name
							if et_layerName.text == "0" do et_layerName.enabled = false
							--Display mode
							dd_display.selection = case layers[1].display of (#viewport:1; #boundingBox:2; #wireframe:3; #shaded:4; default:1;)
							--Wirecolor
							cp_layerColor.color = layers[1].wireColor
						) else (
							--Layer Name
							et_layerName.text = "Multiple Selected"
							et_layerName.enabled = false
							--Wirecolor
							cp_layercolor.color = color 128 128 128
						)
						--Interactivity
						cb_hide.triState = getCheckState #on layers reversed:true
						cb_freeze.triState = getCheckState #isFrozen layers
						--Display Properties
						cb_seeThrough.triState = getCheckState #xray layers
						cb_displayAsBox.triState = getCheckState #boxMode layers
						cb_backfaceCull.triState = getCheckState #backFaceCull layers
						cb_edgesOnly.triState = getCheckState #allEdges layers
						cb_vertexTicks.triState = getCheckState #vertexTicks layers
						cb_trajectory.triState = getCheckState #showTrajectory layers
						db_ignoreExtents.triState = getCheckState #ignoreExtents layers
						db_showFrozenInGray.triState = getCheckState #showFrozenInGray layers
						cb_neverDegrade.triState = getCheckState #degrade layers
						cb_vertexColors.triState = getCheckState #showVertexColors layers
						cb_vertexColorsShaded.checked  = if layers.count == 1 then layers[1].vertexColorsShaded else false
						--Rendering Control
						spn_visibility.value = if layers.count == 1 then layers[1].visibility else 1.00
						cb_renderable.tristate = getCheckState #renderable layers
						cb_inheritVisibility.tristate = getCheckState #inheritVisibility layers
						cb_visibleToCamera.tristate = getCheckState #primaryVisibility layers
						cb_visibleToRefRaf.tristate = getCheckState #secondaryVisibility layers
						cb_receiveShadows.tristate = getCheckState #receiveShadows layers
						cb_castShadows.tristate = getCheckState #castShadows layers
						cb_applyAtmospherics.tristate = getCheckState #applyAtmospherics layers
						cb_renderOccObjects.tristate = getCheckState #renderOccluded layers
						--Motion Blur
						cb_motionBlurEnabled.tristate = getCheckState #motionBlurOn layers
						spn_motionBlurMultiplier.value = if layers.count == 1 then layers[1].imageMotionBlurMultiplier else 1.00
						if layers.count == 1 then rb_motionBlurType.state = case layers[1].motionBlur of (#none:1; #object:2; #image:3; default:1;)
					)
					
					on btn_ok pressed do (
						--Functions
						function setCheckState property layers val reversed:false = (
							case val of (
								0 : for a in layers do setProperty a property (if reversed then true else false)
								1 : for a in layers do setProperty a property (if reversed then false else true)
								false : for a in layers do setProperty a property (if reversed then true else false)
								true : for a in layers do setProperty a property (if reversed then false else true)
							)
						)
						--Get selected layers in NLM
						local layerNodes = nestedLayerManager.ui.tl.selection
						local layers = for a=0 to layerNodes.count-1 while layerNodes.item[a].imageIndex == 2 collect (
							getAnimByHandle (nestedLayerManager.io.getLayerHndByNode layerNodes.item[a])
						)
						--Layer Information
						if layers.count == 1 then (
							--Layer name
							layers[1].setName et_layerName.text
							--Display mode
							layers[1].display = case dd_display.selection of (1:#viewport; 2:#boundingBox; 3:#wireframe; 4:#shaded;)
							--Wirecolor
							layers[1].wireColor = cp_layerColor.color
						) else (
							for a in layers do (
								a.display = case dd_display.selection of (1:#viewport; 2:#boundingBox; 3:#wireframe; 4:#shaded;)
								if cp_layerColor.color != (color 128 128 128) do a.wirecolor = cp_layercolor.color
							)
						)
						--Interactivity
						setCheckState #on layers cb_hide.triState reversed:true
						setCheckState #isFrozen layers cb_freeze.triState
						--Display Properties
						setCheckState #xray layers cb_seeThrough.tristate
						setCheckState #boxMode layers cb_displayAsBox.tristate
						setCheckState #backFaceCull layers cb_backfaceCull.tristate
						setCheckState #allEdges layers cb_edgesOnly.tristate
						setCheckState #vertexTicks layers cb_vertexTicks.tristate
						setCheckState #showTrajectory layers cb_trajectory.tristate
						setCheckState #ignoreExtents layers db_ignoreExtents.tristate
						setCheckState #showFrozenInGray layers db_showFrozenInGray.tristate
						setCheckState #degrade layers cb_neverDegrade.tristate
						setCheckState #showVertexColors layers cb_vertexColors.tristate
						setCheckState #vertexColorsShaded layers cb_vertexColorsShaded.checked
						--Rendering Control
						for a in layers do a.visibility = spn_visibility.value
						setCheckState #renderable layers cb_renderable.tristate
						setCheckState #inheritVisibility layers cb_inheritVisibility.tristate
						setCheckState #primaryVisibility layers cb_visibleToCamera.tristate
						setCheckState #secondaryVisibility layers cb_visibleToRefRaf.tristate
						setCheckState #receiveShadows layers cb_receiveShadows.tristate
						setCheckState #castShadows layers cb_castShadows.tristate
						setCheckState #applyAtmospherics layers cb_applyAtmospherics.tristate
						setCheckState #renderOccluded layers cb_renderOccObjects.tristate
						--Motion Blur
						setCheckState #motionBlurOn layers cb_motionBlurEnabled.tristate
						for a in layers do a.imageMotionBlurMultiplier = spn_motionBlurMultiplier.value
						for a in layers do a.motionBlur = case rb_motionBlurType.state of (1:#none; 2:#object; 3:#image;)
						--Close Window
						destroyDialog nestedLayerManager.ui.layerPropertiesRoll
					)
					
					on btn_cancel pressed do (
						destroyDialog nestedLayerManager.ui.layerPropertiesRoll
					)
					
				)
				nestedLayerManager.ui.layerPropertiesRoll = layerPropertiesRoll
				createDialog layerPropertiesRoll 400 450
				
				if nestedLayerManager.showLog do format "[NLM] Showing Layer Properties Dialog\n"
				
			) catch (
				if nestedLayerManager != undefined do nestedLayerManager.error.scriptError message:"ui.ms >  layerProperties()"
			)
		),
		
		--Settings window rollout
		function settings = (
			
			try (
				
				--Destroy dialog if it is already open
				try (destroyDialog nestedLayerManager.ui.settingsRoll)catch()
				
				--Obtain required values from max ini files. (This is so stupidly complicated, all because there is no way to access this damn setting through mxs. /rant)
				maxIniFile = getMaxIniFile()
				plugCFGDir = getINISetting maxIniFile "Directories" "PlugCFG"
				defaultsDir =getFilenamePath plugCFGDir + "defaults\max\\"
				defaultsIniFile = defaultsDir + "currentDefaults.ini"
				
				nestedLayerManager.defaultsIniFile = defaultsIniFile
				nestedLayerManager.nodePropsByLayer = case (getINISetting defaultsIniFile "LAYER" "LayerDefault") of (
					"1": true
					default: false
				)
				
				--Build rollout
				rollout settingsRoll "Nested Layer Manager | Settings" (
					
					group "IO Options" (
						checkbox cb_loadFoldersOnXref "Merge Folders on Xref Scene Import" \
							checked: nestedLayerManager.loadFoldersOnXref
						checkBox cb_loadFoldersOnMerge "Merge Folders on File > Merge" \
							checked: nestedLayerManager.loadFoldersOnMerge
					)
					group "Selection Options" (
						checkbox cb_selectObjectsInScene "Select objects in scene after selecting them in NLM UI" \
							checked:nestedLayerManager.selectObjectsInScene
						checkbox cb_selectObjectsInTree "Select objects in NLM UI after selecting them in scene" \
							checked:nestedLayerManager.selectObjectsInTree
						checkbox cb_selectLayersInTree "Select layers in NLM UI after selecting objects in scene" \
							checked:nestedLayerManager.selectLayersInTree
					)
					group "Layer Options" (
						checkbox cb_nodePropsByLayer "Default new node properties to 'By Layer'" \
							checked:nestedLayerManager.nodePropsByLayer
						label lbl_nodePropsByLayer "(Warning: 3ds Max Restart Required for above change)" align:#left
						checkbox cb_makeNewLayerCurrent "Make new layer the current layer" \
							checked:nestedLayerManager.makeNewLayerCurrent
					)
					group "UI Options" (
						checkbox cb_autoColWidth "Automatic Column Resizing" \
							checked:nestedLayerManager.autoWidth
					)
					group "Delete Nested Data" (
						button btn_removeAllNestedData "Remove All Nested Data From Scene" width:290
					)
					
					on cb_loadFoldersOnXref changed state do (
						nestedLayerManager.loadFoldersOnXref = state
					)
					
					on cb_loadFoldersOnMerge changed state do (
						nestedLayerManager.loadFoldersOnMerge = state
					)
					
					on cb_selectObjectsInScene changed state do (
						nestedLayerManager.selectObjectsInScene = state
					)
					
					on cb_selectObjectsInTree changed state do (
						nestedLayerManager.selectObjectsInTree = state
						nestedLayerManager.selectLayersInTree = false
						cb_selectLayersInTree.state = false
					)
					
					on cb_selectLayersInTree changed state do (
						nestedLayerManager.selectLayersInTree = state
						nestedLayerManager.selectObjectsInTree = false
						cb_selectObjectsInTree.state = false
					)
					
					on cb_nodePropsByLayer changed state do (
						layerDefault = case state of (
							true: "1"
							default: "0"
						)
						setINISetting nestedLayerManager.defaultsIniFile "LAYER" "LayerDefault" layerDefault
					)
					
					on cb_makeNewLayerCurrent changed state do (
						nestedLayerManager.makeNewLayerCurrent = state
					)
					
					on cb_autoColWidth changed state do (
						nestedLayerManager.ui.tl.optionsView.autoWidth = state
						nestedLayerManager.autoWidth = state
					)
					
					on btn_removeAllNestedData pressed do (
						nestedLayerManager.buttonFunctions.removeAllNestedData ()
					)
				)
				nestedLayerManager.ui.settingsRoll = settingsRoll
				
				mf = nestedLayerManager.ui.mf
				width = 310
				height = 335
				xPos = (mf.location.x+(mf.width/2))-width/2
				yPos = (mf.location.y+(mf.height/2))-height/2
				
				createDialog settingsRoll width height xPos yPos
					
				if nestedLayerManager.showLog do format "[NLM] Showing Settings Dialog\n"
				
			) catch (
				nestedLayerManager.error.scriptError message:"ui.ms > settings()"
			)
			
		),
		
		--Information window rollout
		function information = (
			try (
				
				--Destry dialog if it is already open
				try (destroyDialog nestedLayerManager.ui.infoRoll)catch()
				
				--Info about NLM
				local aboutText = ""
				aboutText += "Thank you for using Nested Layer Manager. "
				aboutText += "Licensed under MIT License."
				aboutText += "Originally written by Tim Hawker, now open source!"
				
				rollout info "Nested Layer Manager | Information" (
					
					label title "" offSet:[0,10] align:#left 
					
					label aboutNLM "" width:300 height:130 align:#left offSet:[0,10] 					
				)
				nestedLayerManager.ui.infoRoll = info
				
				mf = nestedLayerManager.ui.mf
				width = 320
				height = 210
				xPos = (mf.location.x+(mf.width/2))-width/2
				yPos = (mf.location.y+(mf.height/2))-height/2
				createDialog info width height xPos yPos
				info.title.text = "Nested Layer Manager " + nestedLayerManager.version()
				info.aboutNLM.text = aboutText
					
				if nestedLayerManager.showLog do format "[NLM] Showing Info Dialog\n"
					
			) catch (
				nestedLayerManager.error.scriptError message:"ui.ms > information()"
			)
		),
		
		--Load dotNet image, referencing the file so that it is not locked. Important for uninstalls.
		function loadDotNetImage dir = (
			imageStream = (dotNetClass "System.IO.File").ReadAllBytes dir
			memoryStream = dotNetObject "System.IO.MemoryStream" imageStream
			img = (dotNetClass "System.Drawing.Image").fromStream memoryStream
		)
		
	)--End Struct
	
	nestedLayerManager.ui = nestedLayerManagerUIStruct()
	
	--Surround in try catch for error handling
	try (
		
		--Load ini preferences to customise size and position of controls
		nestedLayerManager.io.loadIniPrefs()
		
		--Define local variables
		local tl = nestedLayerManager.ui.tl
		local ui = nestedLayerManager.ui
		local nlm = nestedLayerManager
		local uiDir = nestedLayerManagerPath + "icons\\"
		
		--Begin UI update
		tl.beginUpdate()
		
		----------------------------------------------------
		-- TREELIST UI CUSTOMISATION
		----------------------------------------------------
		
		--Size and position
		local systemInfo = dotNetClass "SystemInformation"
		local borderSize = systemInfo.frameBorderSize.width
		local captionHeight = systemInfo.captionHeight
		
		local tlWidth = nestedLayerManager.width - (borderSize*2) - 10
		local tlHeight = nestedLayerManager.height - (borderSize*2) - captionHeight - 61
		
		ui.tl.size = dotNetObject "System.Drawing.Size" tlWidth tlHeight
		
		--Column data to be used in loop. (1.name 2.textAlign 3.allowEdit 4.width 5.visibleIndex 6.visible 7.checkedIcon 8.grayedIcon 9.uncheckedIcon, 10.fixedWidth, 11.minWidth)
		local columns = #( \
			#("Layers", "left", true, nlm.layersColWidth, nlm.layersColOrder, true, undefined, undefined, undefined, false, 100),
			#("Current", "centre", false, nlm.currentColWidth, nlm.currentColOrder, nlm.currentColEnabled, "currentChecked", "currentGrayed", "currentUnchecked", true, 20),
			#("Visible", "centre", false, nlm.visibleColWidth, nlm.visibleColOrder, nlm.visibleColEnabled, "visibleChecked", "visibleGrayed", "visibleUnchecked", true, 20),
			#("Freeze", "centre", false, nlm.freezeColWidth, nlm.freezeColOrder, nlm.freezeColEnabled, "freezeChecked", "freezeGrayed", "unchecked", true, 20),
			#("Render", "centre", false, nlm.renderColWidth, nlm.renderColOrder, nlm.renderColEnabled, "renderChecked", "renderGrayed", "unchecked", true, 20),
			#("Color", "centre", false, nlm.colorColWidth, nlm.colorColOrder, nlm.colorColEnabled, undefined, undefined, undefined, true, 20),
			#("Box", "centre", false, nlm.boxColWidth, nlm.boxColOrder, nlm.boxColEnabled, "boxChecked", "boxGrayed", "unchecked", true, 20)
		)
		
		--Column factory using previously defined data array
		for a in columns do (
			col = tl.columns.add()
			col.caption = a[1]
			col.appearanceHeader.textOptions.hAlignment = case a[2] of (
				"left" : col.appearanceHeader.textOptions.hAlignment.default
				"centre" : col.appearanceHeader.textOptions.hAlignment.center
			)
			col.optionsColumn.allowEdit = a[3]
			col.width = a[4]
			col.visibleIndex = a[5]
			col.visible = a[6]
			if a[7] != undefined do (
				checkEdit = dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemCheckEdit"
				checkEdit.CheckStyle = checkEdit.checkStyle.userDefined			
				checkEdit.pictureChecked = nestedLayerManager.ui.loadDotNetImage (uiDir+a[7]+".png")
				checkEdit.pictureGrayed = nestedLayerManager.ui.loadDotNetImage (uiDir+a[8]+".png")
				checkEdit.pictureUnchecked = nestedLayerManager.ui.loadDotNetImage (uiDir+a[9]+".png")
				col.columnEdit = checkEdit
			)
			col.optionsColumn.fixedWidth = a[10]
			col.minWidth = a[11]
			--color control for color column
			if a[1] == "Color" do (
				colorBox = dotNetObject "DevExpress.XtraEditors.Repository.RepositoryItemColorEdit"
				colorBox.buttons.item[0].visible = false
				colorBox.colorAlignment = colorBox.colorAlignment.center
				col.columnEdit = colorBox
			)
		)
		
		--dotNet anchor to auto resize objects
		anchorStyle = (dotNetClass "System.Windows.Forms.AnchorStyles")
		
		--Treelist node icons
		iconsArr = #("root", "folder", "layer", "object", "spline", "light", "camera", "helper", "spaceWarp", "bones")
		nodeImgList = dotNetObject "DevExpress.Utils.ImageCollection"
		nodeImgList.imageSize = dotNetObject "System.Drawing.Size" 18 18
		for a in iconsArr do (
			nodeImgList.images.add (nestedLayerManager.ui.loadDotNetImage (uiDir+a+".png"))
		)
		tl.selectImageList = nodeImgList
		
		--Treelist UI options
		local dnCol = (dotNetClass "System.Drawing.Color").FromArgb
		
		bgCol  = (colorMan.getColor #window * 255)
		--Check to make sure bgCol is within 5-250 to avoid impossible rgb values
		for a=1 to 3 do (
			if bgCol[a] > 250 do bgCol[a] = 250
			if bgCol[a] < 5 do bgCol[a] = 5
		)
		fcsCol  = (colorMan.getColor #itemHilight * 255)
		textCol = (colorMan.getColor #text * 255)
		fcsTextCol = (colorMan.getColor #hilightText * 255)
		treeLineCol = (colorMan.getColor #background * 255)
		
		tl.appearance.oddRow.backColor = dnCol (bgCol[1]+5) (bgCol[2]+5) (bgCol[3]+5)
		tl.appearance.evenRow.backColor = dnCol (bgCol[1]-5) (bgCol[2]-5) (bgCol[3]-5)
		tl.appearance.treeLine.backColor = dnCol treeLineCol[1] treeLineCol[2] treeLineCol[3]
		tl.appearance.focusedRow.backColor = dnCol fcsCol[1] fcsCol[2] fcsCol[3]
		tl.appearance.selectedRow.backColor = dnCol fcsCol[1] fcsCol[2] fcsCol[3]
		tl.appearance.oddRow.foreColor = dnCol textCol[1] textCol[2] textCol[3]
		tl.appearance.evenRow.foreColor = dnCol textCol[1] textCol[2] textCol[3]
		tl.appearance.focusedRow.foreColor = dnCol fcsTextCol[1] fcsTextCol[2] fcsTextCol[3]
		tl.appearance.selectedRow.foreColor = dnCol fcsTextCol[1] fcsTextCol[2] fcsTextCol[3]
		tl.appearance.hideSelectionrow.backColor = dnCol fcsCol[1] fcsCol[2] fcsCol[3]
		tl.appearance.hideSelectionrow.foreColor = dnCol fcsTextCol[1] fcsTextCol[2] fcsTextCol[3]
		tl.appearance.empty.backColor = dnCol bgCol[1] bgCol[2] bgCol[3]
		
		tl.optionsBehavior.immediateEditor = false
		tl.optionsBehavior.editable = true
		tl.optionsBehavior.allowExpandOnDblclick = false
		tl.optionsBehavior.closeEditorOnLostFocus = true
		tl.optionsBehavior.KeepSelectedOnClick = true
		tl.optionsBehavior.dragNodes = true
		tl.optionsBehavior.expandNodeOnDrag = true
		tl.optionsBehavior.showEditorOnMouseUp = true
		tl.optionsBehavior.autoSelectAllInEditor = true
		tl.optionsBehavior.autoChangeParent = false
		
		tl.OptionsSelection.multiselect = true
		tl.OptionsSelection.enableAppearanceFocusedCell = false
		
		tl.optionsView.autoWidth = nestedLayerManager.autoWidth
		tl.optionsView.showIndicator = false
		tl.optionsView.showButtons = true	
		tl.optionsView.enableAppearanceOddRow = true
		tl.optionsView.enableAppearanceEvenRow = true
		tl.optionsView.showFocusedFrame = false
		tl.optionsView.showVertLines = false
		tl.optionsView.showhorzlines = false
		tl.optionsView.showRoot = false
		
		tl.treeLineStyle = tl.treeLineStyle.solid
		tl.borderStyle = tl.borderStyle.simple
		
		tl.anchor = dotnet.combineEnums anchorStyle.top anchorStyle.bottom anchorStyle.left anchorStyle.right
		
		if (maxVersion())[1] < 14000 then (
			--lookAndFeel does not work in max 2012.
			--Alternatives are to custom draw column header, but this has noticable slowdown, and does not style the scrollbar.
			tl.lookAndFeel.activelookandfeel.style = tl.lookAndFeel.activelookandfeel.style.style3d
			tl.lookAndFeel.activelookandfeel.useDefaultLookAndFeel = false
			tl.lookAndFeel.activelookandfeel.useWindowsXPtheme = true
		)
		
		--Border style cannot be changed due to above bug. Instead hide it, and place treelist in panel with border.
		tl.borderStyle = tl.borderStyle.noBorder
		
		--End UI update
		tl.endUpdate()
		
		----------------------------------------------------
		-- TOP PANEL CUSTOMISATION
		----------------------------------------------------
		
		ui.topPanel.windowColor = dnCol bgCol[1] bgCol[2] bgCol[3]
		ui.topPanel.textColor = dnCol textCol[1] textCol[2] textCol[3]
		
		----------------------------------------------------
		-- PANEL CUSTOMISATION
		----------------------------------------------------
		
		ui.tlPanel.size = dotNetObject "System.Drawing.Size" tlWidth tlHeight
		ui.tlPanel.location = dotNetObject "System.Drawing.Point" 5 56
		ui.tlPanel.borderStyle = ui.tlPanel.borderStyle.fixedSingle
		ui.tlPanel.anchor = dotnet.combineEnums anchorStyle.top anchorStyle.bottom anchorStyle.left anchorStyle.right
		
		ui.nlmPanel.size = dotNetObject "System.Drawing.Size" nestedLayerManager.width nestedLayerManager.height
		ui.nlmPanel.anchor = dotnet.combineEnums anchorStyle.top anchorStyle.bottom anchorStyle.left anchorStyle.right
		
		----------------------------------------------------
		-- FORM CUSTOMISATION
		----------------------------------------------------
		
		--Size and position
		ui.mf.size = dotNetObject "System.Drawing.Size" nestedLayerManager.width nestedLayerManager.height
		ui.mf.minimumSize = dotNetObject "System.Drawing.Size" 333 160
		ui.mf.showInTaskBar = false
		--Window title
		ui.mf.text = "Nested Layer Manager " + nestedLayerManager.version()
		--Icon
		ui.mf.icon = (dotNetObject "MaxCustomControls.MaxForm").icon
		
		--Add top panel
		ui.topPanel.size = dotNetObject "System.Drawing.Size" tlWidth 55
		ui.nlmPanel.controls.add ui.topPanel
		--Add Treelist
		ui.tlPanel.controls.add ui.tl
		ui.nlmPanel.controls.add ui.tlPanel
		
		--Add panel to maxform
		ui.mf.controls.add ui.nlmPanel
		
	) catch (
		nestedLayerManager.error.scriptError message:"ui.ms"
	)

	nestedLayerManager.ui
	
)