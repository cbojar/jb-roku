'**********************************************************
'' Video Player Example Application - URL Utilities 
'' November 2009
'' Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'*********************************************************
' Constucts a URL Transfer object
'*********************************************************
Function CreateURLTransferObject(url As String) as Object
	obj = CreateObject("roUrlTransfer")
	obj.SetPort(CreateObject("roMessagePort"))
	obj.SetUrl(url)
	obj.AddHeader("Content-Type", "application/x-www-form-urlencoded")
	obj.EnableEncodings(true)
	return obj
End Function

'*********************************************************
' Url Query builder
' so this is a quick and dirty name/value encoder/accumulator
'*********************************************************
Function NewHttp(url As String) as Object
	obj = CreateObject("roAssociativeArray")
	obj.Http = CreateURLTransferObject(url)
	obj.FirstParam = true
	obj.AddParam = http_add_param
	obj.AddRawQuery = http_add_raw_query
	obj.GetToStringWithRetry = http_get_to_string_with_retry
	obj.PrepareUrlForQuery = http_prepare_url_for_query
	obj.GetToStringWithTimeout = http_get_to_string_with_timeout
	obj.PostFromStringWithTimeout = http_post_from_string_with_timeout

	if Instr(1, url, "?") > 0 then obj.FirstParam = false
	return obj
End Function

'*********************************************************
' Constucts a URL Transfer object 2
'*********************************************************
Function CreateURLTransferObject2(url As String, contentHeader As String) as Object
	obj = CreateObject("roUrlTransfer")
	obj.SetPort(CreateObject("roMessagePort"))
	obj.SetUrl(url)
	obj.AddHeader("Content-Type", contentHeader)
	obj.EnableEncodings(true)
	return obj
End Function

'*********************************************************
' Url Query builder 2
' so this is a quick and dirty name/value encoder/accumulator
'*********************************************************
Function NewHttp2(url As String, contentHeader As String) as Object
	obj = CreateObject("roAssociativeArray")
	obj.Http = CreateURLTransferObject2(url, contentHeader)
	obj.FirstParam = true
	obj.AddParam = http_add_param
	obj.AddRawQuery = http_add_raw_query
	obj.GetToStringWithRetry = http_get_to_string_with_retry
	obj.PrepareUrlForQuery = http_prepare_url_for_query
	obj.GetToStringWithTimeout = http_get_to_string_with_timeout
	obj.PostFromStringWithTimeout = http_post_from_string_with_timeout

	if Instr(1, url, "?") > 0 then obj.FirstParam = false
	return obj
End Function

'*********************************************************
' HttpEncode - just encode a string
'*********************************************************
Function HttpEncode(str As String) As String
	o = CreateObject("roUrlTransfer")
	return o.Escape(str)
End Function

'*********************************************************
' Prepare the current url for adding query parameters
' Automatically add a '?' or '&' as necessary
'*********************************************************
Function http_prepare_url_for_query() As String
	url = m.Http.GetUrl()
	if m.FirstParam then
		url = url + "?"
		m.FirstParam = false
	else
		url = url + "&"
	endif
	m.Http.SetUrl(url)
	return url
End Function

'*********************************************************
' Percent encode a name/value parameter pair and add the
' the query portion of the current url
' Automatically add a '?' or '&' as necessary
' Prevent duplicate parameters
'*********************************************************
Function http_add_param(name As String, val As String) as Void
	q = m.Http.Escape(name)
	q = q + "="
	url = m.Http.GetUrl()
	if Instr(1, url, q) > 0 return ' Parameter already present
	q = q + m.Http.Escape(val)
	m.AddRawQuery(q)
End Function

'*********************************************************
' Tack a raw query string onto the end of the current url
' Automatically add a '?' or '&' as necessary
'*********************************************************
Function http_add_raw_query(query As String) as Void
	url = m.PrepareUrlForQuery()
	url = url + query
	m.Http.SetUrl(url)
