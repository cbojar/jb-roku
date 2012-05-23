sub ShowParagraphScreen( show )
	port = CreateObject( "roMessagePort" )
	screen = CreateObject( "roParagraphScreen" )
	screen.SetMessagePort( port )

	screen.SetTitle( show.title )
	screen.AddHeaderText( show.shortDescriptionLine1 )
	for each p in show.paragraphs
		screen.AddParagraph( p )
	next
	screen.AddButton(1, "Return")
	screen.Show()

	while true
		msg = wait( 0, screen.GetMessagePort() )
		if type( msg ) = "roParagraphScreenEvent"
			exit while
		endif
	end while
End sub
