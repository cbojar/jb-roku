Sub ShowMessageDialog( title="", text="" )
	port = CreateObject( "roMessagePort" )
	dialog = CreateObject( "roMessageDialog" )
	dialog.SetMessagePort( port )

	dialog.SetTitle( title )
	dialog.SetText( text )
	dialog.AddButton( 1, "Close" )
	dialog.Show()

	while true
		dlgMsg = wait( 0, dialog.GetMessagePort() )
		if type( dlgMsg ) = "roMessageDialogEvent"
			exit while
		end if
	end while
End Sub

