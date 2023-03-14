Function init()
    m.back = m.top.findnode("back")
    m.title = m.top.findnode("title")
    m.buttonGroup = m.top.findnode("buttonGroup")
    m.top.ObserveField("focusedChild", "OnFocusChange")
End function

' Function onPosterChange(event as object)
'     if event.getdata() = ""
'         m.buttonPoster.width = 0
'         m.buttonPoster.height = 0
'         m.buttonGroup.itemSpacings=[0]
'         m.title.width = m.top.width
'         m.title.horizAlign = "center"
'     else
'         m.buttonPoster.width = 48
'         m.buttonPoster.height = 48
'         m.buttonGroup.itemSpacings=[5]
'     end if
' end function

Function OnFocusChange(event as object)
    if event.getdata() <> invalid
        m.back.backgroundColor = m.top.focusBackColor
        'm.buttonPoster.blendColor =  m.top.focusTextColor
        m.title.color = m.top.focusTextColor
    else
        m.back.backgroundColor = m.top.backColor
        m.title.color = m.top.textColor
        'm.buttonPoster.blendColor = m.top.textColor
    end if
End function

function onColorChanged()
    m.back.backgroundColor = m.top.backColor
    m.title.color = m.top.textColor
    'm.buttonPoster.blendColor = m.top.textColor
end function

function onKeyEvent(key as String, press as Boolean)
    handled = false
    if press 
        if key = "OK"
            if m.top.hasfocus()
                m.top.buttonselected = true
                if m.top.getParent().hasField("buttonSelected")
                    m.top.getParent().buttonSelected = m.top.id
                end if
                handle = true
            end if
        end if    
    end if
    return handled
end function