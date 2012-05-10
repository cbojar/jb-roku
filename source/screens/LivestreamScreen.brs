function ShowLivestreamScreen( livestream )
	screen = CreateObject( "roSpringboardScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )	

	'screen.setAdURL( sdAd, hdAd )
	'screen.setAdSelectable( false )

	screen.SetStaticRatingEnabled( false )
	screen.AddButton( 1, "Play" )
	screen.SetContent( livestream )
	screen.Show()

	raw = NWM_UT_GetStringFromURL( livestream.calendar )
	calendar = CreateObject( "roXMLElement" )
	if calendar.Parse( raw )
		islive = false
		nextevent = invalid
		now = CreateObject( "roDateTime" )
		now.mark()
		now_s = now.asSeconds()

		for each event in calendar.Event
			estart = strtoi( ValidStr( event.start.GetText() ) )
			efinish = strtoi( ValidStr( event.finish.GetText() ) )
			if nextevent = invalid
				nextevent = event
			else
				nestart = strtoi( ValidStr( nextevent.start.GetText() ) )
				if estart < nestart AND efinish > now_s
					nextevent = event
				end if
			end if
		next
		nestart = strtoi( ValidStr( nextevent.start.GetText() ) )
		nefinish = strtoi( ValidStr( nextevent.finish.GetText() ) )
		islive = ( nestart < now_s AND nefinish > now_s )
		desc = strReplace( nextevent.summary.GetText(), "LIVE: ", "" )
		if islive
			desc = "LIVE NOW: " + desc
		else
			nextlive = CreateObject( "roDateTime" )
			nextlive.fromSeconds( nestart )
			nextlive.toLocalTime()
			desc = "Next Live Show:" + nl() + desc + " ("
			desc = desc + nextlive.asDateString( "long-date" ) + " "
			desc = desc + itostr( nextlive.getHours() ) + ":"
			if nextlive.getMinutes() < 10
				desc = desc + "0"
			end if
			desc = desc + itostr( nextlive.getMinutes() ) + ")"
		end if

		desc = desc + nl() + nl() + "Live pre-shows generally start approximately 15 minutes before shows."

		livestream.shortDescriptionLine2 = desc
		livestream.description = desc		
		screen.SetContent( livestream )
		screen.Show()
	end if

	while true
		msg = wait( 0, screen.GetMessagePort() )
		
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isButtonPressed()
				ShowVideoScreen( livestream )
			endif
		end if
	end while

	return selectedEpisode
end function