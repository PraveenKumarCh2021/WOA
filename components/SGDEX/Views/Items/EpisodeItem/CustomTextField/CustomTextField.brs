Function init()
    m.poster = m.top.FindNode("poster")
    m.textbox = m.top.FindNode("textbox")

    m.top.ObserveField("focusedChild", "OnFocusChange")
End Function


Function OnFocusChange(event as object)
    if event.getdata() <> invalid
        m.textbox.active = true
        m.poster.uri = "pkg:/images/backborder.9.png"
    else
        m.textbox.active = false
        m.poster.uri="pkg:/images/searchbox.9.png"
    end if
End Function

Function onWidthchanged(event as object)
    m.textbox.width = event.getdata()-20
End Function