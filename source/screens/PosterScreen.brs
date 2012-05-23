sub ShowPosterScreen( contentList, breadcrumb="Jupiter Broadcasting" )
	screen = CreateObject( "roPosterScreen" )
	screen.SetMessagePort( CreateObject( "roMessagePort" ) )
	screen.SetListStyle( "flat-category" )
	screen.SetBreadcrumbText( "", breadcrumb )

	'screen.setAdURL( sdAd, hdAd )
	'screen.setAdSelectable( false )

	screen.SetContentList( contentList )
	screen.Show()
	
	while true
		msg = wait( 0, screen.GetMessagePort() )

		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isListItemSelected()
				selectedItem = contentList[msg.Getindex()]
				if selectedItem.screenTarget = "video"
					ShowVideoScreen( selectedItem )
				else if selectedItem.screenTarget = "livestream"
					ShowLivestreamScreen( selectedItem )
				else if selectedItem.screenTarget = "quality"
					ShowQualityDialog()
					contentList = LoadConfig()
					screen.SetContentList( contentList )
					screen.Show()
				else if selectedItem.screenTarget = "paragraph"
					ShowParagraphScreen( selectedItem )
				else if selectedItem.categories <> invalid and selectedItem.categories.Count() > 0
					ShowPosterScreen( selectedItem.categories, selectedItem.shortDescriptionLine1 )
				else
					ShowEpisodeScreen( selectedItem, selectedItem.shortDescriptionLine1 )
				end if
			end if
		end if
	end while
end sub
