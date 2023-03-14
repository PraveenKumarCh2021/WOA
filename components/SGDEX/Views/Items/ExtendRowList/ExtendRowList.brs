function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "down"
            m.top.key = key
            m.top.getParent().findnode("slideTimer").control = "stop"
        end if
    end if
    return handled
end function
