function CreateVideoScreen(episode as Object)
	instance = CreateObject("roAssociativeArray")

	instance.screen = CreateObject("roVideoScreen")
	instance.messagePort = CreateObject("roMessagePort")
	instance.screen.setMessagePort(instance.messagePort)
	instance.watchedStatusTracker = WatchedStatusTracker()

	instance.episode = episode

	instance.showScreen = function()
		m.setTimedEventInterval(15)
		m.showEpisode()
		m.waitForInput()
	end function

	instance.setTimedEventInterval = function(interval as Integer)
		m.screen.SetPositionNotificationPeriod(interval)
	end function

	instance.showEpisode = function()
		m.screen.SetContent(m.episode)
		m.screen.Show()
	end function

	instance.waitForInput = function()
		while true
			msg = wait(0, m.messagePort)
			if msg.isScreenClosed()
				exit while
			else if msg.isRequestFailed()
				print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
			else if msg.isStatusMessage()
				print "Video status: "; msg.GetIndex(); " " msg.GetData() 
			else if msg.isButtonPressed()
				print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
			else if msg.isPlaybackPosition() and m.episode.live <> true then
				m.updateSavePoint(msg.GetIndex())
				print "Marked progress: "; msg.GetIndex()
			else if msg.isFullResult() then
				m.removeSavePoint()
			end if
		end while
	end function

	instance.updateSavePoint = function(currentPosition)
		m.watchedStatusTracker.saveProgress(m.episode.title, currentPosition)
	end function

	instance.removeSavePoint = function()
		m.watchedStatusTracker.removeProgress(m.episode.title)
	end function

	return instance
end function
