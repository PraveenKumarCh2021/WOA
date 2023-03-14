function init()
    m.usingWeb = m.top.FindNode("usingWeb")
    m.usingMobile = m.top.FindNode("usingMobile")
    m.qrCode = m.top.findnode("qrCode")

    m.SignRemoteButton = m.top.findnode("SignRemoteButton")

    m.company_logo = m.top.findnode("company_logo")
    m.company_logo.uri = m.global.appconfig.config.icons.company_icon

    m.username = m.top.findnode("username")
    m.password = m.top.findnode("password")

    m.loginWithCode = m.top.findnode("loginWithCode")
    m.loginWithEmail = m.top.findnode("loginWithEmail")

    m.loginqrcodebutton = m.top.findnode("loginqrcodebutton")

    m.timer = m.top.findnode("timer")
    m.timer.ObserveField("fire","onTimerFire")

    m.LoginSubmit = m.top.findnode("LoginSubmit")
    m.LoginSubmit.observeField("buttonselected","OnLoginButtonSelected")

    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("focusedChild", "OnFocusChange")

    m.logindata = {}

    m.usingWeb.drawingStyles = fontStyle()
    m.usingMobile.drawingStyles =fontStyle()

    'LoginWithCredetails()
end function

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

function OnWasShown(event as object)
    if event.getData() = true
        m.SignRemoteButton.setfocus(true)
        GetTVCode()
    else
        m.timer.control = "stop"
    end if

    m.global.setFields({selectedMenu : "Login"})
end function

Function onTimerFire(event as object)   
    if m.top.visible = true
        ValidateTVCode()
    end if
End function

Function GetTVCode()
    input = {
        url : m.global.appconfig.config.api_tv_login
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
        m.logindata = response.results
        m.usingWeb.text = "<title>"+response.results.web_link.title+ "</title>"+ chr(10)+ chr(10) + response.results.web_link.description+chr(10)+chr(10)+chr(10)+"<code>"+response.results.web_link.code+"</code>"+chr(10)+chr(10)+"<title>or</title>"
        m.usingMobile.text = "<title>"+response.results.qr_code.title+ "</title>"+ chr(10)+ chr(10) + response.results.qr_code.description
        m.qrCode.uri = response.results.qr_code.image
        m.loginWithCode.visible = true
        m.timer.duration = response.results.check_interval_sec.toint()
        m.timer.control = "Start"
    end sub)
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
        if response.results <> invalid and response.results.login_completed <> invalid
            if response.results.login_completed = false
                m.timer.control = "start"
            else if response.results.login_completed = true
                m.global.setFields({appconfig : response.results})
                RegistryUtil().write("refreshToken",response.results.refreshToken,"WorldBBTV")
                m.top.close = true
            end if
        else
            GetTVCode()
        end if
    end sub)
End function

Function OnLoginButtonSelected(event as object)
    if m.username.text <> "" and m.password.text <> ""
        LoginWithCredetails()
    end if
End function

Function LoginWithCredetails()
    parmas = SetBody()
    ' parmas["username"] = "rimdhanani@gmail.com"
    ' parmas["password"] = "BBtv1234"

    parmas["username"] = "rokubbtv@gmail.com"
    parmas["password"] = "BBtv1234"

    ' parmas["username"] = m.username.text
    ' parmas["password"] =  m.password.text
    

    input = {
        url :m.global.appconfig.config.api_login
        headers : {
            "Content-Type" : "application/json"
        }
        "parmas" : FormatJSON(parmas)
    }

    createTaskPromise("PostTask", {
        input : input
    }).then(sub(task)
        results = task.output
        response = ParseJSON(results)
        if response.status = "FAIL"
            data = {
                title : "Login"
                message : response.message
            }
            m.global.setFields({dialog : data})
        else
            m.global.setFields({appconfig : response.results})
            RegistryUtil().write("refreshToken",response.results.refreshToken,"WorldBBTV")
            m.top.close = true
        end if
    end sub)
End function

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
       if key = "OK"
            if m.SignRemoteButton.hasfocus()
                m.loginWithCode.visible = false
                m.loginWithEmail.visible = true
                m.username.setfocus(true)
            else if m.loginqrcodebutton.hasfocus()
                m.loginWithCode.visible = true
                m.loginWithEmail.visible = false
                m.SignRemoteButton.setfocus(true)
            else if m.username.hasfocus()
                data = {
                    textfield : m.username
                }
                m.global.setFields({dialog : data})
            else if m.password.hasfocus()
                data = {
                    textfield : m.password
                }
                m.global.setFields({dialog : data})
            end if
        else if key = "up"
            if m.SignRemoteButton.hasfocus()
                m.global.menu.setfocus(true)
            end if
       end if
    end if
    return handled
end function
