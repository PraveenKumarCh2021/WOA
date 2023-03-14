' Copyright (c) 2018 Roku, Inc. All rights reserved.
Function init()
    m.back = m.top.findNode("back")
    m.titleBack = m.top.findNode("titleBack")
    m.title = m.top.findNode("title")
    m.planTitle = m.top.findNode("planTitle")
    m.planfeature = m.top.findNode("planFeature")

    m.planTitle.drawingStyles = TextStyle()
    m.planfeature.drawingStyles = TextStyle()
End function


Function TextStyle()
    data = {
        "title": {
            "fontSize": 27
            "fontUri": "pkg:/images/fonts/arial-bold.ttf"
            "color": "#FFFFFF"
        }
        "price": {
            "fontSize": 45
            "fontUri": "pkg:/images/fonts/arial.ttf"
            "color": "#FFFFFF"
        }
        "default": {
            "fontSize": 26
            "fontUri": "pkg:/images/fonts/arial.ttf"
            "color": "#FFFFFF"
        }
    }
    return data
End function

sub onContentSet()
   itemdata = m.top.itemContent
   m.title.text = itemdata.id
   m.planTitle.text = "<title>"+itemdata.name+"</title>" + " "+"<price>" +itemdata.currency_symbol+itemdata.amount+"</price>"

   if type(itemdata.features) = "roArray"
    featurelist = []
    for each feature in itemdata.features
        featurelist.push(">>  "+feature.name)
    end for
    m.planfeature.text = featurelist.join(chr(10))
   end if
end sub

sub onWidthChange()
    m.back.width  = m.top.width
    m.titleBack.width = m.top.width
    m.title.width = m.top.width
    m.planTitle.width = m.top.width
    m.planfeature.width = m.top.width-40
end sub

sub onHeightChange()
    m.back.height = m.top.height
end sub