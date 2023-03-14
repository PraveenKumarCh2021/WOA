Function SetBody()
    appInfo = CreateObject("roAppInfo")
    di = CreateObject("roDeviceInfo")
    data = {
        "device_id": di.GetChannelClientId() ,
        "version_name": appInfo.GetVersion(),
        "version_code": "1",
        "device_type": "Roku",
        "device_model": di.GetModelDisplayName()
    }
    return data
End Function