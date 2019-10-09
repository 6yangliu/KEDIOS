# KEDIOS
项目中使用到的网络框架底层基于AFNetworking整理的一套网络开发框架
优点:以尽可能少的代码处理网络请求的发送和回调，数据缓存 ，数据包的处理
###发送:
```KDNetHttpReqCenter *req=[[KDNetHttpReqCenter alloc] init];
    [req sendHttpReq:self sendDic:nil URL:[NSString stringWithFormat:@"%@%@",BASE_URL,HomeActivity] responseDWay:1 api:HomeActivity nsl:NO stl:NO];```
