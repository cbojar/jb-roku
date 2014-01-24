''	Usage:
''		mrss = MRSS("http://www.example.com/mrss_feed.xml")	' iniitialize a NWM_MRSS object
'''		episodes = mrss.GetEpisodes() 	' get all episodes found in the MRSS feed

function MRSS(url)
	this = {
		url: url
		utils: NWM_Utilities()
	}

	' Build an array of content-meta-data objects suitable for passing to roPosterScreen::SetContentList()
	this.GetEpisodes = function()
		result = []
		
		if InStr(1, m.url, "http://") = 1
			raw = NWM_GetStringFromURL(m.url)
		else
			raw = ReadASCIIFile(m.url)
		end if
	
		xml = CreateObject("roXMLElement")
		if xml.Parse(raw)
			channelThumbnail = m.getChannelThumbnail(xml.channel)
	
			for each item in xml.channel.item
				newItem = m.processItem(item)

				' Default thumbnail (from channel)
				newItem.sdPosterURL = ValidStr(channelThumbnail)
				newItem.hdPosterURL = ValidStr(channelThumbnail)

				result.Push(newItem)
			next
		end if
		
		return result
	end function
	
	this.getChannelThumbnail = function(channel)
		channelThumbnail = ""
		if channel.image.url.Count() > 0 ' RSS standard image tag
			channelThumbnail = channel.image.url.GetText()
		else
			tmp = channel.GetNamedElements("media:thumbnail") ' MRSS media tag
			if tmp.Count() > 0
				channelThumbnail = tmp[0]@url
			else
				tmp = channel.GetNamedElements("itunes:image") ' Less-than-standard iTunes image tag
				if tmp.Count() > 0
					channelThumbnail = tmp[0]@href
				end if
			end if
		end if
		
		return ValidStr(channelThumbnail)
	end function

	this.processItem = function(item)
		newItem = {
			streams:	[]
			streamFormat:	"mp4"
			actors:		[]
			categories:	[]
			contentType:	"episode"
		}

		newItem.title = m.getItemTitle(item)
		newItem.shortDescriptionLine1 = newItem.title
		
		newItem.description = m.getItemDescription(item)
		newItem.synopsis = newItem.description

		newItem.sdPosterURL_hq = m.getItemThumbnail(item)
		newItem.hdPosterURL_hq = newItem.sdPosterURL_hq

		newItem.releaseDate = m.getItemReleaseDate(item)
		
		newItem.streams = m.getItemStreams(item)

		return newItem
	end function

	this.getItemTitle = function(item)
		xmlElement = item.GetNamedElements("media:title")
		if xmlElement.Count() > 0
			xmlElement = xmlElement[0]
		else
			xmlElement = item.title
		end if

		return m.utils.HTMLEntityDecode(ValidStr(xmlElement.GetText()))
	end function

	this.getItemDescription = function(item)
		xmlElement = item.GetNamedElements("media:description")
		if xmlElement.Count() > 0
			xmlElement = xmlElement[0]
		else
			xmlElement = item.description
		end if

		description = m.utils.HTMLEntityDecode(m.utils.HTMLStripTags(ValidStr(xmlElement.GetText())))
		' Strip newlines and replace with spaces to get more text on the screen
		description = regexReplaceAll( description, "(\r?\n)+", " ", "" )

		return description
	end function

	this.getItemThumbnail = function(item)
		' hq thumbnail
		xmlElement = item.GetNamedElements("media:thumbnail") 
		if xmlElement.Count() > 0
			xmlElement = xmlElement[0]
		else
			return ""
		end if

		return ValidStr(xmlElement@url)
	end function

	this.getItemReleaseDate = function(item)
		return ValidStr(item.pubdate.GetText())
	end function

	this.getItemStreams = function(item)
		streamsList = []

		' media:content can be a child of <item> or of <media:group>
		contentItems = item.GetNamedElements("media:content")
		if contentItems.Count() = 0
			tmp = item.GetNamedElements("media:group")
			if tmp.Count() > 0
				contentItems = tmp.GetNamedElements("media:content")
			end if
		end if
		
		if contentItems.Count() > 0
			for each content in contentItems
				if ValidStr(content@url) <> ""
					streamsList.push({
						url: ValidStr(content@url)
						bitrate: StrToI(ValidStr(content@bitrate))
					})
				end if
			next
		else if item.enclosure.Count() > 0
			' we didn't find any media:content tags, try the enclosure tag
			streamsList.push({
				url:	ValidStr(item.enclosure@url)
			})
		end if

		return streamsList
	end function

	return this
end function
