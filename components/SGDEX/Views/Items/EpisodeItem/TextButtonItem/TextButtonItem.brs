sub init()
    m.button_label = m.top.findnode("button_label")
    'm.back = m.top.findnode("back")
    m.indicator = m.top.findnode("indicator")
    m.global.observeField("selectedMenu","onMenuselectedChange")
end sub    


sub OnContentSet()
    content = m.top.itemContent
    m.button_label.text = content.title
    m.indicator.translation = [0,m.top.height-5]
    if content.title = m.global.selectedMenu
        m.indicator.visible = true
    else
        m.indicator.visible = false
    end if
end sub

Function onMenuselectedChange(event as object)
    content = m.top.itemContent
    if content.title = event.getdata()
        m.indicator.visible = true
    else
        m.indicator.visible = false
    end if
End function

sub OnWidthChange()
    m.button_label.width = m.top.width
    m.indicator.width = m.top.width-30
end sub   

sub OnHeightChange()
    m.button_label.height = m.top.height
  
end sub    


sub OnItemFocusChanged()
    content = m.top.itemContent
    ' if m.top.itemHasFocus = true 
    '     m.back.visible = true
    ' else
    '     m.back.visible = false
    ' end if
end sub