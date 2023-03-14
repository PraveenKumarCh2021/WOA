Function init()
    m.detailsGroup = m.top.findNode("detailsGroup")
    m.buttons = m.top.findNode("buttons")

    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ShowSpinner(true)

    m.RowList = m.top.findNode("RowList")
    m.RowList.observeField("itemFocused","onItemFocused")
    m.RowList.observeField("rowItemFocused","onRowItemFocused")
    m.RowList.observeField("rowItemSelected","orowItemSelected")

    m.title = m.top.findNode("title")
    m.submeta = m.top.findNode("submeta")
    m.desc = m.top.findNode("desc")
    m.director = m.top.findNode("director")
    m.star = m.top.findNode("star")

    m.buttons = m.top.findNode("buttons")

    m.logo = m.top.findNode("logo")

    ' m.playTrailor = m.top.findNode("playTrailor")
    ' m.watchnow = m.top.findNode("watchnow")
    ' m.addtofav = m.top.findNode("addtofav")
    'm.BannerList = m.top.findNode("BannerList")

    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.token =  m.global.appconfig.accessToken

    m.desc.drawingStyles = TextStyle()
    m.director.drawingStyles = TextStyle()
    m.star.drawingStyles = TextStyle()

    m.top.findNode("backgroundImage").shadeOpacity = 0.8

    m.lastfocused = invalid
    m.top.findNode("backgroundImage").height = 900
    m.top.findNode("gradient").uri = m.global.appconfig.config.app_settings.description_gradiant_image
    m.Premium = m.top.findNode("Premium")
End Function

Function TextStyle()
    data = {
        "title": {
            "fontSize": 27
            "fontUri": "pkg:/images/fonts/arial-bold.ttf"
            "color": "#FFFFFF"
        }
        "default": {
            "fontSize": 25
            "fontUri": "pkg:/images/fonts/arial.ttf"
            "color": "#FFFFFF"
        }
    }
    return data 
End function

Function OnWasShown(event as object)
    if m.lastfocused <> invalid
        m.lastfocused.setfocus(true)
        GetData(m.top.data.uri)
    else
        m.RowList.setfocus(true)
    end if
End function

Function orowItemSelected(event as object)
    index = event.GetData()
    data = event.getRoSGNode().content.getchild(index[0]).getchild(index[1])
    if data.size = "SEASION_EPISODE_LAYOUT" and data.layout = "LAUNCHER_ITEM"
        rowItem = {
            id: data.id
            item_title_position: data.item_title_position
            layout: data.layout
            retrieve_uri: data.retrieve_uri
            size: "LAUNCHER_ITEM"
            total: 0
            uri: data.uri
        }
        ClearRow(event.getRoSGNode().content.getchild(index[0]+1))
        event.getRoSGNode().content.getchild(index[0]+1).update(rowItem,true)
        GetRowData(rowItem)
    end if
    m.lastfocused = event.getRoSGNode()
End function


Function onRowItemFocused(event as object)
    if event.getROSGNode().content <> invalid
        index = event.getData()
        data = event.getROSGNode().content.getChild(index[0])
        if data.getchildCount()-1 = index[1] and data.getchildCount() <> 0
            if data.loaded = invalid
                data.update({loaded : 2},true)
            else
                data.update({loaded : data.loaded+1},true)
            end if
            GetRowData(data)
        end if
    end if
End Function


sub ShowSpinner(show)
    m.spinner.visible = show
    if show
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub

sub ondataChanged(event as object)
    data = event.GetData()
    GetData(data.uri)
end sub

Function GetData(url as string)
    input = {
        url :  m.global.appconfig.config.api_base_url+url
        headers : {
            "Content-Type" : "application/json"
            "Authorization" : "Bearer "+m.global.appconfig.accessToken
        }
        "parmas" : FormatJSON(SetBody())
    }

    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        results = ParseJson(results)
        m.top.info = results.results
        if m.RowList.content = invalid
            SetMeta(results)
            SetupRowGrid(results)
        else
            SetButtons(results.results)
        end if
        m.detailsGroup.visible = true
        ShowSpinner(false)
    end sub)
