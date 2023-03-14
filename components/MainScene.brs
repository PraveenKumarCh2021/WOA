' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    m.MenuList = m.top.findnode("MenuList")
    m.MenuList.ObserveField("rowItemSelected","OnMenuItemSelected")
    m.global.AddFields({menu : m.MenuList})
    m.global.setFields({selectedMenu : m.global.appconfig.menu_apps[0].title})
    m.global.observeField("trp","onTRPDataChanged")
    content = CreateObject("roSGNode","ContentNode")
    content.update(m.global.appconfig.menu_apps[0],true)
    ShowHomeScreen(content)
    
    ? args
    if IsDeepLinking(args)
        ? args
        PerformDeepLinking(args)
    end if

    m.global.ObserveField("dialog","ondialogShow",true)

    m.ComponentController = m.top.findNode("ComponentController")

    m.top.signalBeacon("AppLaunchComplete")
end sub

Function ondialogShow(event as object)
    data = event.getData()
    if data.textfield <> invalid
        ShowsKeyboard(data)
    else
        ShowsDialog(data)
    end if
End Function

Function onTRPDataChanged(event as object)
    content = event.getdata().content
    video = event.getdata().video
    if content.manage_trp <> invalid and content.manage_trp = true 
       trp_uri = content.trp_uri.replace("[CURRENT_PLAYING_POSITION]",video.position.tostr())
       trp_uri = trp_uri.replace("[TOTAL_DURATION]",video.duration.tostr())
       if video.state = "playing"
            trp_uri = trp_uri.replace("[PLAYING_STATUS]","1")
       else
            trp_uri = trp_uri.replace("[PLAYING_STATUS]","2")
       end if
       GetURLData(trp_uri)
    end if
End Function


function ShowsDialog(data as object)
    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.update(data,true)
    m.dialog.observeField("buttonSelected", "HandleDialogButton")
    m.top.dialog = m.dialog
end function


function ShowsKeyboard(data as object)
    m.dialog = createObject("roSGNode", "KeyboardDialog")
    m.dialog.keyboard.textEditBox.secureMode = false
    if data.Textfield.id = "username"
        m.dialog.title = "Enter USERNAME"
        m.dialog.buttons = ["Enter","Cancel"]
    else if data.Textfield.id = "password"
        m.dialog.title = "PASSWORD"
        m.dialog.keyboard.textEditBox.secureMode = true
        m.dialog.buttons = ["Enter","Cancel"]
    else if data.Textfield.id = "searchField"
        m.dialog.title = "Enter your search query"
        m.dialog.keyboard.textEditBox.secureMode = false
        m.dialog.buttons = ["Enter","Cancel"]
    end if
    m.dialog.update(data,true)
    m.dialog.message = ""
    m.dialog.observeField("buttonSelected", "HandleKeyboardbutton")
    m.top.dialog = m.dialog
end function


function HandleKeyboardbutton(event as object)
    data = m.top.dialog
    if event.getData() = 0
        if data.Textfield <> invalid
            m.top.dialog.close = true
            data.Textfield.text = data.text
        end if  
    else
        m.top.dialog.close = true
    end if
end function


Function OnMenuItemSelected(event as object)
    index = event.GetData()
    data = event.GetRoSGNode().content.GetChild(index[0]).GetChild(index[1])
    m.global.setFields({selectedMenu :data.title})
    if data.title <> invalid and data.uri <> invalid
        m.ComponentController.addStack = data.title
        ShowHomeScreen(data)
    else if data.title = "Login"
        ShowLoginScreen()
    else if data.title = "Logout"
        GetURLData(m.global.appConfig.config.api_logout,true)
    else if data.title = "Search"
        m.ComponentController.addStack = data.title
        ShowSearchScreen()
    end if
End function



function ShowHomeScreen(data as object)
    m.HomeScreen = CreateObject("roSGNode", "HomeScreen")
    m.HomeScreen.data = data
    m.HomeScreen.findnode("RowList").observeField("rowItemSelected","onRowItemSelectedChanged")
    m.HomeScreen.observeField("visible","onHomeVisibleChange")
    m.top.ComponentController.CallFunc("show", {
        view: m.HomeScreen
    })
End Function

Function onHomeVisibleChange(event as object)
    if event.getData() = true
        m.MenuList.visible = true
    end if
End function

function onRowItemSelectedChanged(event as object)
    index = event.getData()
    data = event.GetRoSGNode().content.GetChild(index[0]).GetChild(index[1])
    if data.layout <> invalid and (data.layout = "CONTENT_ITEM" or data.layout = "BUNDLE_ITEM")
        ShowDetailsScreen(data)
    else if data.layout <> invalid and (data.layout = "LAUNCHER_ITEM") 
        if data.size <> invalid and (data.size = "SEASION_EPISODE_LAYOUT")
        else
            ShowHomeScreen(data) 
        end if
    end if
end function

