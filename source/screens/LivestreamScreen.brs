function CreateLivestreamScreen(livestream)
	instance = CreateObject("roAssociativeArray")

	instance.screen = CreateObject("roSpringboardScreen")
	instance.messagePort = CreateObject("roMessagePort")
	instance.screen.SetMessagePort(instance.messagePort)
	instance.audioStream = CreateAudioPlayer(instance.messagePort)
	instance.audioStream.SetStream(livestream.audio)

	instance.livestream = livestream

	instance.showScreen = function()
		m.showStars()
		m.showAds()
		m.setButtons(false)
		m.showEpisode() ' Show data so far
		m.fetchCalendar()
		m.showEpisode()
		m.waitForInput()
	end function

	instance.showStars = function()
		' Disable star ratings
		m.screen.SetStaticRatingEnabled(false)
	end function
	
	instance.showAds = function()
		'Don't show ads, really
		'm.screen.setAdURL(sdAd, hdAd)
		'm.screen.setAdSelectable(false)
		x = 0 'Don't break the editor
	end function
	
	instance.setButtons = function(isAudioPlaying)
		m.screen.ClearButtons()
		if isAudioPlaying
			m.screen.AddButton(3, "Stop Listening")
		else
			m.screen.AddButton(1, "Watch")
			m.screen.AddButton(2, "Listen")
		end if
	end function

	instance.showEpisode = function()
		' Set content to live stream (automatically parses array)
		m.screen.SetContent(m.livestream)
		m.screen.Show()
	end function

	instance.fetchCalendar = function()
		calendarRaw = m.getRawCalendar()
		calendar = m.parseRawCalendar(calendarRaw)
		desc = m.getDescriptionWithCalendar(calendar)
		m.updateDescriptionWithCalendar(desc)
	end function
	
	instance.getRawCalendar = function()
		return NWM_UT_GetStringFromURL(m.livestream.calendar)
	end function

	instance.parseRawCalendar = function(calendarRaw)
		calendar = CreateObject("roXMLElement")
		if not calendar.Parse(calendarRaw)
			return invalid
		end if
		return calendar
	end function

	instance.getDescriptionWithCalendar = function(calendar)
		if calendar = invalid
			return "Calendar could not be loaded."
		end if

		nextEvent = m.getNextEvent(calendar)
		isLive = m.isEventLive(nextEvent)
		desc = m.getEventDescription(nextEvent, isLive)
		
		return desc
	end function
	
	instance.getNowInSeconds = function()
		now = CreateObject("roDateTime")
		now.mark()
		return now.asSeconds()
	end function

	instance.getNextEvent = function(calendar)
		now = m.getNowInSeconds()
		nextEvent = invalid

		for each event in calendar.Event
			eventStart = m.parseXMLTime(event.start.GetText())
			eventFinish = m.parseXMLTime(event.finish.GetText())
			' If nextevent is not set, set to current event (first run)
			if nextEvent = invalid
				nextEvent = event
			else
				nextEventStart = m.parseXMLTime(nextEvent.start.GetText())
				' If event starts before nextevent and finishes after current time
				if eventStart < nextEventStart AND eventFinish > now
					nextEvent = event
				end if
			end if
		next
		
		return {
			start: m.parseXMLTime(nextEvent.start.getText())
			finish: m.parseXMLTime(nextEvent.finish.getText())
			summary: strReplace(nextevent.summary.GetText(), "LIVE: ", "") ' Remove "Live:" portions from description
		}
	end function

	instance.parseXMLTime = function(xmlTime)
		return strtoi(ValidStr(xmlTime))
	end function

	instance.isEventLive = function(event)
		now = m.getNowInSeconds()

		' If event starts before now and ends after now, it is live
		return (event.start < now AND event.finish > now)
	end function

	instance.getEventDescription = function(event, isLive)
		desc = event.summary

		if islive
			desc = "LIVE NOW: " + desc
		else
			whenLive = CreateObject("roDateTime")
			whenLive.fromSeconds(event.start)
			whenLive.toLocalTime()

			' Show next live show name and date
			desc = "Next Live Show: " + desc + nl()
			desc = desc + whenLive.asDateString("long-date") + " "

			' Show next live show time (24hr)
			desc = desc + m.get24HourTimeString(whenLive.getHours(), whenLive.getMinutes())

			' Show next live show time (12hr)
			desc = desc + " (" + m.get12HourTimeString(whenLive.getHours(), whenLive.getMinutes()) + ")"
		end if

		desc = desc + nl() + nl() + "Live pre-shows generally start approximately 15 minutes before shows."

		return desc
	end function

	instance.get24HourTimeString = function(hours, minutes)
		timestr = itostr(hours) + ":"
		if minutes < 10 ' If less than 10 minutes, add leading zero
			timestr = timestr + "0"
		end if
		timestr = timestr + itostr(minutes)
		
		return timestr
	end function
	
	instance.get12HourTimeString = function(hours, minutes)
		timestr = ""
		
		ispm = hours > 11 ' If hours is more than 11, is PM
		if ispm ' If is PM, subtract 12 and show hours
			if hours = 12 ' If is PM and is 12, show 12
				timestr = timestr + "12:"
			else
				timestr = timestr + itostr(hours - 12) + ":"
			end if
		else ' If is AM show hours
			if hours = 0 ' If is AM and is 0, show 12
				timestr = timestr + "12:"
			else
				timestr = timestr + itostr(hours) + ":"
			end if			
		end if

		if minutes < 10 ' If less than 10 minutes, add leading zero
			timestr = timestr + "0"
		end if
		timestr = timestr + itostr(minutes) + " "

		if ispm
			timestr = timestr + "PM"
		else
			timestr = timestr + "AM"
		end if
		
		return timestr
	end function

	instance.updateDescriptionWithCalendar = function(desc)
		m.livestream.shortDescriptionLine2 = desc
		m.livestream.description = desc	
	end function
	
	instance.waitForInput = function()
		while true
			msg = wait(0, m.messagePort)
			if msg <> invalid
				if msg.isScreenClosed()
					m.audioStream.Stop()
					exit while
				else if msg.isButtonPressed()
					if msg.GetIndex() = 1
						m.audioStream.Stop()
						ShowVideoScreen(m.livestream)
					else if msg.GetIndex() = 2
						m.audioStream.Play()
					else if msg.GetIndex() = 3
						m.audioStream.Stop()
					endif
					m.setButtons(m.audioStream.IsPlaying())
				endif
			end if
		end while
	end function

	return instance
end function
