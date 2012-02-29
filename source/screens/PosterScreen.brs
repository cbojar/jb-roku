sub ShowPosterScreen(contentList, breadLeft, breadRight)
	screen = CreateObject("roPosterScreen")
	screen.SetMessagePort(CreateObject("roMessagePort"))
  screen.SetListStyle("flat-category")
  screen.SetBreadcrumbText(breadLeft, breadRight)
	screen.Show()
	
	screen.SetContentList(contentList)
	screen.Show()
	
	while true
		msg = wait(0, screen.GetMessagePort())
		
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isListItemSelected()
				selectedItem = contentList[msg.Getindex()]
				if selectedItem.categories.Count() > 0
					ShowPosterScreen(selectedItem.categories, selectedItem.shortDescriptionLine1, "")
				else
					ShowEpisodeScreen(selectedItem, selectedItem.shortDescriptionLine1, "")
				end if
			end if
		end if
	end while
end sub
