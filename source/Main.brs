sub Main()
	LoadTheme()
	categories = LoadConfig()
	
	if categories.Count() > 1
		ShowPosterScreen( categories )
	else
		ShowEpisodeScreen( categories[0] )
	end if
end sub

sub LoadTheme()
	app = CreateObject( "roAppManager" )
	theme = CreateObject( "roAssociativeArray" )
	theme.OverhangSliceSD = "pkg:/images/Overhang_Slice_SD.png"
	theme.OverhangSliceHD = "pkg:/images/Overhang_Slice_HD.png"
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

	app.SetTheme( theme )
end sub

function LoadConfig()
	result = []

	result.push( GetLiveStream() )

	'raw = ReadASCIIFile("pkg:/config.opml") ' Pull configuration from a local config file
	raw = NWM_UT_GetStringFromURL( "http://cbojar.net/roku/jb/opml.xml" ) ' Pull configuration from a remote config file
	opml = CreateObject( "roXMLElement" )
	if opml.Parse( raw )
		for each category in opml.body.outline
			result.Push( BuildCategory( category ) )
		next
	end if

	result.push( GetLicense() )

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
	
	if category.outline.Count() > 0
		for each subCategory in category.outline
			result.categories.Push( BuildCategory( subCategory ) )
		next
	end if
	
	return result
end function

function GetLiveStream()
	result = {
		screenTarget:		"video"
		title:			"Live Stream"
		shortDescriptionLine1:	"Live Stream"
		shortDescriptionLine2:	"Watch Jupiter Broadcasting Live!"
		sdPosterURL:		"pkg:/images/mm_icon_focus_sd.png"
		hdPosterURL:		"pkg:/images/mm_icon_focus_hd.png"
		streamurls:		["http://videocdn-us.geocdn.scaleengine.net/jblive-iphone/live/jblive.stream/playlist.m3u8"]
		streamformat:		"hls"
		streamqualities:	["HD"]
		streambitrates:		[0]
		categories:		[]
	}

	return result
end function

function GetLicense()
	result = {
		screenTarget:		"paragraph"
		title:			"Licenses"
		shortDescriptionLine1:	"Licenses"
		shortDescriptionLine2:	"Licensing information"
		sdPosterURL:		"pkg:/images/mm_icon_focus_sd.png"
		hdPosterURL:		"pkg:/images/mm_icon_focus_hd.png"
		paragraphs:		[
						"The content of this channel is distributed under a CC-BY-SA license (http://creativecommons.org/licenses/by-sa/3.0/) by Jupiter Broadcasting (www.jupiterbroadcasting.com).",
						"This channel is Copyright (C) 2012 Roku, CBojar, and is released under the terms of the MIT license (http://www.opensource.org/licenses/MIT). The project page can be found at code.google.com/p/jupiterbroadcasting-roku/."
					]
	}

	return result
end function