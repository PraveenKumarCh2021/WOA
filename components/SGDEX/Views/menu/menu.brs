function init()
    m.MenuList = m.top.findnode("MenuList")
    m.MenuList.ObserveField("rowItemSelected","onRowItemSelected")
    m.MenuList.ObserveField("rowitemfocused","onRowItemFocused")
    m.MenuList.ObserveField("visible","OnVisibleChanged")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.test = m.top.findNode("test")

    m.global.ObserveField("appconfig","onAPPConfigChanged")

    m.logo = m.top.findNode("logo")
    m.logo.uri = m.global.appconfig.config.icons.company_logo
    
    m.global.ObserveField("profile","onProfileChanged",true)

    SetMenu()
end Function

Function onAPPConfigChanged(event as object)
    SetMenu()
End function

Function OnVisibleChanged(event as object)
    m.logo.visible = event.getdata()
End Function

Function SetMenu()
    m.MenuItems = m.global.appconfig.menu_apps
    if m.global.appconfig.userInfo <> invalid and m.global.appconfig.userInfo.type <> "guest"
        Logtext = "Logout"
    else
        Logtext = "Login"
    end if
    otherMenus = [
        {
            title : Logtext,
        }
        {
            title : "Search",
        }
    ]
    m.MenuItems.append(otherMenus)
    SetupMenuList()
End function

Function onRowItemSelected(event as object)
   ' SetupMenuList()
End function

Function OnFocusChange(event as object)
    if event.getdata() <> invalid
       ' m.focusRing.visible = false
    end if
End function

Function onRowItemFocused(event as object)
    'm.focusRing.visible = false 
End function

Function SetupMenuList()
    content = createobject("roSGNode","ContentNode")
    row = createobject("roSGNode","ContentNode")
    for each menuItem in m.MenuItems
        item = createobject("roSGNode","ContentNode")
        m.test.text = menuItem.title
        item.title = menuItem.title
        item.Update(menuItem,true)
        item.Update({
            FHDItemWidth: m.test.boundingRect().width + 50.0
        }, true)
        row.appendchild(item)
    end for
    content.appendchild(row)
    m.MenuList.itemSize = [1400, 80]
    m.MenuList.content = content
end Function


function onkeyEvent(key as String, press as Boolean) as Boolean
    ' handled = false
    ' if press
    '     if key = "right"
    '         if m.MenuList.hasfocus()
    '             if m.profileImage.visible = true
    '                 m.profileImage.setfocus(true)
    '                 m.focusRing.visible = true
    '                 handled = true
    '             end if
    '         end if
    '     else if key = "left"
    '         if m.profileImage.visible = true and m.profileImage.hasfocus()
    '             m.MenuList.setfocus(true)
    '             m.focusRing.visible = false
    '             handled = true
    '         end if
    '     end if
    ' end if
    ' return handled
end function


Function onProfileChanged(event as object)
    ' if GetToken() <> ""
    '     'm.profileImage.visible = true
    '     SetupMenuList()
    ' else
    '     'm.profileImage.visible = false
    '     SetupMenuList()
    ' end if
End function