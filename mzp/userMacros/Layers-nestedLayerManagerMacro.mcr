macroScript nestedLayerManagerMacro 
	category:"Layers"
	tooltip:"Nested Layer Manager"
	buttontext: "Nested Layer Manager"
	icon:#("nestedLayerManagerIcon",1)
	(
		
		global nestedLayerManager
		
		sysEn = dotNetClass "System.Environment"
		speFo = dotNetClass "System.Environment+specialFolder"
		programDataPath = sysEn.getfolderPath speFo.commonApplicationData
		
		--Custom Path
		--To change the installation of NLM to a network location, or anywhere other than the default location, change the text below.
		global nestedLayerManagerPath = programDataPath +  "\\Nested Layer Manager\\"
		
		on execute do (
			
			if nestedLayerManager == undefined do (
				
				startupDevFile = nestedLayerManagerPath + "scripts\\startup.ms"
				startupProFile = nestedLayerManagerPath + "scripts\\startup.mse"
				
				if doesFileExist startupProFile do (
					format "[NLM] Loading...\n"
					fileIn startupProFile
				)
				if doesFileExist startupDevFile do (
					format "[NLM] Loading...\n"
					fileIn startupDevFile
				)
				if not doesFileExist startupProFile and not doesFileExist startupDevFile do (
					messageBox "Failed to load Nested Layer Manager.\nPlease reinstall to fix this issue." title:"Nested Layer Manager"
				)
				
			)
			if nestedLayerManager != undefined then (
				if nestedLayerManager.windowOpen then (
					nestedLayerManager.close()
				)
				else (
					nestedLayerManager.open()
				)
			) else (
				messageBox "Failed to load Nested Layer Manager.\nPlease reinstall to fix this issue." title:"Nested Layer Manager"
			)
			
		)
		on isChecked return (if nestedLayerManager != undefined then nestedLayerManager.windowOpen else false)
	)