End Function

Function SetMeta(data as object)
   
    ClearButtons()
    data = data.results

    ' if data <> invalid and data.sub_content_type <> invalid and data.sub_content_type = "LIVE_CHANNEL"
    '     m.top.theme = {
    '         backgroundImageURI: data.images.poster
    '     }
    ' else
    '     m.top.theme = {
    '         backgroundImageURI: data.images.landscape
    '     }
    ' end if

    ' m.top.theme = {
    '     backgroundImageURI: data.images.poster
    ' }
    itemSpacings = []   
    m.top.findNode("backPoster").uri = data.images.poster

    if data.is_paid = true
        itemSpacings.push(10)
    else
        m.Premium.visible = false
        m.Premium.height = 0
        itemSpacings.push(0)
    end if

    if data.images <> invalid and data.images.logo <> invalid and data.images.logo <> ""
        m.logo.uri = data.images.logo
        m.title.text = data.title
        itemSpacings.push(0)
        itemSpacings.push(10)
    else
        itemSpacings.push(0)
        itemSpacings.push(10)
        m.title.text = data.title
        m.logo.height = 0
        m.logo.width = 0
    end if

    
    ? FormatJson(data)

    submeta = []
    if data.duration_txt <> invalid and data.duration_txt <> ""
        submeta.push(data.duration_txt)
    end if

    if data.year <> invalid and data.year.toStr() <> ""
        submeta.push(data.year.toStr())
    end if

    if data.genres <> invalid and data.genres.count() > 0
        genres = []
        for each genre in data.genres
            genres.push(genre.title)
        end for
        submeta.push(genres.join(","))
    end if

    if data.languages <> invalid and data.languages.count() > 0
        languages = []
        for each language in data.languages
            languages.push(language.title)
        end for
        submeta.push(languages.join(","))
    end if

    if data.maturity_rating <> invalid and data.maturity_rating <>  ""
        submeta.push(data.maturity_rating)
    end if
    m.submeta.text = submeta.join(" | ")

    if m.submeta.text <> ""
        itemSpacings.push(10)
    else
        m.submeta.height = 0
        itemSpacings.push(0)
    end if

    if data.cast_crew <> invalid
        director = []
        actors = []
        if data.cast_crew.count() > 0
            for each cast in data.cast_crew 
                if cast.type_name = "Actor"
                    actors.push(cast.title)
                else if cast.type_name = "Director"
                    director.push(cast.title)
                end if
            end for
        end if

        if director.count() > 0
            m.director.text = m.desc.text + "<title>Director: </title>"+director.join(",")
            itemSpacings.push(10)
        else
            itemSpacings.push(0)
            m.director.height = 0
        end if

        if actors.count() > 0
            m.star.text = m.desc.text + "<title>Cast and Crew: </title>"+actors.join(",")
            itemSpacings.push(10)
        else
            itemSpacings.push(0)
            m.star.height = 0
        end if
    end if

    if data.description <> invalid and data.description <> ""
        m.desc.text = data.description
        itemSpacings.push(20)
    else
        itemSpacings.push(0)
        m.desc.height = 0
    end if
    itemSpacings.push(20)
    m.detailsGroup.itemSpacings = itemSpacings

    SetButtons(data)
End function


