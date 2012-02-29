sub ShowEpisodeScreen(show, leftBread, rightBread)
	screen = CreateObject("roPosterScreen")
	screen.SetMessagePort(CreateObject("roMessagePort"))
  screen.SetListStyle("flat-episodic")
  screen.SetBreadcrumbText(leftBread, rightBread)
	screen.Show()
	
	mrss = NWM_MRSS(show.url)
	content = mrss.GetEpisodes()
	selectedEpisode = 0
	screen.SetContentList(content)
	screen.Show()

	while true
		msg = wait(0, screen.GetMessagePort())
		
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isListItemFocused()
				selectedEpisode = msg.GetIndex()
			else if msg.isListItemSelected()
				selectedEpisode = ShowSpringboardScreen(content, selectedEpisode, leftBread, "")
				screen.SetFocusedListItem(selectedEpisode)
				'screen.Show()
			else if msg.isRemoteKeyPressed()
        if msg.GetIndex() = 13
					ShowVideoScreen(content[selectedEpisode])
				end if
			end if
		end if
	end while
end sub
