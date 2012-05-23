sub ShowEpisodeScreen( show, breadcrumb="" )
	screen = CreateObject( "roPosterScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )
	screen.SetListStyle( "flat-episodic" )
	screen.SetBreadcrumbText( "", breadcrumb )
	screen.Show()

	mrss = NWM_MRSS( show.url )
	content = mrss.GetEpisodes()
	dialogSeen = false
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
				selectedEpisode = ShowSpringboardScreen( content, selectedEpisode )
				screen.SetFocusedListItem( selectedEpisode )
			else if msg.isRemoteKeyPressed()
				if msg.GetIndex() = 13
					ShowVideoScreen( content[selectedEpisode] )
				end if
			end if
		end if
	end while
end sub