Function ShowDetailsScreen(data as object)
    m.MenuList.visible = false
    m.DetailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.DetailsScreen.observeField("VideoData","OnVideoDataChanged")
    m.DetailsScreen.observeField("SubscribeData","OnSubscribeDataChanged")
    m.DetailsScreen.findnode("RowList").observeField("rowItemSelected","onRowItemSelectedChanged")
    m.DetailsScreen.observeField("screen","onScreenChanged")
    m.DetailsScreen.data = data
    m.top.ComponentController.CallFunc("show", {
        view: m.DetailsScreen
    })
End function

Function onScreenChanged(event as object)
    if event.getData() = "LoginScreen"
        ShowLoginScreen()
    end if
End Function


Function OnVideoDataChanged(event as object)
    data = event.getData()
    ? data.tracks
    if data.is_drm <> invalid and data.is_drm = false
        content  = createobject("roSGNode","ContentNode")
        data.url = data.uri
        data.PlayStart = m.global.videoPosition
        if data.tracks <> invalid and data.tracks.count() > 0
            subtitleTracks = []
            for each track in data.tracks
                subtitleTracks.push({language:track.language, description: track.label, trackName: track.src})
            end for
            data["SubtitleTracks"] = subtitleTracks
            'data.update({SubtitleTracks :subtitleTracks },true)
        end if
        content.update(data,true)
        ? FormatJSON(content.subtitleTracks)
        if data.manage_ads = true then
            handlerConfigRAF = {
                name : "RAFHandler"
            }
            content.update({handlerConfigRAF : handlerConfigRAF},true)
        end if
        OpenVideoPlayerItem(content)
    else if data.is_drm <> invalid and data.is_drm = true
        content  = createobject("roSGNode","ContentNode")
        data.url = data.dash_uri
        data.drmParams = {
            keySystem: "Widevine"
            licenseServerURL: data.widevine_laurl+"&token="+data.token.widevine
        }
        if data.tracks.count() > 0
            subtitleTracks = []
            for each track in data.tracks
                subtitleTracks.push({language:data.language, description: data.label, trackName: data.src})
            end for
            data.subtitleTracks = subtitleTracks
        end if
        content.update(data,true)
        if data.manage_ads = true then
            handlerConfigRAF = {
                name : "RAFHandler"
            }
            content.update({handlerConfigRAF : handlerConfigRAF},true)
        end if
        OpenVideoPlayerItem(content)
    else if data.url <> invalid
        content  = createobject("roSGNode","ContentNode")
        content.url = data.url
        OpenVideoPlayerItem(content)
    end if
End Function



Function OnSubscribeDataChanged(event as object)
    ShowSubscribeScreen(event.getData())
End Function


Function ShowSubscribeScreen(data as object)
    m.SubscribeScreen = CreateObject("roSGNode", "SubscribeScreen")
    m.SubscribeScreen.data = data
    m.top.ComponentController.CallFunc("show", {
        view: m.SubscribeScreen
    })
End function


function ShowLoginScreen()
    m.LoginScreen = CreateObject("roSGNode", "LoginScreen")
    m.top.ComponentController.CallFunc("show", {
        view: m.LoginScreen
    })
End Function

function ShowSearchScreen()
    m.SearchScreen = CreateObject("roSGNode", "SearchScreen")
    m.SearchScreen.findnode("RowList").observeField("rowItemSelected","onRowItemSelectedChanged")
    m.top.ComponentController.CallFunc("show", {
        view: m.SearchScreen
    })
End Function

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "up"
            if m.ComponentController.currentView <> invalid and not m.MenuList.hasfocus()
                ' if m.menu.visible = true
                '     m.MenuList.setfocus(true)
                '     handled = true
                ' end if
            end if
        else if key = "down"
            if m.ComponentController.currentView <> invalid
                m.ComponentController.currentView.setfocus(true)
                handled = true
            end if
        else if key = "back"
            if m.ComponentController.currentView <> invalid and m.MenuList.hasfocus()
                m.ComponentController.currentView.close = true
                handled = true
            end if
        else if key = "OK"
            
        end if
    end if
    return handled
end function


Function GetURLData(url as string,full=false)
    if full=false
        url = m.global.appconfig.config.api_base_url+url
    end if
    inputdata = {
        url :  url
        headers : {
            "Content-Type" : "application/json"
            "Authorization" : "Bearer "+m.global.appconfig.accessToken
        }
        "parmas" : FormatJSON(SetBody())
    }

    createTaskPromise("PostTask", {
        input : inputdata
    }).then(sub(task)
        results = task.output
        results = ParseJSON(results)
        if results.results <> invalid and results.results.message <> invalid and results.results.message = "Logout successfully"
            content = CreateObject("roSGNode","ContentNode")
            content.update(m.global.appconfig.menu_apps[0],true)
            ShowHomeScreen(content)
        end if
    end sub)
End Function


sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub
