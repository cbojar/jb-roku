Sub ShowQualityDialog( title="Select Quality", text="Select video quality:" )
	port = CreateObject( "roMessagePort" )
	dialog = CreateObject( "roMessageDialog" )
	dialog.SetMessagePort( port )

	dialog.SetTitle( title )
	dialog.SetText( text )
	dialog.AddButton( 1, "High Quality" )
	dialog.AddButton( 2, "Low Quality" )
	dialog.AddButton( 3, "Cancel" )
	dialog.Show()

	while true
		dlgMsg = wait( 0, dialog.GetMessagePort() )
		if type( dlgMsg ) = "roMessageDialogEvent"
			if dlgMsg.GetIndex() = 1
				RegDelete( "quality" )
				print "Quality set to HQ"
			else if dlgMsg.GetIndex() = 2
				RegWrite( "quality", "1" )
				print "Quality set to LQ"
			end if
			exit while
		end if
	end while
End Sub
