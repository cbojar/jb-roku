function ShowSpringboardScreen( episodes, selectedEpisode )
	screen = CreateObject( "roSpringboardScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )
	screen.SetStaticRatingEnabled( false )
	screen.AddButton( 1, "Play" )
	screen.Show()

	SpringBoardScreen_swapPoster( episodes[selectedEpisode] )
	screen.SetContent( episodes[selectedEpisode] )
	screen.Show()
	SpringBoardScreen_swapPoster( episodes[selectedEpisode] )

	while true
		msg = wait( 0, screen.GetMessagePort() )
		
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isButtonPressed()
				ShowVideoScreen( episodes[selectedEpisode] )
			else if msg.isRemoteKeyPressed()
				if msg.GetIndex() = 4 ' LEFT
					if selectedEpisode = 0
						selectedEpisode = episodes.Count() - 1
					else
						selectedEpisode = selectedEpisode - 1
					end if
					screen.SetContent( episodes[selectedEpisode] )
				else if msg.GetIndex() = 5 ' RIGHT
					if selectedEpisode = episodes.Count() - 1
						selectedEpisode = 0
					else
						selectedEpisode = selectedEpisode + 1
					end if
					screen.SetContent( episodes[selectedEpisode] )
				end if
			end if
		end if
	end while

	return selectedEpisode
end function

sub SpringBoardScreen_swapPoster( show )
	tmp = show.sdPosterURL
	if show.sdPosterURL_hq <> invalid and show.sdPosterURL_hq <> ""
		show.sdPosterURL = show.sdPosterURL_hq
		show.sdPosterURL_hq = tmp
	end if
	tmp = show.hdPosterURL
	if show.hdPosterURL_hq <> invalid and show.hdPosterURL_hq <> ""
		show.hdPosterURL = show.hdPosterURL_hq
		show.hdPosterURL_hq = tmp
	end if
end sub
