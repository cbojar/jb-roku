Function ShowLoadingDialog( title="", showBusy = false ) As Object
	dialog = CreateObject( "roOneLineDialog" )

	dialog.SetTitle( title )
	if showBusy
		dialog.ShowBusyAnimation()
	end if
	dialog.Show()
	
	return dialog
End Function
