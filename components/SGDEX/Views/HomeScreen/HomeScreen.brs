Function init()

    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ShowSpinner(true)

    m.RowList = m.top.findNode("RowList")
    m.RowList.observeField("itemFocused","onItemFocused")
    m.RowList.ObserveField("key","onRowListKeyPressed")
    m.RowList.observeField("rowItemFocused","onRowItemFocused")

    m.slideTimer = m.top.findNode("slideTimer")
    m.slideTimer.ObserveField("fire","onslideTimerFire")
    m.slideTimer.duration = m.global.appconfig.config.spotlight.autoscroll_time_secs

    m.detailsGroup = m.top.findNode("detailsGroup")
    m.title = m.top.findNode("title")
    m.submeta = m.top.findNode("submeta")
    m.desc = m.top.findNode("desc")

    m.noContent = m.top.findNode("noContent")

    'm.BannerList = m.top.findNode("BannerList")
    m.loaded = false

    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.page = 1
    m.requests = []

    m.global.ObserveField("appConfig", "OnAPPConfigChanged")

    m.desc.drawingStyles = {
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

    m.GridLayout = invalid
    m.lastRowFocused = invalid
End Function


Function OnAppConfigChanged(event as object)
    m.page = 1
    m.detailsGroup.visible = false
    if m.RowList.content <> invalid
        GetData(m.page)
    end if
End Function

sub onslideTimerFire()
    if m.RowList.hasfocus() and m.RowList.content <> invalid and m.RowList.content.getChild(0) <> invalid and m.RowList.content.getChild(0).layout <> invalid and m.RowList.content.getChild(0).layout = "SPOTLIGHT_LAYOUT"
        if m.RowList.content.getChild(0).getchildCount()-1 = m.RowList.rowItemFocused[1]
            m.RowList.jumpToRowItem = [0,0]
        else
            m.RowList.jumpToRowItem = [0,m.RowList.rowItemFocused[1]+1]
        end if
        m.slideTimer.control = "start"
    else if m.top.visible = true and not m.RowList.hasfocus() and m.RowList.content <> invalid and m.RowList.content.getChild(0) <> invalid and m.RowList.content.getChild(0).layout <> invalid and m.RowList.content.getChild(0).layout = "SPOTLIGHT_LAYOUT"
        if m.RowList.content.getChild(0).getchildCount()-1 = m.RowList.jumpToRowItem[1]
            m.RowList.jumpToRowItem = [0,0]
        else
            if m.RowList.jumpToRowItem.count() = 0
                m.RowList.jumpToRowItem = [0,m.RowList.rowItemFocused[1]+1]
            else
                m.RowList.jumpToRowItem = [0,m.RowList.jumpToRowItem[1]+1]
            end if
        end if
        index = m.RowList.jumpToRowItem
        content = m.RowList.content.getChild(index[0]).getChild(index[1])
        SetMeta(content)
        m.slideTimer.control = "start"
    end if
end sub


Function onRowListKeyPressed(event as object)
    if event.getData() = "down"
        m.detailsGroup.visible = false
    end if
End function


sub ShowSpinner(show)
    m.spinner.visible = show
    if show
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub


function OnWasShown(event as object)
    m.RowList.setFocus(true)
    if event.getData() = true
        if m.RowList.content <> invalid and m.top.data.TITLE = "My List"
            m.lastRowFocused = m.RowList.rowItemFocused
            m.noContent.visible = false
            m.page = 1
            GetData(m.page)
        else if m.RowList.content <> invalid
            RefreshData()    
        else if m.noContent.visible = true
            m.noContent.visible = false
            m.page = 1
            GetData(m.page)
        end if
    end if

    if m.top.data <> invalid
        m.global.setFields({selectedMenu : m.top.data.title})
    end if
end function

Function RefreshData()
    rowItem = GetRowByLayout("CONTINUE_WATCHING_LAYOUT")
    if rowItem <> invalid
        rowItem.total = 0
        rowItem.loaded = 1
        RemoveAllChild(rowItem)
        m.requests.push(rowItem)
    end if
    if m.requests.count() > 0
        GetRowData(m.requests.Shift())
    end if
End function

Function ondataChanged(event as object)
    m.page = 1
    data = event.getData()
    GetData(m.page)
End function

Function OnFocusChange(event as object)
    focus = event.getdata()
    if focus <> invalid
        if focus.id = ""
            m.RowList.setFocus(true)
        end if
    end if
End function

Function onItemFocused(event as object)
    if event.getROSGNode().content <> invalid 
        if event.getData() = 0
            m.slideTimer.control = "start"
        else
            m.slideTimer.control = "stop"
        end if
        if event.getData() = event.getROSGNode().content.getchildCount()-1 and m.loaded = false
            m.page = m.page+1
            GetData(m.page)
        end if
    end if
End Function

Function onRowItemFocused(event as object)
    if event.getROSGNode().content <> invalid
        index = event.getData()
        if index[0] > 0
            m.slideTimer.control = "stop"
        end if
        data = event.getROSGNode().content.getChild(index[0])
        if data.layout <> invalid and data.layout = "SPOTLIGHT_LAYOUT"
            m.detailsGroup.visible = true
            content = event.getROSGNode().content.getChild(index[0]).getChild(index[1])
            SetMeta(content)
        else
            m.detailsGroup.visible = false
        end if

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

Function SetMeta(data as object)
    if data = invalid then return ""
    m.desc.text = ""
    m.title.text = data.title

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

    if data.maturity_rating <> invalid and data.maturity_rating <>  ""
        submeta.push(data.maturity_rating)
    end if
    m.submeta.text = submeta.join(" | ")

    if data.description <> invalid and data.description <> ""
        if m.desc.text = ""
            m.desc.text = data.description
        else
            m.desc.text = m.desc.text+chr(10)+chr(10)+data.description
        end if
    else
        m.desc.text = ""
    end if
End function

Function GetData(pageNum as integer)
    ShowSpinner(true)
    if pageNum = 1
        m.RowList.content = invalid
        url = m.global.appconfig.config.api_base_url+m.top.data.uri+"?page="+pageNum.toStr()
    else
        if m.top.data.retrieve_uri <> invalid and m.top.data.retrieve_uri <> ""
            url = m.global.appconfig.config.api_base_url+m.top.data.retrieve_uri.Replace("[PAGE_NUMBER]",pageNum.toStr())
        else if m.GridLayout <> invalid
            if m.GridLayout.retrieve_uri <> invalid and m.GridLayout.retrieve_uri <> ""
                url = m.global.appconfig.config.api_base_url+m.GridLayout.retrieve_uri.Replace("[PAGE_NUMBER]",pageNum.toStr())
            else
                ShowSpinner(false)
                return ""
            end if
        else
            m.loaded = true
            ShowSpinner(false)
            return ""
        end if
    end if

    input = {
        url : url
        headers : {
            "Content-Type" : "application/json"
            "Authorization" : "Bearer "+m.global.appconfig.accessToken
        }
        "parmas" : FormatJSON(setBody())
    }

    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        response = ParseJSON(results)
        if response.results.trays <> invalid and response.results.trays.count() > 0
            SetupRowGrid(response)
        else if response.results.layout <> invalid and response.results.layout = "GRID"
            ' response.results.trays = []
            m.GridLayout = response.results
            ' response.results.trays.push(response.results)
            ' m.RowList.numRows = 5
            ' SetupRowGrid(response)
            SetUPGrid(response)
        else if response.results.items <> invalid
            if m.GridLayout <> invalid
                if response.results.items.count() > 0
                    m.GridLayout.items = response.results.items
                    data = {}
                    data["results"] = m.GridLayout
                    SetUPGrid(data)
                end if
            end if
        else
            m.loaded = true
            if m.RowList.content = invalid
                m.noContent.visible = true
            end if
        end if
        ShowSpinner(false)
    end sub)
