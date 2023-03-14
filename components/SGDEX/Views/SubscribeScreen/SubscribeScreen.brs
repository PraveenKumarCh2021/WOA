Function init()
    m.RowList = m.top.findnode("RowList")
    m.RowList.ObserveField("rowItemSelected","onRowItemSelected")
    m.token =  m.global.appconfig.accessToken
    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("focusedChild", "OnFocusChange")

    m.usingWeb = m.top.FindNode("usingWeb")
    m.usingMobile = m.top.FindNode("usingMobile")
    m.qrCode = m.top.findnode("qrCode")

    m.SignRemoteButton = m.top.findnode("SignRemoteButton")

    m.loginWithCode = m.top.findnode("loginWithCode")

    m.timer = m.top.findnode("timer")
    m.timer.ObserveField("fire","onTimerFire")

    m.usingWeb.drawingStyles = fontStyle()
    m.usingMobile.drawingStyles =fontStyle()

    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ShowSpinner(true)

End Function


sub ShowSpinner(show)
    m.spinner.visible = show
    if show
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub


Function OnWasShown(event as object)
    m.RowList.setfocus(true)
End Function

Function ondataChanged(event as object)
    data = event.getData()
    GetURLData(data.subscription_uri)
End Function

Function GetURLData(url as string)
    input = {
        url : m.global.appconfig.config.api_base_url+url
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
            if results.results <> invalid and results.results.layout = "PACKAGE_LAYOUT"
                SetPlans(results.results.packages)
            else
                SetQRData(results)
            end if
        else
            data = {
                title : "Error"
                message : results.message
            }
            m.global.setFields({dialog:data})
            m.RowList.visible = true
            ShowSpinner(false)
        end if
    end sub)
End Function


Function SetQRData(response as object)
    m.logindata = response.results
    m.usingWeb.text = "<title>"+response.results.web_link.title+ "</title>"+ chr(10)+ chr(10) + response.results.web_link.description+chr(10)+chr(10)+chr(10)+"<code>"+response.results.web_link.code+"</code>"
    m.usingMobile.text = "<title>"+response.results.qr_code.title+ "</title>"+ chr(10)+ chr(10) + response.results.qr_code.description
    m.qrCode.uri = response.results.qr_code.image
    m.loginWithCode.visible = true
    m.timer.duration = response.results.check_interval_sec.toint()
    m.timer.control = "Start"
    m.RowList.visible = false
    ShowSpinner(false)
End Function

Function onTimerFire(event as object)   
    if m.top.visible = true
        if m.loginWithCode.visible = true
            ValidateTVCode()
        end if
    end if
End function

Function ValidateTVCode()
    input = {
        url :m.global.appconfig.config.api_base_url+m.logindata.check_url
        headers : {
            "Content-Type" : "application/json"
        }
        "parmas" : FormatJSON(SetBody())
    }
    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        response = ParseJSON(results)
        if response.results.order_completed = true
            m.top.close = true
        else
            m.timer.control = "start"
        end if
    end sub)
End function


Function SetPlans(data as object)
    content = createobject("roSGNode","ContentNode")
    row = createobject("roSGNode","ContentNode")
    for each dataItem in data
        item = createobject("roSGNode","ContentNode")
        item.update(dataItem,true)
        row.appendChild(item)
    end for
    content.appendChild(row)
    m.RowList.content = content
    ShowSpinner(false)
End Function

Function onRowItemSelected(event as object)
    if m.RowList.visible = true
        index = event.getData()
        data = event.getRoSGNode().content.getChild(index[0]).getChild(index[1])
        m.RowList.visible = false
        ShowSpinner(true)
        GetURLData(data.uri)
    end if
End Function



Function fontStyle()
    data = {
        "title": {
            "fontSize": 35
            "fontUri": "pkg:/images/fonts/arial-bold.ttf"
            "color": "#FFFFFF"
        }
        "code": {
            "fontSize": 60
            "fontUri": "pkg:/images/fonts/arial-bold.ttf"
            "color": "#e0843d"
        }
        "default": {
            "fontSize": 25
            "fontUri": "pkg:/images/fonts/arial.ttf"
            "color": "#FFFFFF"
        }
    }
    return data
end function


function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "back"
            if m.loginWithCode.visible  = true
                m.timer.control = "stop"
                m.RowList.setfocus(true)
                m.loginWithCode.visible = false
                m.RowList.visible = true
                handled = true
            end if
        end if
    end if
    return handled
end function