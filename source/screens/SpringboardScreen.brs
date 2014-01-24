function CreateSpringboardScreen(episodes, selectedEpisodeIndex)
	instance = CreateObject("roAssociativeArray")
	
	instance.screen = CreateObject("roSpringboardScreen")
	instance.messagePort = CreateObject("roMessagePort")
	instance.screen.SetMessagePort(instance.messagePort)
	instance.watchedStatusTracker = WatchedStatusTracker()
	instance.lastMessage = invalid
	instance.screen.SetStaticRatingEnabled(false)

	instance.episodes = episodes
	instance.selectedEpisodeIndex = selectedEpisodeIndex

	instance.getSelectedEpisode = function()
		return m.episodes[m.selectedEpisodeIndex]
	end function

	instance.showScreen = function()
		m.showAds()
		m.showEpisode()
		m.waitForInput()
		
		return m.selectedEpisodeIndex
	end function

	instance.showAds = function()
		'Don't show ads, really
		'm.screen.setAdURL(sdAd, hdAd)
		'm.screen.setAdSelectable(false)
		x = 0 'Don't break the editor
	end function

	instance.showEpisode = function()
		episode = m.getSelectedEpisode()
	    m.setButtons()

	    m.swapPoster()
	    m.screen.SetContent(episode)
	    m.screen.Show()
	    m.swapPoster()
	end function

	instance.swapPoster = function()
		episode = m.getSelectedEpisode()
		tmp = episode.sdPosterURL
		if episode.sdPosterURL_hq <> invalid and episode.sdPosterURL_hq <> ""
			episode.sdPosterURL = episode.sdPosterURL_hq
			episode.sdPosterURL_hq = tmp
		end if
		tmp = episode.hdPosterURL
		if episode.hdPosterURL_hq <> invalid and episode.hdPosterURL_hq <> ""
			episode.hdPosterURL = episode.hdPosterURL_hq
			episode.hdPosterURL_hq = tmp
		end if
	end function

	instance.setButtons = function()
		episode = m.getSelectedEpisode()
		m.screen.ClearButtons()
		if m.isPartiallyWatched() then
			m.screen.AddButton(1, "Resume Playing")
			m.screen.AddButton(2, "Play from Beginning")
		else
			m.screen.AddButton(2, "Play")
		end if
	end function

	instance.isPartiallyWatched = function()
		episode = m.getSelectedEpisode()
		return m.watchedStatusTracker.hasProgress(episode.title)
	end function

	instance.waitForInput = function()
		episode = m.getSelectedEpisode()
		while m.hasNonExitMessage()
			m.processMessage()
		end while
	end function

	instance.processMessage = function()
		msg = m.getLastMessage()
		if msg = invalid then
			return invalid
		end if
		
		if msg.isButtonPressed()
			m.processButtonPress()
		else if msg.isRemoteKeyPressed()
			m.processRemoteKeyPress()
		end if
	end function

	instance.getLastMessage = function()
		return m.lastMessage
	end function

	instance.processButtonPress = function()
		msg = m.getLastMessage()
		episode = m.getSelectedEpisode()
		if msg.GetIndex() = 1
			PlayStart = m.watchedStatusTracker.getProgress(episode.title)
			if PlayStart > 0 then
				episode.PlayStart = PlayStart
			end if
		else if msg.GetIndex() = 2
			m.watchedStatusTracker.removeProgress(episode.title)
			episode.PlayStart = 0
		end if
		ShowVideoScreen(episode)
		m.setButtons()
		m.screen.Show()
	end function

	instance.processRemoteKeyPress = function()
		msg = m.getLastMessage()
		if msg.GetIndex() = 4 ' LEFT
			m.movePreviousEpisode()
		else if msg.GetIndex() = 5 ' RIGHT
			m.moveNextEpisode()
		end if
		m.showEpisode()
	end function

	instance.hasNonExitMessage = function()
		m.lastMessage = wait(0, m.messagePort)
		return m.lastMessage = invalid or not m.lastMessage.isScreenClosed()
	end function

	instance.moveNextEpisode = function()
		if m.selectedEpisodeIndex = m.episodes.Count() - 1
			m.selectedEpisodeIndex = 0
		else
			m.selectedEpisodeIndex = m.selectedEpisodeIndex + 1
		end if
		
		return m.selectedEpisodeIndex
	end function
	
	instance.movePreviousEpisode = function()
		if m.selectedEpisodeIndex = 0
			m.selectedEpisodeIndex = m.episodes.Count() - 1
		else
			m.selectedEpisodeIndex = m.selectedEpisodeIndex - 1
		end if
		
		return m.selectedEpisodeIndex
	end function
	
	return instance
end function
