function init()
    m.messageTitle = m.top.findnode("messageTitle")
    m.colors = createObject("roSGNode", "RSGPalette")
    m.colors.colors = {DialogBackgroundColor: "0xffffff00"}
    m.top.palette = m.colors
    m.ButtonList = m.top.findnode("ButtonList")
    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.observeField("focusedChild", "focusChanged")
    m.contentArea = m.top.findnode("contentArea")
end function


Function focusChanged()
    m.messageTitle.translation = [ (m.contentArea.boundingRect().width - m.messageTitle.boundingRect().width)/2,0]
    m.ButtonList.translation = [ (m.contentArea.boundingRect().width - m.ButtonList.boundingRect().width)/2,0]
End Function

function OnWasShown()
end function

function onButtonChanged(event as object) 
    data = event.getData()
    for each buttonItem in data
        button = createObject("roSGNode", "button")
        button.focusable = "true"
        'button.update(buttonItem,true)
        button.text = buttonItem
        button.id = buttonItem
        button.iconUri = "pkg:/"
        button.focusedIconUri = "pkg:/"
        button.minWidth = 100
        button.showFocusFootprint = "true"
        button.observeField("buttonSelected","OnButtonSelected")
        m.ButtonList.appendChild(button)
    end for
    m.ButtonList.getchild(0).setfocus(true)
end function

function OnButtonSelected(event as object)
    m.top.buttonNode  = event.getroSGNode()
    '  m.top.buttonSelected = event.getroSGNode().text
   ' m.top.close = true
end function


function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "OK"
            ' m.top.buttonSelected = m.top.focusedChild.focusedChild.focusedChild.id
            ' m.top.close = true
        end if
    end if
    return handled
end function