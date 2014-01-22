sub Main()
	app = CreateObject( "roAppManager" )
	app.setTheme( LoadTheme() )
	categories = LoadConfig()

	ShowPosterScreen( categories )
end sub

function LoadTheme()
	theme = CreateObject( "roAssociativeArray" )
	theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.jpg"
	theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.jpg"
	theme.OverhanglogoHD = "pkg:/images/Logo_Overhang_JB_HD.png"
	theme.OverhanglogoSD = "pkg:/images/Logo_Overhang_JB_SD.png"

	theme.OverhangPrimaryLogoOffsetHD_X = "60"
	theme.OverhangPrimaryLogoOffsetHD_Y = "40"

	theme.OverhangPrimaryLogoOffsetSD_X = "60"
	theme.OverhangPrimaryLogoOffsetSD_Y = "40"

	backgroundColor = "#E0E0E0"
	primaryTextColor = "#333333"
	secondaryTextColor = "#666666"
	tertiaryTextColor = "#999999"

	theme.backgroundColor = ValidStr( backgroundColor )
	theme.breadcrumbTextLeft = ValidStr( primaryTextColor )
	theme.breadcrumbDelimiter = ValidStr( primaryTextColor )
	theme.breadcrumbTextRight = ValidStr( primaryTextColor )

	theme.posterScreenLine1Text = ValidStr( primaryTextColor )
	theme.posterScreenLine2Text = ValidStr( secondaryTextColor )
	theme.episodeSynopsisText = ValidStr( secondaryTextColor )

	theme.springboardTitleText = ValidStr( primaryTextColor )
	theme.springboardSynopsisColor = ValidStr( secondaryTextColor )
	theme.springboardRuntimeColor = ValidStr( tertiaryTextColor )
	theme.springboardDirectorColor = ValidStr( tertiaryTextColor )
	theme.springboardDirectorLabelColor = ValidStr( tertiaryTextColor )
	theme.springboardActorColor = ValidStr( tertiaryTextColor )

	return theme
end function

function LoadConfig()
	result = []

	result.push( GetLiveStream() )

	opml = CreateObject( "roXMLElement" )
	raw = NWM_UT_GetStringFromURL( "http://roku.jupitercolony.com/opml.xml" ) ' Pull configuration from a remote config file
	if opml.Parse( raw )
		for each category in opml.body.outline
			result.Push( BuildCategory( category ) )
		next
	else ' Fallback if cannot contact server, find file, or parse
		raw = ReadASCIIFile("pkg:/config.opml") ' Pull configuration from a local config file
		if opml.Parse( raw )
			for each category in opml.body.outline
				result.Push( BuildCategory( category ) )
			next
		end if
		ShowMessageDialog( "Cannot Connect", "Cannot connect to server. Please check your connection and try again." )
	end if

	result.push( GetQualityIcon() )

	return result
end function

function BuildCategory( category )
	result = {
		title:			ValidStr( category@title )
		shortDescriptionLine1:	ValidStr( category@title )
		shortDescriptionLine2:	ValidStr( category@subtitle )
		sdPosterURL:		ValidStr( category@img )
		hdPosterURL:		ValidStr( category@img )
		url:			ValidStr( category@url )
		categories:		[]
	}

	if category@hqfeed <> invalid
		result.url = ValidStr( category@hqfeed )
	end if

	quality = RegRead( "quality" )
	if quality <> invalid AND strtoi( ValidStr( quality ) ) = 1
		if category@lqfeed <> invalid
			result.url = ValidStr( category@lqfeed )
		end if
	end if

	if category.outline.Count() > 0
		for each subCategory in category.outline
			result.categories.Push( BuildCategory( subCategory ) )
		next
	end if

	return result
end function

function GetLiveStream()
	result = {
		screenTarget:		"livestream"
		calendar:		"http://roku.jupitercolony.com/live-calendar.xml"
		live:			true
		title:			"Live Stream"
		shortDescriptionLine1:	"Live Stream"
		shortDescriptionLine2:	"Watch Jupiter Broadcasting Live!"
		sdPosterURL:		"pkg:/images/mm_icon_focus_sd.jpg"
		hdPosterURL:		"pkg:/images/mm_icon_focus_hd.jpg"
		contentType:		"episode"
		streamurls:		["http://videocdn-us.geocdn.scaleengine.net/jblive-iphone/live/jblive.stream/playlist.m3u8"]
		streamformat:		"hls"
		streamqualities:	["SD"]
		streambitrates:	[0]
		categories:		[]
	}
	
	result.audio = {
		live:			true
		title:			"Audio Stream"
		shortDescriptionLine1:	"Audio Stream"
		shortDescriptionLine2:	"Listen To JB Radio Live!"
		sdPosterURL:		"pkg:/images/mm_icon_focus_sd.jpg"
		hdPosterURL:		"pkg:/images/mm_icon_focus_hd.jpg"
		contentType:		"episode"
		streamurls:		["http://jbradio.out.airtime.pro:8000/jbradio_a"]
		streamformat:		"mp3"
		streambitrates:	[0]
		streamqualities:	["SD"]
		categories:		[]
	}

	return result
end function

function GetQualityIcon()
	result = {
		screenTarget:		"quality"
		title:			"Quality"
		shortDescriptionLine1:	"Quality"
		shortDescriptionLine2:	"Currently set to HQ"
		sdPosterURL:		"pkg:/images/settings.png"
		hdPosterURL:		"pkg:/images/settings.png"
		contentType:		"episode"
		categories:		[]
	}

	quality = RegRead( "quality" )
	if( quality <> invalid AND strtoi( ValidStr( quality ) ) = 1 )
		result.shortDescriptionLine2 = "Currently set to LQ (mobile quality)"
	end if

	return result
end function