End Function

'*********************************************************
' Performs Http.AsyncGetToString() in a retry loop
' with exponential backoff. To the outside
' world this appears as a synchronous API.
'*********************************************************
Function http_get_to_string_with_retry() as String
	timeout% = 1500
	num_retries% = 5

	str = ""
	while num_retries% > 0
		' print "httpget try " + itostr(num_retries%)
		if (m.Http.AsyncGetToString())
			event = wait(timeout%, m.Http.GetPort())
			if type(event) = "roUrlEvent"
				str = event.GetString()
				exit while
			elseif event = invalid
				m.Http.AsyncCancel()
				' reset the connection on timeouts
				m.Http = CreateURLTransferObject(m.Http.GetUrl())
				timeout% = 2 * timeout%
			else
				print "roUrlTransfer::AsyncGetToString(): unknown event"
			endif
		endif

		num_retries% = num_retries% - 1
	end while

	return str
End Function

'*********************************************************
' Performs Http.AsyncGetToString() with a single timeout in seconds
' To the outside world this appears as a synchronous API.
'*********************************************************

Function http_get_to_string_with_timeout(seconds as Integer) as String
	timeout% = 1000 * seconds
	str = ""
	m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
	if (m.Http.AsyncGetToString())
		event = wait(timeout%, m.Http.GetPort())
		if type(event) = "roUrlEvent"
			str = event.GetString()
		elseif event = invalid
			Dbg("AsyncGetToString timeout")
			m.Http.AsyncCancel()
		else
			Dbg("AsyncGetToString unknown event", event)
		endif
	endif

	return str
End Function

'*********************************************************
' Performs Http.AsyncPostFromString() with a single timeout in seconds
' To the outside world this appears as a synchronous API.
'*********************************************************
Function http_post_from_string_with_timeout(val As String, seconds as Integer) as String
	timeout% = 1000 * seconds

	str = ""
	' m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
	if (m.Http.AsyncPostFromString(val))
		event = wait(timeout%, m.Http.GetPort())
		if type(event) = "roUrlEvent"
			print "1"
			str = event.GetString()
		elseif event = invalid
			print "2"
			Dbg("AsyncPostFromString timeout")
			m.Http.AsyncCancel()
		else
			print "3"
			Dbg("AsyncPostFromString unknown event", event)
		endif
	endif

	return str
End Function

Function NWM_GetStringFromURL(url) as Dynamic
	result = ""
	timeout = 10000
	
  ut = CreateObject("roURLTransfer")
  ut.SetPort(CreateObject("roMessagePort"))
  ut.AddHeader("user-agent", "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3")
  ut.SetURL(url)
	if ut.AsyncGetToString()
		event = wait(timeout, ut.GetPort())
		if type(event) = "roUrlEvent"
				print ValidStr(event.GetResponseCode())
				result = event.GetString()
				'exit while
		elseif event = invalid
				ut.AsyncCancel()
				'reset the connection on timeouts
				'ut = CreateURLTransferObject(url)
				'timeout = 2 * timeout
		else
				print "roUrlTransfer::AsyncGetToString(): unknown event"
		endif
	end if
	
	return result
End Function

function NWM_ResolveRedirect(url)
	result = url
	done = false
	
	ut = CreateObject("roURLTransfer")
	ut.SetPort(CreateObject("roMessagePort"))
	ut.AddHeader("user-agent", "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3")
	while not done
		ut.SetURL(result)
		if ut.AsyncHead()
			while true
				msg = wait(10000, ut.GetPort())
				if msg <> invalid
					h = msg.GetResponseHeaders()
					PrintAA(h)
					if ValidStr(h.location) <> ""
						result = ValidStr(h.location)
					else
						done = true
					end if
				else
					done = true
				end if
				exit while
			end while
		else 
			done = true
		end if
	end while
	
	return result
end function