Function SetButtons(data as object)
    ClearButtons()
    buttons = []

    if data.resume_position <> invalid and m.global.appconfig.userInfo <> invalid and m.global.appconfig.userInfo.type <> "guest"
        button = CreateButton({name : "Continue Watching",id:"conWatching"})
        buttons.push(button)
    end if

    if data.play_btn_name <> "" and data.show_play_btn = true
        button = CreateButton({name :data.play_btn_name,id:"watchnow"})
        buttons.push(button)
    end if

    if data.trailer_btn_name <> invalid and data.trailer_btn_name <> "" and data.trailer_uri <> ""
        button = CreateButton({name : data.trailer_btn_name,id:"wathctrailor"})
        buttons.push(button)
    end if

    if data.wishlist <> invalid  and m.global.appconfig.userInfo <> invalid and m.global.appconfig.userInfo.type <> "guest"
        if data.wishlist.selected <> invalid and data.wishlist.selected = false
            button = CreateButton({name : "Add to Favorites",id:"addtoFav"})
            buttons.push(button)
        else
            button = CreateButton({name :  "Remove From Favorites",id:"addtoFav"})
            buttons.push(button)
        end if
    end if
 
    if data.subscription_required = true and data.subscription_btn_name <> ""
        button = CreateButton({name :  data.subscription_btn_name,id:"subscribe"})
        buttons.push(button)
    end if

    for each button in buttons
        button.ObserveField("buttonselected","onButtonSelected")
        m.buttons.appendChild(button)
    end for

    if m.lastfocused = invalid 
        if not m.buttons.isinfocuschain() and m.buttons.getchildCount() > 0
            m.buttons.getChild(0).setFocus(true)
        end if
    else
        if m.top.findNode(m.lastfocused.id) <> invalid
            m.top.findNode(m.lastfocused.id).setfocus(true)
            m.lastfocused = m.top.findNode(m.lastfocused.id)
        else if m.buttons.getChildCount() > 0
            m.buttons.getChild(0).setfocus(true)
            m.lastfocused = m.buttons.getChild(0)
        end if
    end if

End function

Function onButtonSelected(event as object)
    id = event.getRoSGNode().id
    m.lastfocused = event.getRoSGNode()
    if id = "watchnow"
        if (m.global.appconfig.userInfo <> invalid and m.global.appconfig.userInfo.type <> "guest") or m.top.info.login_requred_to_play = false
            m.global.setFields({videoPosition : 0})
            GetURLData(m.top.info.play_uri)
        else
            m.top.Screen = "LoginScreen"
        end if
    else if id = "wathctrailor"
        m.top.VideoData = {
            url : m.top.info.trailer_uri
        }
    else if id = "addtoFav"
        if m.top.info.wishlist.selected = true
            GetURLData(m.top.info.wishlist.remove_uri)
        else
            GetURLData(m.top.info.wishlist.add_uri)
        end if
    else if id = "subscribe"
        'GetURLData(m.top.info.subscription_uri)
        if (m.global.appconfig.userInfo <> invalid and m.global.appconfig.userInfo.type <> "guest")
            m.top.SubscribeData = m.top.info
        else
            m.top.Screen = "LoginScreen"
        end if
    else if id = "conWatching"
        if m.top.info.resume_position <> invalid
            m.global.setFields({videoPosition : m.top.info.resume_position.toint()})
        end if
        GetURLData(m.top.info.play_uri)
    else
        ? id
        ? m.top.info
    end if
End Function

