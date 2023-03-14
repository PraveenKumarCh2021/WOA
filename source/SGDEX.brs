' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub RunUserInterface(args)
    m.args = args
    if Type(GetSceneName) <> "<uninitialized>" AND GetSceneName <> invalid AND GetInterface(GetSceneName, "ifFunction") <> invalid then
        StartSGDEXChannel(GetSceneName(), args)
    else
        ? "Error: SGDEX, please implement 'GetSceneName() as String' function and return name of your scene that is extended from BaseScene"
    end if
end sub

sub StartSGDEXChannel(componentName, args)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene(componentName)

    ' Execute MainInit function, if defined by developer, prior to showing the RSG scene
    if Type(MainInit) = "Function" OR Type(MainInit) = "roFunction"
        MainInit(screen, args)
    end if

    m.global = screen.getGlobalNode()
    m.global.addFields({appConfig : {},dialog : {}, selectedMenu : "",trp : {},videoPosition : 0})

    'RegistryUtil().delete("refreshToken","WorldBBTV")

    'GetAppConfig()
    GetRefreshToken()

    screen.Show()
    scene.ObserveField("exitChannel", m.port)
    scene.launch_args = args

    scene.theme = {
        global: {
            OverhangVisible : "false"
            backgroundColor: "#091225"
        }
    }

    ' create roInput context for handling roInputEvent messages
    input = CreateObject("roInput")
    input.setMessagePort(m.port)
    
    while (true)
        msg = Wait(0, m.port)
        msgType = Type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            field = msg.getField()
            data = msg.getData()
            if field = "exitChannel" and data = true
                END
            end if
        else if msgType = "roInputEvent"
            ' roInputEvent deep linking, pass arguments to the scene
            scene.input_args = msg.getInfo()
        end if

        ' Pass event msg to MainHandleEvent, if defined by developer
        if Type(MainHandleEvent) = "Function" OR Type(MainHandleEvent) = "roFunction"
            MainHandleEvent(msg)
        end if

    end while
end sub


function GetRefreshToken()
    data = SetBody()
    token = RegistryUtil().read("refreshToken","WorldBBTV")
    if token <> invalid
        data["token"] = token
    end if

    response = fetch({
        url: "https://bbtvapi.tech2020solutions.net/refresh-token",
        timeout: 5000,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        }
        body: FormatJson(data)
    })
    if response.ok
        response = response.json().results
        RegistryUtil().write("refreshToken",response.refreshToken,"WorldBBTV")
        GetAppConfig()
    else
        ?"The request failed", response.statusCode, response.text()
        RegistryUtil().delete("refreshToken","WorldBBTV")
        GetAppConfig()
    end if
end function


function GetAppConfig()
    data = SetBody()
    token = RegistryUtil().read("refreshToken","WorldBBTV")

    if token <> invalid
        data["token"] = token
    end if

    response = fetch({
        url: "https://api.worldbbtv.com/user",
        timeout: 5000,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        }
        body: FormatJson(data)
    })
    if response.ok
        response = response.json().results
        ? response
        RegistryUtil().write("refreshToken",response.refreshToken,"WorldBBTV")
        m.global.setFields({appConfig : response})
    else
        ?"The request failed", response.statusCode, response.text()
        RegistryUtil().delete("refreshToken","WorldBBTV")
        GetAppConfig()
    end if
end function


