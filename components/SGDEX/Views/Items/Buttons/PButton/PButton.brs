Function init()
    m.back = m.top.findnode("back")
    m.title = m.top.findnode("title")
    m.top.ObserveField("focusedChild", "OnFocusChange")
End function


Function OnFocusChange(event as object)
    m.top.scaleRotateCenter = [m.top.width/2,m.top.height/2]
    if event.getdata() <> invalid
        m.back.blendcolor = m.top.focusBackColor
        m.title.color = m.top.focusTextColor
        m.top.scale = [1.1,1.1]
        m.back.visible = true
    else
        m.back.blendcolor = m.top.backColor
        m.title.color = m.top.textColor
        m.top.scale = [1,1]
        m.back.visible = false
    end if
End function

Function onWidthChanged()
End function

Function onHeightChanged()
    m.title.width = m.top.width/1.1
    m.back.width = m.top.width/1.1
    m.title.height = m.top.height/1.1
    m.back.height = m.top.height/1.1
    m.top.translation = [(m.top.width-(m.top.width/1.1))/2,(m.top.height-(m.top.height/1.1))/2]
End function

function onColorChanged()
    m.back.blendcolor = m.top.backColor
    m.title.color = m.top.textColor
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