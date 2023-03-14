' Copyright (c) 2018 Roku, Inc. All rights reserved.
Function init()
    m.poster = m.top.findNode("poster")
    m.line1 = m.top.findNode("line1")
    m.title = m.top.findNode("title")
    m.mask = m.top.findNode("mask")
    m.durationBar = m.top.findNode("durationBar")
End function
sub onContentSet()
    content = m.top.itemContent
  '  ? content
    if content.images <> invalid
        if content.size <> invalid and content.size = "PORTRAIT_LAYOUT"
            m.poster.uri = content.images.portrait
        else if content.size <> invalid and content.size = "SQUARE_LAYOUT"
            m.poster.uri = content.images.square
        else if content.size <> invalid and content.size = "LANDSCAPE_LAYOUT" or content.size = "GRID_SMALL_LANDSCAPE_LAYOUT" or content.size = "SMALL_LANDSCAPE_LAYOUT" or content.size = "CONTINUE_WATCHING_LAYOUT"
            m.poster.uri = content.images.landscape
        else if content.size <> invalid and content.size = "SPOTLIGHT_LAYOUT"
            m.poster.uri = content.images.poster
        else
            m.poster.uri = content.images.portrait
        end if
    else if content.size <> invalid and content.size = "SEASION_EPISODE_LAYOUT"
        m.poster.uri = "pkg:/images/ButtonBack.9.png"
        m.title.text = content.TITLE
        m.title.horizAlign="center" 
        m.title.vertAlign="center"
    end if

    if content.item_title_position <> invalid and content.item_title_position <> "none"
        if content.item_title_position  = "hover"
            m.TITLE.text = content.TITLE
            m.TITLE.visible = true
            m.line1.visible = false
        else if content.item_title_position = "bottom"
            m.line1.text = content.TITLE
            m.line1.visible = true
            if content.size <> invalid and content.size = "SEASION_EPISODE_LAYOUT"
                m.TITLE.visible = true
            else
                m.TITLE.visible = false
            end if
        end if
    else
        m.line1.visible = false
        m.TITLE.visible = false
    end if

    if content.size <> invalid and content.size <> "SEASION_EPISODE_LAYOUT"
        m.title.horizAlign="left" 
        m.title.vertAlign="buttom"
        m.TITLE.color = "#FFFFFF"
        m.TITLE.translation = "[10,0]"
    else
        m.TITLE.translation = "[0,0]"
    end if

    if content.size <> invalid and content.size = "SPOTLIGHT_LAYOUT"
        m.mask.visible = true
        m.mask.uri = "pkg:/images/bg1.png"
        m.mask.width = m.top.width
        m.mask.height = m.top.height
    else
        m.mask.visible = false
        m.mask.uri = "pkg:/"
        m.mask.width = 0
        m.mask.height = 0
    end if

    if content.size <> invalid and content.size = "CONTINUE_WATCHING_LAYOUT" and content.duration <> invalid and content.resume_position <> invalid
        m.durationBar.translation = [10,m.top.height-50]
        m.durationBar.visible = true
        m.durationBar.width = m.top.width - 20
        m.durationBar.height = 10
        m.durationBar.length = content.duration.toint()
        m.durationBar.bookmarkPosition = content.resume_position.toint()
        m.title.visible = true
        m.title.text = GetDurationString(content.duration.toint()-content.resume_position.toint())+" mns remaining"
        m.mask.visible = true
        m.mask.uri = "pkg:/images/bg1.png"
        m.mask.width = m.top.width
        m.mask.height = m.top.height
    else
        m.durationBar.visible = false
    end if
end sub

sub onWidthChange()
    m.poster.width      = m.top.width
    m.poster.loadWidth  = m.top.width
    m.line1.width = m.top.width
    m.TITLE.width = m.top.width
end sub

sub onHeightChange()
    m.poster.height = m.top.height
    m.poster.loadHeight  = m.top.height
    m.TITLE.height = m.top.height
end sub

Function GetDurationString(totalSeconds = 0 As Integer) As String
    remaining = totalSeconds
    hours = Int(remaining / 3600).ToStr()
    remaining = remaining Mod 3600
    minutes = Int(remaining / 60).ToStr()
    remaining = remaining Mod 60
    seconds = remaining.ToStr()

    If hours <> "0" Then
        Return PadLeft(hours, "0", 2) + ":" + PadLeft(minutes, "0", 2) + ":" + PadLeft(seconds, "0", 2)
    Else
        Return PadLeft(minutes, "0", 2) + ":" + PadLeft(seconds, "0", 2)
    End If
End Function

Function PadLeft(value As String, padChar As String, totalLength As Integer) As String
While value.Len() < totalLength
    value = padChar + value
End While
Return value
End Function