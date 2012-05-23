function ShowLivestreamScreen( livestream )
	screen = CreateObject( "roSpringboardScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )	

	'screen.setAdURL( sdAd, hdAd )
	'screen.setAdSelectable( false )

	' Disable star ratings
	screen.SetStaticRatingEnabled( false )
	' Add "Play" button
	screen.AddButton( 1, "Play" )
	' Set content to live stream (automatically parses array)
	screen.SetContent( livestream )
	' Show screen
	screen.Show()

	' Fetch calendar feed
	raw = NWM_UT_GetStringFromURL( livestream.calendar )
	' Parse calendar feed
	calendar = CreateObject( "roXMLElement" )
	if calendar.Parse( raw )
		islive = false
		nextevent = invalid
		now = CreateObject( "roDateTime" )
		now.mark()
		now_s = now.asSeconds()

		for each event in calendar.Event
			' Parse start and end times into ints
			estart = strtoi( ValidStr( event.start.GetText() ) )
			efinish = strtoi( ValidStr( event.finish.GetText() ) )
			' If nextevent is not set, set to current event (first run)
			if nextevent = invalid
				nextevent = event
			else
				' Parse event's start time
				nestart = strtoi( ValidStr( nextevent.start.GetText() ) )
				' If event starts before nextevent and finishes after current time
				if estart < nestart AND efinish > now_s
					nextevent = event
				end if
			end if
		next
		nestart = strtoi( ValidStr( nextevent.start.GetText() ) )
		nefinish = strtoi( ValidStr( nextevent.finish.GetText() ) )

		islive = ( nestart < now_s AND nefinish > now_s ) ' If event starts before now and ends after now, it is live
		desc = strReplace( nextevent.summary.GetText(), "LIVE: ", "" ) ' Remove "Live:" portions from description
		if islive
			desc = "LIVE NOW: " + desc
		else
			nextlive = CreateObject( "roDateTime" )
			nextlive.fromSeconds( nestart )
			nextlive.toLocalTime()

			' Show next live show name and date
			desc = "Next Live Show: " + desc + nl()
			desc = desc + nextlive.asDateString( "long-date" ) + " "

			' Show next live show time (24hr)
			desc = desc + itostr( nextlive.getHours() ) + ":"
			if nextlive.getMinutes() < 10 ' If less than 10 minutes, add leading zero
				desc = desc + "0"
			end if
			desc = desc + itostr( nextlive.getMinutes() )

			' Show next live show time (12hr)
			ispm = nextlive.getHours() > 11 ' If hours is more than 11, is PM
			desc = desc + " ("
			if ispm ' If is PM, subtract 12 and show hours
				if nextlive.getHours() = 12 ' If is PM and is 12, show 12
					desc = desc + "12:"
				else
					desc = desc + itostr( nextlive.getHours() - 12 ) + ":"
				end if
			else ' If is AM show hours
				if nextlive.getHours() = 0 ' If is AM and is 0, show 12
					desc = desc + "12:"
				else
					desc = desc + itostr( nextlive.getHours() ) + ":"
				end if			
			end if
			if nextlive.getMinutes() < 10 ' If less than 10 minutes, add leading zero
				desc = desc + "0"
			end if
			desc = desc + itostr( nextlive.getMinutes() ) + " "
			if ispm ' If is PM, show PM
				desc = desc + "PM"
			else ' If is AM, show AM
				desc = desc + "AM"
			end if
			desc = desc + ")"
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
