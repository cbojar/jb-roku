REM This file has no dependencies on other common files.
REM
REM Functions in this file:
REM     GetDeviceVersion
REM     GetDeviceESN
REM     IsHD
REM

'******************************************************
'Get our device version
'******************************************************
Function GetDeviceVersion()
    if m.softwareVersion = invalid OR m.softwareVersion = "" then
        m.softwareVersion = CreateObject("roDeviceInfo").GetVersion()
    end if
    return m.softwareVersion
End Function


'******************************************************
'Get our serial number
'******************************************************
Function GetDeviceESN()
    if m.serialNumber = invalid OR m.serialNumber = "" then
        m.serialNumber = CreateObject("roDeviceInfo").GetDeviceUniqueId()
    end if
    return m.serialNumber
End Function


'******************************************************
'Determine if the UI is displayed in SD or HD mode
'******************************************************
Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayMode() = "720p" then return true
    return false
End Function

'******************************************************
'Return a newline character
'******************************************************
Function nl()
    return chr(10)
End Function

'******************************************************
'Registry Helper Functions
'******************************************************
Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
End Function

Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function

Function RegDelete(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
End Function