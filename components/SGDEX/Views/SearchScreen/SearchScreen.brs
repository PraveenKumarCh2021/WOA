Function init()
    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ShowSpinner(false)

    m.RowList = m.top.findNode("RowList")
    m.RowList.observeField("itemFocused","onItemFocused")
    m.RowList.observeField("rowItemFocused","onRowItemFocused")

    m.noContent = m.top.findnode("noContent")

    'm.BannerList = m.top.findNode("BannerList")

    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.page = 1
    m.requests = []
    m.token =  m.global.appconfig.accessToken

    m.searchField = m.top.findnode("searchField")
    m.searchField.ObserveField("text","onTextChanged")
End function

function onTextChanged(event as object)
    text = event.GetData()
    if Len(text) > 2
        GetData(text)
        m.RowList.visible = true
    else
        ' data = {
        '     title : "Search"
        '     message : "Please enter minimum 3 characters"
        ' }
        ' m.global.setFields({dialog:data})
        m.noContent.text = "Please enter minimum 3 characters"
        m.noContent.visible = true
        m.RowList.visible = false
    end if
End function

Function OnFocusChange(event as object)
    focus = event.getdata()
    if focus <> invalid
        if focus.id = ""
            m.searchField.setFocus(true)
            m.global.menu.visible = true
        end if
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

Function OnWasShown(event as object)
    m.searchField.setfocus(true)
    m.global.setFields({selectedMenu : "Search"})
    if m.RowList.content = invalid
        if m.searchField.hasfocus()
            data = {
                textfield : m.searchField
            }
            m.global.setFields({dialog : data})
        end if
    end if
End function

Function GetData(query as string)
    m.RowList.content = invalid
    m.noContent.visible = false
    ShowSpinner(true)
    input = {
        url :  m.global.appconfig.config.api_base_url+"/search/"+query.Escape()
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
        if results.results <> invalid and results.results.trays <> invalid and results.results.trays.count() > 0
            SetupRowGrid(results)
            m.RowList.visible = true
        else
            m.noContent.visible = true
            m.noContent.text = "No Data Available"
            m.RowList.visible =false
        end if
        ShowSpinner(false)
    end sub)
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
    else
        content = CreateObject("roSGNode","ContentNode")
        rowItemSize = []
        rowHeights = []
        focusXOffset = []
    end if

    if data.results.spotlight <> invalid
        if m.RowList.content = invalid
            row = CreateObject("roSGNode","ContentNode")
            for each dataItem in data.results.spotlight.items 
                item = CreateObject("roSGNode","ContentNode")
                item.update(dataItem,true)
                item.update({size:data.results.spotlight.layout},true)
                row.appendChild(item)
            end for
            GetLayoutSize(data.results.spotlight.layout,rowItemSize,rowHeights,focusXOffset)
            content.appendChild(row)
        end if
    else
        m.RowList.showRowLabel = [true]
        m.RowList.numRows = 3
    end if


    for each rowItem in data.results.trays
        if rowItem.layout = "GRID_SMALL_LANDSCAPE_LAYOUT"
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
                            row.appendChild(item)
                        end if
                    end for
                    if row.getchildCount() > 0
                        GetLayoutSize(rowItem.layout,rowItemSize,rowHeights,focusXOffset)
                        content.appendChild(row)
                    end if
                end for
            end if
        else
            if rowItem.items <> invalid and rowItem.items.count() > 0
                row = CreateObject("roSGNode","ContentNode")
                row.title = rowItem.title
                for each dataItem in rowItem.items
                    item = CreateObject("roSGNode","ContentNode")
                    item.update(dataItem,true)
                    item.update({size:rowItem.layout},true)
                    row.appendChild(item)
                end for
                GetLayoutSize(rowItem.layout,rowItemSize,rowHeights,focusXOffset)
                content.appendChild(row)
                rowItem.items = []
                row.update(rowItem,true)
            else
                row = CreateObject("roSGNode","ContentNode")
                row.title = rowItem.title
                row.update(rowItem,true)
                item.update({size:rowItem.layout},true)
                GetLayoutSize(rowItem.layout,rowItemSize,rowHeights,focusXOffset)
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
        m.RowList.content = content
    else
        m.RowList.rowItemSize = rowItemSize
        m.RowList.rowHeights = rowHeights
        m.RowList.focusXOffset = focusXOffset
    end if
    'GetRowData(m.requests.Shift())
End Function

Function GetLayoutSize(LayoutType as string,rowItemSize as object,rowHeights as object,focusXOffset as object) 
    ? LayoutType
    if LayoutType = "SPOTLIGHT_LAYOUT"
        rowItemSize.push([1780, 500])
        focusXOffset.push(74)
        rowHeights.push(580)
    else if LayoutType = "LANDSCAPE_LAYOUT"
        rowItemSize.push([568, 320])
        focusXOffset.push(74)
        rowHeights.push(400)
    else if LayoutType = "PORTRAIT_LAYOUT"
        rowItemSize.push([340, 488])
        focusXOffset.push(74)
        rowHeights.push(568)
    else if LayoutType = "GRID_SMALL_LANDSCAPE_LAYOUT"
        rowItemSize.push([378, 213])
        focusXOffset.push(150)
        rowHeights.push(293)
    else if LayoutType = "SMALL_LANDSCAPE_LAYOUT"
        rowItemSize.push([378, 213])
        focusXOffset.push(74)
        rowHeights.push(293)
    else if  LayoutType = "SQUARE_LAYOUT"
        rowItemSize.push([320, 320])
        focusXOffset.push(74)
        rowHeights.push(400)
    end if
End Function


function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
       if key = "OK"
            if m.searchField.hasfocus()
                data = {
                    textfield : m.searchField
                }
                m.global.setFields({dialog : data})
            end if
        else if key = "up"
            if m.RowList.hasfocus()
                m.searchField.setfocus(true)
                handled = true
            else if m.searchField.hasfocus()
                m.global.menu.setfocus(true)
                handled = true
            end if
        else if key = "down"
            if m.searchField.hasfocus()
                if m.RowList.content <> invalid and m.RowList.visible = true
                    m.RowList.setfocus(true)
                    handled = true
                end if
            end if
       end if
    end if
    return handled
end function
