--Nested Layer Manager Core Loader and Values Set Here
(
	--Define global variables
	global nestedLayerManager

	--Build nested layer manager struct
	--Read only values are functions
	
	struct nestedLayerManagerStruct (
		
		--Sub Structs
		init,											--Initialise Struct
		buttonEvents,								--Button Events Struct
		treeEvents,									--Treelist Events Struct
		mfEvents,									--MaxForm Events Struct
		callbacks,									--Callbacks Struct
		buttonFunctions,							--Functions for all buttons and right click menu
		io,												--Rootnode IO Struct
		ui,												--UI Struct
		rc,											--Right Click Struct
		error,											--Error Handling Scruct
		searchEvents,								--Search bar struct
		
		--Values stored within struct
		fn version = "2.2.6",						--Version of Nested Layer Manager
		fn dataVersion = 2.0,					--Version of rootNode data format. Used for any legacy functions.		
		showLog = false,							--When true various functions will print information into the listener on completion.
		showSyncLog = false,					--When true sync timer will print info to the listener
		
		currentLayerNode,						--Used to store current layer node in nested layer manager
		nodeCallback,								--Used to store instance of nodeEventCallback
		
		windowOpen = false,					--When open, set to true, when closed set to false.
		maxFormOpen = false,	
		dialogDockOpen = false,
		
		deleteQuery = false,						--When deleting nodes, this value is used to store whether the confirmation dialog is required.
		buttonPress = false,						--Used to store information on whether callback fired due to button press within nested layer manager.
		handlersActive = true,					--Used to disable change handlers when modifying a layer parameter diretly
		
		selectionCount = selection.count,	--Used to store selection count variances for deSelItemsOnMouseUp function
		preIOlayerCount = 0,
		preIOObjectCount = 0,
		topNodeIndex = 0,
		
		folderNodes = #(),						--All folder nodes in treelist
		
		nodePropsbyLayer = false,				--Used for node properties by layer preferences as a way of parsing variable to rollout
		defaultsIniFile = "",						--Used to transfer an outer local variable to rollout
		
		-------------------
		--Information stored in INI File. These are defaults in case ini file is corrupt/does not exist.
		
		posX = 100,								--X position of maxform from ini file
		posY = 100,								--Y position of maxform from ini file
		width = 550,								--Width of maxform from ini file
		height = 350,								--Height of maxform from ini file
		layersColWidth = 230,					--Column widths from ini file
		currentColWidth = 45,
		visibleColWidth = 45,
		freezeColWidth = 45,
		renderColWidth = 45,
		colorColWidth = 45,
		boxColWidth = 45,
		currentColEnabled = true,				--Column visibility from ini file
		visibleColEnabled = true,
		freezeColEnabled = true,
		renderColEnabled = true,
		colorColEnabled = true,
		boxColEnabled = true,
		layersColOrder = 0,						--Column order from ini file
		currentColOrder = 1,
		visibleColOrder = 2,
		freezeColOrder = 3,
		renderColOrder = 4,
		colorColOrder = 5,
		boxColOrder = 6,
		windowMode = #standard,
		
		loadFoldersOnXref = true,				--After loading xRef scene, folders are imported into scene too
		loadFoldersOnMerge = true,			--After merging scene, folders are imported into scene.
		selectObjectsInScene = false,		--After selecting an object in NLM, it will be selected in the viewport
		selectObjectsInTree = false,			--After selecting an object in the scene, it will be selected in NLM
		selectLayersInTree = false,			--After selecting an object in the scene, it's layer will be selected in NLM
		runSelObjFn  = true,					--Used to tell difference between NLM selecting object and user selecting object
		autoWidth = true,						--Treelist auto width setting from ini file
		makeNewLayerCurrent = true,		--After creating new layer, makes new layer current or not
		addSelToLayer = true,					--Add selected objects to new layer or not after manually creating new layer
		-------------------
		
		open,											--Shortcut to open function
		close,										--Shortcut to close function
		refresh,
		reload,										--Shortcut to reload nested layer manager
		createLayer,
		createFolder,
		moveLayer
		
	)--End Struct

	nestedLayerManager = nestedLayerManagerStruct()
	scripts = nestedLayerManagerPath + "scripts\\"
	
	--Load scripts
	(dotNetClass "System.Reflection.Assembly").Load ((dotNetClass "System.IO.File").ReadAllBytes (nestedLayerManagerPath + "assembly\\nestedLayerManager.dll"))
	fileIn (scripts + "errorHandling.ms")
	fileIn (scripts + "io.ms")
	fileIn (scripts + "ui.ms")
	fileIn (scripts + "rightclick.ms")
	fileIn (scripts + "buttonEvents.ms")	
	fileIn (scripts + "buttonFunctions.ms")
	fileIn (scripts + "treeEvents.ms")
	fileIn (scripts + "maxFormEvents.ms")
	fileIn (scripts + "callbacks.ms")
	fileIn (scripts + "searchEvents.ms")

	--Assign shortcuts to struct, used for permanent access to functions that will not change name or location for API
	nestedLayerManager.open = (function openNLM = nestedLayerManager.io.open())
	nestedLayerManager.close = (function closeNLM = nestedLayerManager.io.close())
	nestedLayerManager.refresh = (function refreshNLM = nestedLayerManager.mfEvents.refreshTree())
	nestedLayerManager.reload = (function reloadNLM = nestedLayerManager.mfEvents.reload())
	nestedLayerManager.createLayer = (function createLayer layerName dir = nestedLayerManager.io.createLayerInDir layerName dir)
	nestedLayerManager.createFolder = (function createFolder dir = nestedLayerManager.io.createFolderFromDir dir)
	nestedLayerManager.moveLayer = (function moveLayer layerName dir = nestedLayerManager.io.moveLayerToDir layerName dir)
	
	--Hooray, it's all loaded
	format "[NLM] Loaded Successfully\n"
	
)