
--Close window if open
try(destroyDialog nestedLayerManager)catch() --version 1
try (nestedLayerManager.close()) catch() --version 2
try (destroyDialog nlmInstaller)catch() --nlm installer

(
	
	--Global and local variables
	global nlmInstaller
	local success
	
	sysEn = dotNetClass "System.Environment"
	speFo = dotNetClass "System.Environment+specialFolder"
	programDataPath = sysEn.getfolderPath speFo.commonApplicationData + "\\"
	
	
	function removeAllNestedData = (
		
		--Nested Layer Manager. Remove ALL data from scene.
		result = queryBox "This will remove ALL nested data from the currently loaded 3ds Max file and cannot be undone. \nAre you sure you would like to continue?" \
		title:"Nested Layer Manager"
		
		if result then (
			--Remove custom attributes
			for a=rootNode.custAttributes.count to 1 by-1 do (
				if rootNode.custAttributes[a].name == "nestedLayerManager" do (
					deleteItem rootNode.custAttributes a
					format "Custom Attributes Removed\n"
				)
			)
			
			--Update Log
			preTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.AppendText ("DELETED all Custom Attributes in Scene.\n")
			postTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.select preTextLength postTextLength
			nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 150 20 20
			nlmInstaller.rtb.ScrollToCaret()
			
			--Remove callback
			callbacks.removeScripts id:#nestedLayerManagerPersistent
			format "Callbacks Removed\n"
			
			--Update Log
			preTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.AppendText ("DELETED all Callbacks in Scene.\n")
			postTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.select preTextLength postTextLength
			nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 150 20 20
			nlmInstaller.rtb.ScrollToCaret()
			
			--Result
			messageBox "All data has been removed"\
			title:"Nested Layer Manager"
			
		) else (
			preTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.AppendText ("CANCELLED Deleting all Nested Data.\n")
			postTextLength = nlmInstaller.rtb.textLength
			nlmInstaller.rtb.select preTextLength postTextLength
			nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 20 150 20
			nlmInstaller.rtb.ScrollToCaret()
		)
	)
	
	
	--Copy file function
	function copyFileToDir installDir locationDir installFolder = (
		file = fileNameFromPath locationDir
		case copyFile locationDir installDir of (
			true : (
				preTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.AppendText ("Copied " + file + " to " + installFolder + " directory. \n")
				postTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.select preTextLength postTextLength
				nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 20 150 20
				nlmInstaller.rtb.ScrollToCaret()
			)
			false : (
				preTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.AppendText ("FAILED to copy " + file +" \n")
				postTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.select preTextLength postTextLength
				nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 150 20 20
				nlmInstaller.rtb.ScrollToCaret()
				success = false
			)
		)
	)
	
	
	--Delete file function
	function deleteFileFromDir fileDir installFolder = (
		
		file = fileNameFromPath fileDir
		case deleteFile fileDir of (
			true : (
				preTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.AppendText ("Deleted " + file + " from " + installFolder + " directory. \n")
				postTextLength = nlmInstaller.rtb.textLength
				nlmInstaller.rtb.select preTextLength postTextLength
				nlmInstaller.rtb.selectioncolor = (dotNetClass "System.Drawing.Color").FromArgb 20 150 20
				nlmInstaller.rtb.ScrollToCaret()
			)
		)
		
	)
	
	--Install nested layer manager function
	function installNestedLayerManager = (
		
		success = true
		
		createFolders = #(
			(programDataPath + "Nested Layer Manager\\"),
			(programDataPath + "Nested Layer Manager\\scripts\\"),
			(programDataPath + "Nested Layer Manager\\icons\\"),
			(programDataPath + "Nested Layer Manager\\assembly\\")
		)
		for a in createFolders do makeDir a
		
		tempDir = getDir #temp + "\\Nested Layer Manager\\"
		userIcons = getDir #userIcons + "\\"
		userMacros = getDir #userMacros + "\\"
		programDataIcons = programDataPath + "Nested Layer Manager\\icons\\"
		programDataScripts = programDataPath + "Nested Layer Manager\\scripts\\"
		programDataAssembly = programDataPath + "Nested Layer Manager\\assembly\\"
		
		maxIconsTempArr = getFiles (tempDir +"userIcons\\*.*")
		macroScriptTempArr = getFiles (tempDir +"userMacros\\*.*")
		nlmIconsTempArr = getFiles (tempDir +"icons\\*.*")
		scriptsTempArr = getFiles (tempDir +"scripts\\*.*")
		assemblyTempArr = getFiles (tempDir +"assembly\\*.*")
		
		--Copy files to dir <destination> <location> <folder name for ui feedback>
		for a in MaxIconsTempArr do copyFileToDir (userIcons + fileNameFromPath a) a "userIcons"
		for tempDir in macroScriptTempArr do copyFileToDir (userMacros + fileNameFromPath tempDir) tempDir "userMacros"
		for tempDir in nlmIconsTempArr do copyFileToDir (programDataIcons + fileNameFromPath tempDir) tempDir "icons"
		for tempDir in scriptsTempArr do copyFileToDir (programDataScripts + fileNameFromPath tempDir) tempDir "scripts"
		for tempDir in assemblyTempArr do copyFileToDir (programDataAssembly + fileNameFromPath tempDir) tempDir "assembly"
		
	)

	--Uninstall nested layer manger version 1
	function uninstallv1 = (
		
		uiDir = getdir #ui
		maxRoot = getDir #maxRoot
		
		filesToDelete = #( 
			#((uiDir + "\Icons\NestedLM_Tree_FolderIcon.bmp"), "icons"),
			#((uiDir + "\Icons\NestedLM_Tree_LayerIcon.bmp"), "icons"),
			#((uiDir + "\Icons\NestedLM_Tree_ObjectIcon.bmp"), "icons"),
			#((uiDir + "\Icons\NestedLM_ButtonIcons_16i.bmp"), "icons"),
			#((uiDir + "\Icons\NestedLM_ButtonIcons_16a.bmp"), "icons"),
			#((maxRoot + "stdplugs\stdscripts\NestedLayerManager.ms"), "startup"),
			#((uiDir + "\macroscripts\NestedLayerManagerMacro.mcr"), "macroscripts")
		)
		
		for a in filesToDelete do deleteFileFromDir a[1] a[2]
			
	)

	
	--Uninstall nested layer manager version 2
	function uninstallv2 queryIniDelete:true = (
		
		userIcons = getDir #userIcons + "\\"
		userScripts = getDir #userScripts + "\\"
		userMacros = getDir #userMacros + "\\"
		
		filesToDelete = #()
		
		--Query ini file deletion
		if queryIniDelete do (
			iniFile = getDir #userScripts + "\\nestedLayerManagerPrefs.ini"
			if doesFileExist iniFile do (
				if queryBox "Do you want to delete your user preferences file?" title:"Nested Layer Manager" do (
					append filesToDelete #((iniFile), "userScripts")
				)
			)
		)
		
		append filesToDelete #((userIcons + "NestedLayerManagerIcon_16i.bmp"), "userIcons")
		append filesToDelete #((userIcons + "NestedLayerManagerIcon_16a.bmp"), "userIcons")
		append filesToDelete #((userIcons + "NestedLayerManagerIcon_24i.bmp"), "userIcons")
		append filesToDelete #((userIcons + "NestedLayerManagerIcon_24a.bmp"), "userIcons")
		append filesToDelete #((userMacros + "Layers-nestedLayerManagerMacro.mcr"), "userMacros")
		
		--Nested Layer Manager v2.2.0 and below was installed into the userX path. Delete in case any data is here.
		for a in (getFiles (userIcons + "NestedLayerManager\\*.*")) do append filesToDelete #(a, "userIcons")
		for a in (getFiles (userScripts + "NestedLayerManager\\*.*")) do append filesToDelete #(a, "userScripts")
		for a in filesToDelete do deleteFileFromDir a[1] a[2]
		deleteFolders = #(
			(userScripts + "nestedLayerManager"),
			(userIcons + "nestedLayerManager")
		)
		for a in deleteFolders do hiddendoscommand ("rmdir /s /q \"" + a +  "\"") startpath:"C:\\"
		
		--Nested Layer Manager 2.2.1 and above is installed into the AllUsers (ProgramData) path. 
		--This is because it allows non admin read/write access, and is accessable from all users.
		for a in (getFiles (programDataPath + "Nested Layer Manager\\icons\\*.*")) do append filesToDelete #(a, "icons")
		for a in (getFiles (programDataPath + "Nested Layer Manager\\scripts\\*.*")) do append filesToDelete #(a, "scripts")
		for a in (getFiles (programDataPath + "Nested Layer Manager\\assembly\\*.*")) do append filesToDelete #(a, "scripts")
		for a in filesToDelete do deleteFileFromDir a[1] a[2]
		deleteFolders = #(
			(programDataPath + "Nested Layer Manager\\")
		)
		for a in deleteFolders do hiddendoscommand ("rmdir /s /q \"" + a +  "\"") startpath:"C:\\"
	)
	
	--Load Nested layer manager
	function reInitAfterInstall = (
		nestedLayerManager = undefined
		colorMan.reinitIcons()
		macros.load (getDir #userMacros)
	)
	
	--UI
	rollout NLMInstaller "Nested Layer Manager Installer" (
		
		groupBox gb1 "Instructions" pos:[10,10] height:50 width:430
		label info "Click to install/uninstall nested layer manager. \nIf a previous version is installed it will be updated." height:25 width:410 pos:[20,25]
		
		groupBox gb2 "Install Options" pos:[10,65] height:50 width:430
		button install "Install" across:2 width:200 offset:[10,-35] height:20 align:#left
		button closeBtn "Close" width:200 offset:[-10,-35] height:20 align:#right
		
		groupBox gb3 "Uninstall Options" pos:[10,120] height:50 width:430
		button btn_removeAllNestedData "Remove All Nested Data from Scene" across:2 width:200 offset:[10,-35] height:20 align:#left
		button uninstall "Uninstall" width:200 offset:[-10,-35] height:20 align:#right
		
		groupBox gb4 "Log" pos:[10,175] height:180 width:430
		dotNetControl rtb "richTextBox" pos:[20,195] height:150 width:410
		
		hyperlink web "www.timsportfolio.co.uk" address:"http:www.timsportfolio.co.uk" align:#right offset:[0,8]
		
		on install pressed do (
			
			uninstallv1()
			uninstallv2 queryIniDelete:false
			
			installNestedLayerManager()
			if success do reInitAfterInstall()
			
			if success then (
				messageBox 	"Installation Complete. \n\nNested Layer Manager is now available in \"Customise>Customise User Interface\". \n\nIt can be found under the Category \"Layers\"" title:"Nested Layer Manager"
			)
			else (
				messageBox "Installation Failed. \n\nSome items could not be copied over successfully. Please try running 3ds max in admin mode and installing again by navigating to MaxScript>Run Script" title:"Nested Layer Manager"
			)
		)
		
		on closeBtn pressed do (
			destroyDialog NLMInstaller
		)
		
		on btn_removeAllNestedData pressed do (
			removeAllNestedData()
		)
		
		on uninstall pressed do (
			
			uninstallv1()
			uninstallv2()
			
			messageBox "Uninstall Complete. \n\nIf you have any UI shortcuts they can be deleted by right clicking the icon, or by navigating to \"Customise>Customise User Interface\"" title:"Nested Layer Manager"
			
		)
		
		--Delete tempoary folder
		on NLMInstaller close do (
			dir = getDir #temp +"\\Nested Layer Manager"
			hiddendoscommand ("rmdir /s /q \"" + dir +  "\"") startpath:"C:\\"
		)
	)
	
	
	--Check that compatible version of max is present. If not, do not install.
	function maxExeVersion = (
		local versinfo = dotnetclass "System.Diagnostics.FileVersionInfo"
		local myFI = versinfo.GetVersionInfo (pathConfig.appendPath (pathConfig.GetDir #maxroot) "3dsmax.exe")
		local versionArr = filterString myFI.FileVersion "."
		versionArr
	)
	
	local allowInstall = true
	local errorText = "Whoops, that version of max is no good.\n\n"
	local maxExeVer = maxExeVersion()
	
	--Check for max 2012 SP1+
	if maxExeVer[1] as integer == 14 and maxExeVer[2] as integer == 0 do (
		allowInstall = false
		errorText += "Please install (at least) Service Pack 1 for 3ds Max 2012 before installing Nested Layer Manager."
	)
	
	--Check for max 2009+
	if maxExeVer[1] as integer < 11 do (
		allowInstall = false
		errorText += "Nested Layer Manager is supported in 3ds Max 2009+"
	)
	
	--Show dialog is max version is supported. Else show messagebox. 
	if allowInstall then (
		createDialog NLMInstaller 450 375 
	) else (
		messageBox errorText title:"Nested Layer Manager"
	)
	
)