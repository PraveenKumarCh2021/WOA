function IsDeepLinking(args as Object)
    ' check if deep linking args is valid
    return args <> invalid and args.mediaType <> invalid and args.mediaType <> "" and args.contentId <> invalid and args.contentId <> "" 
end function

sub PerformDeepLinking(args as Object)
    ' Implement your deep linking logic. For more details, please see Roku_Recommends sample.

    if args <> invalid and args.mediaType = "live" and args.contentID <> invalid and args.contentID = "bbtv"
        content = CreateObject("roSGNode","ContentNode")
        content.url = "https://d22kb9sinmfyk6.cloudfront.net/76cc0aae-f77d-4581-948a-61f0f7c71593/221_ilike_video.m3u8"
        OpenVideoPlayer(content,0,false)
    else if args <> invalid and args.mediaType = "movie" and args.contentID <> invalid
        content = CreateObject("roSGNode","ContentNode")
        item = CreateObject("roSGNode","ContentNode")
        data = {
            id: args.contentID
        }
        item.update(data,true)
        item.update({HandlerConfigVideo: {name: "VideoScreenHandler"}},true)
        content.appendChild(item)
        OpenVideoPlayer(content,0,false)
    end if
end sub