Function SetupRowGrid(data as object)
    m.requests =[]
    if m.RowList.content <> invalid
        content = m.RowList.content
        rowItemSize =  []
        rowItemSize.append(m.RowList.rowItemSize)
        rowHeights = []
        rowHeights.append(m.RowList.rowHeights)
        focusXOffset = []
        focusXOffset.append(m.RowList.focusXOffset)
        showRowLabel = []
        showRowLabel.append(m.RowList.showRowLabel)
    else
        content = CreateObject("roSGNode","ContentNode")
        rowItemSize = []
        rowHeights = []
        focusXOffset = []
        showRowLabel = []
    end if

    if data.results.spotlight <> invalid
        if m.RowList.content = invalid
            row = CreateObject("roSGNode","ContentNode")
            for each dataItem in data.results.spotlight.items 
                item = CreateObject("roSGNode","ContentNode")
                item.update(dataItem,true)
                item.update({size:data.results.spotlight.layout},true)
                item.update({item_title_position:data.results.spotlight.item_title_position},true)
                row.appendChild(item)
            end for
            data.results.spotlight.items = []
            row.update(data.results.spotlight,true)
            GetLayoutSize(data.results.spotlight,rowItemSize,rowHeights,focusXOffset,showRowLabel)
        end if
    else
        if data.results.sub_content_type = "SHOW"
            m.RowList.showRowLabel = [false,false,true]
        else
            m.RowList.showRowLabel = [true]
        end if
        m.RowList.numRows = 3
    end if


    for each rowItem in data.results.trays
        if rowItem.layout = "GRID_SMALL_LANDSCAPE_LAYOUT" or rowItem.layout = "GRID"
            if rowItem.total > 0
                for i=0 to rowItem.items.count()-1 step 4
                    row = CreateObject("roSGNode","ContentNode")
                    if i=0
                        row.title = rowItem.title 
                    end if
                    for j=i to j+3
                        if rowItem.items[j] <> invalid
                            item = CreateObject("roSGNode","ContentNode")
                            item.update(rowItem.items[j],true)
                            item.update({size:rowItem.layout},true)
                            item.update({item_title_position:rowItem.item_title_position},true)
                            row.appendChild(item)
                        end if
                    end for
                    if row.getchildCount() > 0
                        GetLayoutSize(rowItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                        content.appendChild(row)
                    end if
                end for
            end if
        else
            if rowItem.total <> invalid and rowItem.total > 0
                row = CreateObject("roSGNode","ContentNode")
                row.title = rowItem.title
                for each dataItem in rowItem.items
                    item = CreateObject("roSGNode","ContentNode")
                    item.update(dataItem,true)
                    item.update({size:rowItem.layout},true)
                    item.update({item_title_position:rowItem.item_title_position},true)
                    row.appendChild(item)
                end for
                GetLayoutSize(rowItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                content.appendChild(row)
                'rowItem.items = []
                row.update(rowItem,true)

                if rowItem.layout = "SEASION_EPISODE_LAYOUT"
                    for each dataItem in rowItem.items
                        if dataItem.total > 0 and dataItem.items.count() > 0
                            episodeItem = dataItem
                            episodeItem.layout = dataItem.layout
                            episodeItem.uri = dataItem.uri
                            episodeItem.retrieve_uri = dataItem.retrieve_uri
                            episodeItem.item_title_position = "hover"
                            episodeItem.title = ""
                        end if
                    end for
                    row = CreateObject("roSGNode","ContentNode")
                    'row.title = episodeItem.title
                    for each dataItem in episodeItem.items
                        item = CreateObject("roSGNode","ContentNode")
                        item.update(dataItem,true)
                        item.update({size:episodeItem.layout},true)
                        item.update({item_title_position:episodeItem.item_title_position},true)
                        row.appendChild(item)
                    end for
                    GetLayoutSize(episodeItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                    content.appendChild(row)
                    episodeItem.items = []
                    row.update(episodeItem,true)
                end if
            else
                row = CreateObject("roSGNode","ContentNode")
                row.title = rowItem.title
                row.update(rowItem,true)
                row.update({size:rowItem.layout},true)
                GetLayoutSize(rowItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                content.appendChild(row)
            end if
        end if
        if rowItem.total = 0
            m.requests.Push(rowItem)
        end if
    end for
    if m.RowList.content = invalid
        m.RowList.rowItemSize = rowItemSize
        m.RowList.rowHeights = rowHeights
        m.RowList.focusXOffset = focusXOffset
        m.RowList.showRowLabel = showRowLabel
        m.RowList.content = content
    else
        m.RowList.rowItemSize = rowItemSize
        m.RowList.rowHeights = rowHeights
        m.RowList.focusXOffset = focusXOffset
        m.RowList.showRowLabel = showRowLabel
    end if
    GetRowData(m.requests.Shift())
End Function

Function GetLayoutSize(rowItem as object,rowItemSize as object,rowHeights as object,focusXOffset as object,showRowLabel as object) 
    if rowItem.layout = "SPOTLIGHT_LAYOUT"
        rowItemSize.push([1780, 700])
        focusXOffset.push(74)
        rowHeights.push(780)
        showRowLabel.push(false)
    else if rowItem.layout = "LANDSCAPE_LAYOUT"
        rowItemSize.push([568, 310])
        focusXOffset.push(74)
        if rowItem.item_title_position <> "none"
            rowHeights.push(430)
        else
            rowHeights.push(400)
        end if
        showRowLabel.push(true)
    else if rowItem.layout = "PORTRAIT_LAYOUT"
        rowItemSize.push([340, 488])
        focusXOffset.push(74)
        if rowItem.item_title_position <> "none"
            rowHeights.push(598)
        else
            rowHeights.push(568)
        end if
        showRowLabel.push(true)
    else if rowItem.layout = "GRID_SMALL_LANDSCAPE_LAYOUT" or rowItem.layout = "GRID"
        rowItemSize.push([378, 213])
        focusXOffset.push(150)

        if rowItem.item_title_position <> "none" and  rowItem.gridRowNum <> invalid and rowItem.gridRowNum = 0
            rowHeights.push(340)
        else
            rowHeights.push(293)
        end if
        
        if rowItem.gridRowNum <> invalid and rowItem.gridRowNum = 0
            showRowLabel.push(true)
        else
            showRowLabel.push(false)
        end if
    else if rowItem.layout = "SMALL_LANDSCAPE_LAYOUT"
        rowItemSize.push([378, 213])
        focusXOffset.push(74)
        if rowItem.item_title_position <> "none"
            rowHeights.push(323)
        else
            rowHeights.push(293)
        end if
        showRowLabel.push(true)
    else if  rowItem.layout = "SQUARE_LAYOUT"
        rowItemSize.push([320, 320])
        focusXOffset.push(74)
        if rowItem.item_title_position <> "none"
            rowHeights.push(430)
        else
            rowHeights.push(400)
        end if
        showRowLabel.push(true)
    else if rowItem.layout = "SEASION_EPISODE_LAYOUT"
        rowItemSize.push([220, 58])
        focusXOffset.push(74)
        rowHeights.push(70)
        showRowLabel.push(false)
    else if rowItem.layout  = "LAUNCHER_ITEM"
        rowItemSize.push([378, 213])
        focusXOffset.push(74)
        rowHeights.push(250)
        showRowLabel.push(false)
    end if
End Function


Function GetRowData(rowItem as object)

    if rowItem = invalid or rowItem.retrieve_uri = invalid
        return ""
    end if

    m.rowItem = rowItem
    if m.rowItem.loaded = invalid
        page = 1
    else
        page = m.rowItem.loaded
    end if

    input = {
        url : m.global.appconfig.config.api_base_url+rowItem.retrieve_uri.Replace("[PAGE_NUMBER]",page.toStr())
        headers : {
            "Content-Type" : "application/json"
            "Authorization" : "Bearer "+m.token
        }
        "parmas" : FormatJSON(SetBody())
    }

    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        response = ParseJSON(results)
        SetRowData(response,m.rowItem)
    end sub)

End Function

Function SetRowData(data as Object,rowItem)
    row = GetRowByID(rowItem.id)
    if row <> invalid
        if row.total = 0 
            row.update({total : data.results.total},true)
        end if
        if data <> invalid
            if data.results <> invalid and data.results.items <> invalid
                for each dataItem in data.results.items
                    item = CreateObject("roSGNode","ContentNode")
                    item.update(dataItem,true)
                    item.update({size:row.layout},true)
                    item.update({item_title_position:row.item_title_position},true)
                    row.appendChild(item)
                end for
            end if
        end if
    end if
End Function

Function GetRowByID(id as String)
    if m.RowList.content <> invalid
        for i=0 to m.RowList.content.getchildCount()-1
            if  m.RowList.content.getChild(i).id = id
                return m.RowList.content.getChild(i)
            end if
        end for
    end if
    return invalid
End Function

Function ClearRow(row as object)
    for i=0 to row.getchildCount()-1
        row.removeChildIndex(0)
    end for
End function

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "up"
        if m.RowList.hasfocus() and m.buttons.visible = true
            if m.buttons.getchildCount() > 0 then
                m.buttons.getchild(0).setfocus(true)
                handled = true
            end if
        end if
        else if key = "down"
        if m.buttons.isinfocuschain()
            m.RowList.setfocus(true)
            handled = true
        end if
        else if key = "OK"
            
        end if
    end if
    return handled
end function


' Function CreateButton(data as object)
'     button = CreateObject("roSGNode","PButton")
'     button.id = data.id
'     ? button.id
'     if data.name = "Remove From Favorites"
'         button.width="450"
'     else if data.name = "Continue Watching"
'         button.width="400"
'     else
'         button.width = "330"
'     end if
'     button.height="66"
'     button.name= data.name
'     button.backColor="#979797"
'     button.textColor="#979797"
'     button.focusBackColor="#FFFFFF"
'     button.focusTextColor="#FFFFFF"
'     button.focusable="true"
'     return button
' End function

Function CreateButton(data as object)
    button = CreateObject("roSGNode","Button")
    button.id = data.id
    button.height="66"
    button.text= data.name
    button.textColor="#979797"
    button.focusedTextColor="#FFFFFF"
    button.focusBitmapUri = "pkg:/images/backborder.9.png"
    if button.id = "addtoFav"
        button.iconUri = m.global.appconfig.config.icons.wishlist
        button.focusedIconUri = m.global.appconfig.config.icons.wishlist
    else
        button.iconUri = "pkg:/"
        button.focusedIconUri = "pkg:/"
    end if
    
    font  = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/images/fonts/arial-bold.ttf"
    font.size = 30

    button.textFont = font
    button.focusedTextFont = font
    button.minWidth = 200
    button.focusable="true"
    m.focusedSet = false
    for i=0 to button.getchildCount()-1
        if button.getchild(i).uri <> invalid
           if button.getchild(i).uri <> invalid
                if  button.getchild(i).uri <> "pkg:/images/backborder.9.png" and button.getchild(i).uri <> "pkg:/" and m.focusedSet = false
                    button.getchild(i).blendColor = "#FFFFFF"
                    button.getchild(i).height = "50"
                    button.getchild(i).width = "50"
                    m.focusedSet = true
                else if button.getchild(i).uri <> "pkg:/images/backborder.9.png" and button.getchild(i).uri <> "pkg:/"
                    button.getchild(i).blendColor = "#979797"
                    button.getchild(i).height = "50"
                    button.getchild(i).width = "50"
                    m.focusedSet = false
                end if
           end if
        end if
    end for
    return button
End function

Function GetURLData(url as string)
    input = {
        url :  m.global.appconfig.config.api_base_url+url
        headers : {
            "Content-Type" : "application/json"
            "Authorization" : "Bearer "+m.global.appconfig.accessToken
        }
        "parmas" : FormatJSON(SetBody())
    }

    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        results = ParseJSON(results)
        if results.status <> "FAIL"
            if results.results.is_drm <> invalid
                ? results.results
                m.top.VideoData = results.results
            else
                ? FormatJSON(results)
                GetData(m.top.data.uri)
            end if
        else
            ? results
        end if
    end sub)
End Function


Function ClearButtons()
    if m.buttons.getchildCount()>0 then
        for i=0 to m.buttons.getchildCount()-1
            m.buttons.removeChildIndex(0)
        end for
    end if
End Function

