sub init()
    m.top.functionName = "getContent"
end sub 

sub getContent()
    if m.top.url <> invalid
        m.top.output = Getdata(m.top.url)
    end if
end sub

Function Getdata(url as string)
    response = fetch({
        url: url,
        timeout: 30000,
        method: "GET"
    })
    if response.ok
        return response.text()
    else
        return response.text()
    end if
End function
