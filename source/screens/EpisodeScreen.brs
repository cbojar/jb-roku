sub ShowEpisodeScreen( show, breadcrumb="" )
	screen = CreateObject( "roPosterScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )
	screen.SetListStyle( "flat-episodic" )
	screen.SetBreadcrumbText( "", breadcrumb )
	screen.Show()

	content = MRSS(show.url).GetEpisodes()
	selectedEpisode = 0
	screen.SetContentList( content )
	screen.Show()

	while true
		msg = wait( 0, screen.GetMessagePort() )
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isListItemFocused()
				selectedEpisode = msg.GetIndex()
			else if msg.isListItemSelected()
				selectedEpisode = CreateSpringboardScreen(content, selectedEpisode).showScreen()
				screen.SetFocusedListItem( selectedEpisode )
			else if msg.isRemoteKeyPressed()
				if msg.GetIndex() = 13
					CreateVideoScreen(content[selectedEpisode]).showScreen()
				end if
			end if
		end if
	end while
end sub
