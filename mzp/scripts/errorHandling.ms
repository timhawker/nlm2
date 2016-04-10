--Nested layer manager error handling struct
(
	struct nestedLayerManagerErrorHandlingStruct (
		
		errorMessage,
		currentException,
		
		--Script error function is fired in the catch component of a try within a function.
		function scriptError message:"undefined" = (
			
			--Stop timer and disable callbacks/events to prevent any more errors
			try (	nestedLayerManager.callbacks.layerParamsTimer.stop()	) catch()
			try (	nestedLayerManager.callbacks.removeCallbacks()			) catch()
			try (	nestedLayerManager.buttonEvents.removeEvents()		) catch()
			try (	nestedLayerManager.rc.removeEvents()						) catch()
			try (	nestedLayerManager.treeEvents.removeEvents()			) catch()
			try (	nestedLayerManager.mfEvents.removeEvents()				) catch()
			
			--Build error rollout
			try ( nestedLayerManager.error.buildErrorRoll() 					) catch()
			try ( nestedLayerManager.error.errorMessage = message		) catch()
			try ( nestedLayerManager.error.currentException = getCurrentException() ) catch()
			
			--Print to listener
			try ( format ("[NLM] AN ERROR HAS OCCURED\n[NLM] Error Occured In: %\n[NLM] Error Message: % \n" ) message nestedLayerManager.error.currentException ) catch()
			
			try ( 
				createDialog nestedLayerManager.ui.errorRoll 300 265		
				) catch(
				messageBox "Crikey, there was an error loading the error report window." title:"Nested Layer Manager"
			)
			
		),
		
		function buildErrorRoll = (
			rollout errorRoll "Error Report" (
				label lbl_1 "Nested Layer Manager has experienced an unexpected error and will close. Your folder structure has been saved. \nWould you like to send an online log report? All reports are strictly confidential and any user information included will not be shared." \
				width:270 height:85 pos:[15,15]
				label lbl_2 "Extra User Information: (What did you last press/do?)" align:#left
				dotNetControl editText "TextBox" height:100
				button btn_send "Send" across:2 width:135
				button btn_cancel "Cancel" width:135
				
				on btn_send pressed do (
					try ( nestedLayerManager.error.sendErrorReport editText.text ) catch()
				)
				on btn_cancel pressed do (
					try ( destroyDialog nestedLayerManager.ui.errorRoll ) catch()
				)
				on errorRoll close do (
					try ( nestedLayerManager.error.disposeNestedLayerManager() ) catch()
				)
				on errorRoll open do (
					editText.multiLine = true
					editText.acceptsReturn = true
					editText.acceptsTab = true
					editText.scrollBars = editText.scrollBars.vertical
				)
				on editText keyUp s e do (
					if e.KeyCode == e.KeyCode.Enter do s.selectedtext = (dotNetClass "System.Environment").newline
				)
			)
			nestedLayerManager.ui.errorRoll = errorRoll
		),
		
		function sendErrorReport userText = (
			
			--Find Max Version (Look at EXE through dotNet as this provides more information such as service pack version)
			try (
				local versinfo = dotnetclass "System.Diagnostics.FileVersionInfo"
				local myFI = versinfo.GetVersionInfo (pathConfig.appendPath (pathConfig.GetDir #maxroot) "3dsmax.exe")
				local maxExeVersion = myFI.FileVersion
			) catch ()
			
			--Find Operating System Version
			try (
				local osVersion = (dotNEtClass "System.Environment").osVersion.versionString
			) catch ()
				
			local getLayerHtCount = nestedLayerManager.io.getLayerHndHt.count
			local getLayerNodeHtCount = nestedLayerManager.io.getLayerNodeHt.count
			local getObjectHtCount = nestedLayerManager.io.getObjectHndHt.count
			local getObjectNodeHtCount = nestedLayerManager.io.getObjectNodeHt.count
			local errorLog = stringStream ""
			local reOpenNLM = true
			local reLoad = true
			
			format "Nested Layer Manager Error Report Log \n" to:errorLog
			format "\n" to:errorLog
			format "User Comment:\n" to:errorLog
			format "%\n" userText to:errorLog
			format "\n" to:errorLog
			format "3ds Max Version: %\n" (maxExeVersion as string) to:errorLog
			format "Windows Version: %\n" (osVersion as string) to:errorLog
			format "\n" to:errorLog
			format "Nested Version: %\n" (nestedLayerManager.version() as string) to:errorLog
			format "Nested Data Version: %\n" (nestedLayerManager.dataVersion() as string) to:errorLog
			format "Date & Time: %" localTime to:errorLog
			format "\n" to:errorLog
			format "Max Layer Count: %\n" (layerManager.count as string) to:errorLog
			format "Nested getLayerHndHt Count: %\n" (getLayerHtCount as string) to:errorLog
			format "Nested getLayerNodeHt Count: %\n" (getLayerNodeHtCount as string) to:errorLog
			format "\n" to:errorLog
			format "Max Object Count: %\n" ($*.count as string) to:errorLog
			format "Nested getObjectHndHt Count: %\n" (getObjectHtCount as string) to:errorLog
			format "Nested getObjectNodeHt Count: %\n" (getObjectNodeHtCount as string) to:errorLog
			format "\n" to:errorLog
			format "Error Occured In: %\n" (nestedLayerManager.error.errorMessage as string) to:errorLog
			format "\n" to:errorLog
			format "Exception Information:\n" to:errorLog
			format "%\n" (nestedLayerManager.error.currentException as string) to:errorLog
			format "\n" to:errorLog
			format "Stack Information:\n" to:errorLog
			stack to:errorLog

			--Email error log
			Client = dotNetObject "System.Net.Mail.SmtpClient"
			Client.Host = "venice.footholds.net"

			NetworkCred = dotNetObject "System.Net.NetworkCredential" "bugs@timsportfolio.co.uk" "WU66pAKhGrBH0qdcl6"

			Client.UseDefaultCredentials = false
			Client.Credentials = NetworkCred
			Client.Port = 26
			client.timeOut = 5000

			MailMessage = dotNetObject "System.Net.Mail.MailMessage"
			MailMessage.From = (dotNetObject "System.Net.Mail.MailAddress" "bugs@timsportfolio.co.uk")
			MailMessage.To.Add  (dotNetObject "System.Net.Mail.MailAddress" "bugs@timsportfolio.co.uk")
			MailMessage.Subject = "Nested Layer Manager Error Log"
			MailMessage.Body = (errorLog as string)
			
			try (
				Client.Send MailMessage
				messageBox "Error Report Sent. Thank you." title:"Nested Layer Manager"
			) catch (
				messageBox "Unable to send Error Report. No network access." title:"Nested Layer Manager"
			)
			
			destroyDialog nestedLayerManager.ui.errorRoll 
			
		),
		
		function disposeNestedLayerManager = (
			try (	nestedLayerManager.io.save()							 		) catch ()			
			try ( cui.unRegisterDialogBar nestedLayerManager.ui.nlmRoll	) catch ()
			try ( destroyDialog nestedLayerManager.ui.nlmRoll					) catch ()
			try ( destroyDialog nestedLayerManager.ui.settingsRoll			) catch ()
			try ( destroyDialog nestedLayerManager.ui.infoRoll					) catch ()
			try ( destroyDialog nestedLayerManager.ui.layerPropertiesRoll	) catch ()
			try (	nestedLayerManager.io.getLayerHndHt.clear()				) catch ()
			try (	nestedLayerManager.io.getLayerNodeHt.clear()				) catch ()		
			try (	nestedLayerManager.ui.mf.dispose()							) catch ()
			try (	nestedLayerManager.ui.tl.dispose()								) catch ()
			try ( for a in nestedLayerManager.ui.btns do a.dispose() 		) catch ()
			
			try (
				nestedLayerManager = undefined
				gc light:true
			) catch()
			
			updateToolBarButtons()
			enableAccelerators = true
		),
		
		--Warn user of save error, resulting in potential data loss :/
		function saveError = (
			messageBox "Yikes. An error occured whilst trying to save Nested Layer Manager. Please save this file iteratively to avoid any potential data loss." \
			title:"Nested Layer Manager"
		)
		
	)--End Struct
	
	nestedLayerManager.error = nestedLayerManagerErrorHandlingStruct()
	
)