End Function

Function GetRowData(rowItem as object)
    if rowItem = invalid or rowItem.retrieve_uri = invalid or rowItem.retrieve_uri = ""
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
            "Authorization" : "Bearer "+m.global.appconfig.accessToken
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


Function SetBannerList(data as object)
    content = CreateObject("roSGNode","ContentNode")
    row = CreateObject("roSGNode","ContentNode")
    for each dataItem in data.results.spotlight.items 
        item = CreateObject("roSGNode","ContentNode")
        item.update(dataItem,true)
        item.update({item_title_position:row.item_title_position},true)
        row.appendChild(item)
    end for
    content.appendChild(row)
    m.BannerList.content = content
End Function    

Function SetUPGrid(data as object)
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

    if data.results.spotlight <> invalid and data.results.spotlight.items <> invalid
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
            content.appendChild(row)
        end if
    else
        m.RowList.numRows = 5
    end if

    rowItem = {
        title: data.results.title
        sub_layout: data.results.sub_layout
        layout: data.results.layout
        retrieve_uri: data.results.retrieve_uri
        id: data.results.id
        item_title_position: data.results.item_title_position
    }

    if data.results.items <> invalid and data.results.items.count() > 0
        for i=0 to data.results.items.count()-1 step 4
            row = CreateObject("roSGNode","ContentNode")
            if i=0 and m.page = 1
                row.title = rowItem.title 
            end if
            if m.page = 1
                rowItem.gridRowNum = i
            else
                rowItem.gridRowNum = content.getchildCount()
            end if

            ? rowItem.gridRowNum 

            for j=i to j+3
                if data.results.items[j] <> invalid
                    item = CreateObject("roSGNode","ContentNode")
                    item.update(data.results.items[j],true)
                    if rowItem.sub_layout <> invalid
                        item.update({size:rowItem.sub_layout},true)
                    else
                        item.update({size:rowItem.layout},true)
                    end if
                    item.update({item_title_position:rowItem.item_title_position},true)
                    row.appendChild(item)
                end if
            end for
            if row.getchildCount() > 0
                GetLayoutSize(rowItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                content.appendChild(row)
            end if
        end for
    else
        ShowSpinner(false)
    end if

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
    if  m.RowList.content = invalid or m.RowList.content.getchildCount() = 0
        m.noContent.visible = true
    end if
End Function

Function SetupRowGrid(data as object)

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

    if data.results.spotlight <> invalid and data.results.spotlight.items <> invalid
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
            content.appendChild(row)
        end if
    else
       ' m.RowList.showRowLabel = [true]
        m.RowList.numRows = 5
    end if

    for each rowItem in data.results.trays
        if rowItem.layout = "GRID_SMALL_LANDSCAPE_LAYOUT" or rowItem.layout = "GRID"
            'if rowItem.total <> invalid and rowItem.total > 0
                for i=0 to rowItem.items.count()-1 step 4
                    row = CreateObject("roSGNode","ContentNode")
                    row.update(rowItem,true)
                    row.update({gridRowNum : i},true)
                    if i=0
                        row.title = rowItem.title 
                    end if
                    rowItem.gridRowNum = i

                    for j=i to j+3
                        if rowItem.items[j] <> invalid
                            item = CreateObject("roSGNode","ContentNode")
                            item.update(rowItem.items[j],true)
                            if rowItem.sub_layout <> invalid
                                item.update({size:rowItem.sub_layout},true)
                            else
                                item.update({size:rowItem.layout},true)
                            end if
                            item.update({item_title_position:rowItem.item_title_position},true)
                            row.appendChild(item)
                        end if
                    end for
                    if row.getchildCount() > 0
                        GetLayoutSize(rowItem,rowItemSize,rowHeights,focusXOffset,showRowLabel)
                        content.appendChild(row)
                    end if
                end for
            'end if
        else
            if rowItem.total > 0
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
                rowItem.items = []
                row.update(rowItem,true)
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

    if  m.RowList.content = invalid or m.RowList.content.getchildCount() = 0
        m.noContent.visible = true
    end if

    if m.lastRowFocused <> invalid
        m.RowList.jumpToRowItem = m.lastRowFocused
    end if
End Function

Function SetRowListConfig()
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
End Function

Function SetRowData(data as Object,rowItem)
    row = GetRowByID(rowItem.id)
    if row <> invalid
        if row.total = 0 
            row.update({total : data.results.total},true)
        end if
        if data <> invalid and data.results.items.count() > 0
            for each dataItem in data.results.items
                item = CreateObject("roSGNode","ContentNode")
                item.update(dataItem,true)
                item.update({size:row.layout},true)
                item.update({item_title_position:row.item_title_position},true)
                row.appendChild(item)
            end for
        else
            if row.layout = "CONTINUE_WATCHING_LAYOUT" and (row.loaded = invalid )
                m.RowList.content.removeChild(row)
                SetNewLayoutDimension()
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

Function GetRowByLayout(layout as String)
    if m.RowList.content <> invalid
        for i=0 to m.RowList.content.getchildCount()-1
            if m.RowList.content.getChild(i).layout <> invalid and m.RowList.content.getChild(i).layout = layout
                return m.RowList.content.getChild(i)
            end if
        end for
    end if
    return invalid
End Function

Function RemoveAllChild(rowItem as object)
    if rowItem.getchildCount() > 0
        for i=0 to rowItem.getchildCount()-1
            rowItem.removeChildIndex(0)
        end for
    end if
End Function

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
       if key = "up"
            if m.RowList.hasfocus()
                m.global.menu.setFocus(true)
                m.slideTimer.control = "start"
                handled = true
            end if
       else if key = "down"
            ' if m.MenuList.hasfocus()
            '     m.global.MenuList.setFocus(true)
            ' end if
       else if key = "back"
            if m.top.data.layout <> invalid and m.top.data.layout = "MENU_NODE"
                m.global.menu.setFocus(true)
                if m.RowList.content <> invalid and m.RowList.rowItemFocused <> invalid and m.RowList.rowItemFocused[0] = 0
                    m.slideTimer.control = "start"
                end if
                handled = true
            end if
       end if
    end if

    return handled
end function

Function GetLayoutSize(rowItem as object,rowItemSize as object,rowHeights as object,focusXOffset as object,showRowLabel as object) 
    if rowItem.layout = "SPOTLIGHT_LAYOUT"
        rowItemSize.push([1780, 695])
        focusXOffset.push(74)
        rowHeights.push(745)
        showRowLabel.push(false)
    else if rowItem.layout = "LANDSCAPE_LAYOUT" or rowItem.layout = "CONTINUE_WATCHING_LAYOUT"
        rowItemSize.push([568, 320])
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
        if rowItem.item_title_position = "bottom" and rowItem.gridRowNum <> invalid and rowItem.gridRowNum = 0
            rowHeights.push(360)
        else if rowItem.item_title_position <> "bottom" and rowItem.gridRowNum <> invalid and rowItem.gridRowNum = 0
            rowHeights.push(310)
        else if rowItem.item_title_position = "bottom" and (rowItem.gridRowNum <> invalid and rowItem.gridRowNum <> 0)
            rowHeights.push(340)
        else
            rowHeights.push(253)
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
    end if
End Function


Function SetNewLayoutDimension()
    rowItemSize = []
    rowHeights = []
    focusXOffset = []
    showRowLabel = []
    for i=0 to m.RowList.content.getchildCount()-1
        GetLayoutSize(m.RowList.content.getChild(i),rowItemSize,rowHeights,focusXOffset,showRowLabel)
    end for
    m.RowList.rowItemSize = rowItemSize
    m.RowList.rowHeights = rowHeights
    m.RowList.focusXOffset = focusXOffset
    m.RowList.showRowLabel = showRowLabel
End Function