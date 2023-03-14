
sub init()
    m.top.functionName = "getContent"
end sub
  
sub getContent()
    Getdata(m.top.input)
end sub

function Getdata(data)
    response = fetch({
        url: data.url,
        timeout: 30000,
        headers: SetHeader(),
        method: "POST",
        body: data.parmas
    })
    if response.ok
        json = response.json()
        if json <> invalid
            m.top.output = response.text()
        end if
    else
        ?"The request failed", response.statusCode, response.text()
        json = response.json()
        if json <> invalid and json.status <> invalid and json.status = "FAIL"
            if (json.code <> invalid and json.code = "401") or json.message = "Expired token" or json.message = "Invalid or Expired token"
                'GetAppConfig()
                GetrefreshToken()
            else
                m.top.output = response.text()
            end if
        end if
    end if
end function 


function GetrefreshToken()
    data = SetBody()
    token = RegistryUtil().read("refreshToken","WorldBBTV")
    if token <> invalid
        data["token"] = token
    end if
    response = fetch({
        url: m.global.appconfig.config.api_base_url+"/refresh-token",
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
        url: m.global.appconfig.config.api_base_url+"/user",
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
        m.global.setFields({appConfig : response})
        getContent()
    else
        RegistryUtil().delete("refreshToken","WorldBBTV")
        GetAppConfig()
    end if
end function

Function SetHeader()
    headers = {
        "Content-Type" : "application/json"
        "Authorization" : "Bearer "+m.global.appconfig.accessToken
    }
    return headers
End Function