//
//  KDNetHttpReqCenter.m
//  KedllDemo
//  
//  Created by ly on 15/11/15.
//  Copyright © 2015年 kedll. All rights reserved.
//

#import "KDNetHttpReqCenter.h"
#import "KDNetHttpReqFileModel.h"
#import "LoginViewController.h"
#import "UserManager.h"
@implementation KDNetHttpReqCenter{
    //Header Acept
    NSString *language;
    NSString *curreny;
    
    NSString *clientVersion;
    NSString *deviceType;
}
@synthesize IO_Delegate;
@synthesize IO_RequestGroups;
@synthesize IO_DataSendSum;
@synthesize IO_DataReciveSum;
@synthesize IO_IsNetIdle;
@synthesize m_NowReqNetDNA;
- (id)init
{
    self = [super init];
    if (self)
    {
        IO_RequestGroups=[[NSMutableArray alloc] init];
        IO_IsNetIdle=TRUE;
    }
    return self;
}

-(void)DelRequestByAppID:(NSString*)dapi  dlgt:(id)dlgt
{
    if (dapi==nil&&dlgt==nil){
        [IO_RequestGroups removeAllObjects];
    }
    else{
        for (int i=0; i<[IO_RequestGroups count]; i++) {
            NSMutableDictionary*item=[IO_RequestGroups objectAtIndex:i];
            id _delegate=[item objectForKey:@"delegate"];
            NSString *api=[item objectForKey:@"api"];
            NSString *NetDNA=[item objectForKey:@"NetDNA"];
            if ([api isEqualToString:dapi]||_delegate==dlgt){
                NSLog(@"删除请求包NetDNA:%@",NetDNA);
                if(![m_NowReqNetDNA isEqualToString:NetDNA]) [IO_RequestGroups removeObject:item];
                else [item setObject:@"------" forKey:@"NetDNA"];
            }
        }
    }
}

/*
 delegate:  代理
 sendDic:   发送数据包 if  注:存在 KDNET_OTHER_TYPE字段则表明为PUT 请求
 URL:   请求地址
 responseDWay:    数据类型（1:xml,2:json,3:bit）
 api:   解析指导
 nsl:   阻塞式请求
 stl:   save to local
 注:如需上传图片文件。在sendDic 设置一个key为"file_file" value为图片data数组 的元素
 例：[SendDD setObject:@[data] forKey:@"file_file"];//data:图片二进制数据
 userinfo 特殊需求 预加载缓存 key: PCHE
 */
-(void)sendHttpReq:(id)delegate sendDic:(NSMutableDictionary *)SD  URL:(NSString*)Url  responseDWay:(int)dw api:(NSString*)api nsl:(BOOL)nsl stl:(BOOL)stl{
    
    //初始化header参数
    [self initHeaderParama];
    
    NSString *NetDNA=[NSString stringWithFormat:@"[%d-%@-%d-%d]", ((int)(delegate)), [KDNetUtil md5:[NSString stringWithFormat:@"%@",Url]],dw,((int)SD)];
    NSString *CacheFN=[KDNetUtil md5:[NSString stringWithFormat:@"%@-%@-%@",Url,language,curreny]];
   
    NSMutableDictionary * ReqData=[[NSMutableDictionary alloc] init];
    [ReqData setObject:api forKey:@"api"];
    [ReqData setObject:[NSString stringWithFormat:@"%d",dw] forKey:@"DWay"];
    if(SD)[ReqData setObject:SD forKey:@"SendDD"];
    if(Url)[ReqData setObject:Url forKey:@"Url"];
    if(delegate)[ReqData setObject:delegate forKey:@"delegate"];
    [ReqData setObject:[NSString stringWithFormat:@"%d",nsl] forKey:@"isNecessary"];
    [ReqData setObject:[NSString stringWithFormat:@"%d",stl] forKey:@"SaveToLocal"];
    [ReqData setObject:NetDNA forKey:@"NetDNA"];
    [ReqData setObject:CacheFN forKey:@"CacheFN"];
    BOOL find=FALSE;
    for (NSDictionary*item in IO_RequestGroups)
    {
        find=[NetDNA isEqualToString:[item objectForKey:@"NetDNA"]];
        if (find){find=TRUE;break; }
    }
    if (!find){
        [IO_RequestGroups addObject:ReqData];[self SendRequest];
    }else NSLog(@"重复请求:%@！",NetDNA);
    
    //特殊Api策略:(有缓存先返回一遍缓存数据,同时发一遍请求)
    NSString *LocalFN=[NSString stringWithFormat:@"%@%@",CacheFN, @"_.bak"];
    if(stl){
        if(self.userInfo&&[self.userInfo isKindOfClass:[NSDictionary class]]){
            BOOL PCHE=[self.userInfo[@"PCHE"] boolValue];
            if(PCHE){
                BOOL isSuc;
                NSString *savefp=[KDNetUtil SDTLF:nil path:lcps_rqtxml fname:LocalFN iSuc:&isSuc];
                NSData *data = [NSData dataWithContentsOfFile:savefp];
                if(data){
                    isSuc=YES;
                    NSLog(@"返回成功(缓存)[%d][%d][%@][%@]",isSuc,stl,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],Url);
                    [self SetNData:data reqItem:ReqData urlResponse:[[NSURLResponse alloc] init]];
                }
            }
        }
    }
}

-(void)SendRequest
{   
    if ([IO_RequestGroups count]>0&&IO_IsNetIdle)
    {
        IO_IsNetIdle=FALSE;
        if ([IO_RequestGroups count]>0) {
            NSDictionary *item=[IO_RequestGroups objectAtIndex:0];
            NSMutableDictionary *SendDD=nil;
            if([item objectForKey:@"SendDD"]){
                SendDD=[NSMutableDictionary dictionaryWithDictionary:[item objectForKey:@"SendDD"]];
            }
            NSString *Url=[[item objectForKey:@"Url"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            NSString *reqType=@"GET";

            if(SendDD==nil){//GET
                reqType=@"GET";
            }else{//POST
                if(SendDD[@"KDNET_OTHER_TYPE"]){
                    reqType=SendDD[@"KDNET_OTHER_TYPE"];
                }else{
                    reqType=@"POST";
                }
            }

            int DWay=[[item objectForKey:@"DWay"] intValue];
            
            NSError *requestError = nil;
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            if (Lib_DataWay_XML==DWay) {
                manager.responseSerializer=[AFJSONResponseSerializer serializer];
            }else if (Lib_DataWay_JSON==DWay){
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
            }
            manager.requestSerializer.timeoutInterval = 6;
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
            [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            //经过如上设置，所有 NSNull 的值，都变成了 nil
            ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
            //配置https ssl证书管理
            [self KDNetSSLValidate:NO];

            NSMutableURLRequest *req = [manager.requestSerializer requestWithMethod:reqType URLString:[[NSURL URLWithString:Url] absoluteString] parameters:nil error:&requestError];
            req.HTTPBody = [SendDD JSONData];
            if(self.userAgent){
                if([self.userAgent isKindOfClass:[NSString class]]){
                     [req setValue:self.userAgent forHTTPHeaderField:@"Authorization"];
                }
                if([self.userAgent isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dic=self.userAgent;
                    for (NSString *key in dic.allKeys) {
                         [req setValue:dic[key] forHTTPHeaderField:key];
                    }
                }
            }
            
            [req setValue:[NSString stringWithFormat:@"%@;q=1.0",language] forHTTPHeaderField:@"Accept-Language"];
            [req setValue:curreny forHTTPHeaderField:@"accept-currency"];
            [req setValue:clientVersion forHTTPHeaderField:@"client-version"];
            [req setValue:deviceType forHTTPHeaderField:@"device-type"];
            
            NSURLSessionDataTask *task=[manager.session dataTaskWithRequest:req completionHandler:^(NSData * data, NSURLResponse *  response, NSError *  error) {
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *statusCodeStr=[NSString stringWithFormat:@"%li",(long)httpResponse.statusCode];
                    if([statusCodeStr hasPrefix:@"5"]){
                        [self ParserResult:response isok:NO data:data error:error];
                        NSString *codeError=[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
                        NSError *error=[NSError errorWithDomain:codeError code:httpResponse.statusCode userInfo:nil];
                        NSLog(@"%@",error);
                        [self ParserResult:response isok:NO data:data error:error];
                        return ;
                    }
                    
                    if(!error){
                        [self ParserResult:response isok:YES data:data error:error];
                    }else{
                        [self ParserResult:response isok:NO data:data error:error];
                    }
                });
            }];

            [task resume];
            self.m_NowReqNetDNA=[item objectForKey:@"NetDNA"];
        }
    }
}

-(void)ParserResult:(NSURLResponse *)rq isok:(BOOL)isok data:(NSData *)responseData error:(NSError *)error
{

    
    IO_IsNetIdle=TRUE;
    if([IO_RequestGroups count]==0) {NSLog(@"请求包已过期A.");return;}
    NSMutableDictionary *reqItem=[IO_RequestGroups objectAtIndex:0];
    NSString *NetDNA=[reqItem objectForKey:@"NetDNA"];
    id delegate=[reqItem objectForKey:@"delegate"];
    NSString *Url=[reqItem objectForKey:@"Url"];
    NSString *CacheFN=[reqItem objectForKey:@"CacheFN"];
    
    NSString *LocalFN=[NSString stringWithFormat:@"%@%@",CacheFN, @"_.bak"];
    BOOL isNecessary=FALSE;
    BOOL SaveToLocal=FALSE;
    int trycount=0;
    if([reqItem objectForKey:@"isNecessary"]) isNecessary=[[reqItem objectForKey:@"isNecessary"] boolValue];
    if([reqItem objectForKey:@"trycount"]) trycount=[[reqItem objectForKey:@"trycount"] intValue];
    if([reqItem objectForKey:@"SaveToLocal"]) SaveToLocal=[[reqItem objectForKey:@"SaveToLocal"] boolValue];
    if (delegate==NULL||delegate==nil) delegate=IO_Delegate;

    if (isok) {//成功返回
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"返回成功[%d][%d][%@][%@]",isok,SaveToLocal,responseString,rq.URL.absoluteString);
        if([m_NowReqNetDNA isEqualToString:NetDNA]){
            if(SaveToLocal){
                BOOL isSuc;
                [KDNetUtil SDTLF:responseData path:lcps_rqtxml fname:LocalFN iSuc:&isSuc];
            }
            NSData *data=responseData;
            IO_DataReciveSum+=data.length;
            [IO_RequestGroups removeObjectAtIndex:0];[self SetNData:data reqItem:reqItem urlResponse:rq];
        }else NSLog(@"请求包已过期B.");
        [self SendRequest];
    }else{//返回失败
        if(SaveToLocal){
            BOOL isSuc;
            NSString *savefp=[KDNetUtil SDTLF:nil path:lcps_rqtxml fname:LocalFN iSuc:&isSuc];
            NSData *data = [NSData dataWithContentsOfFile:savefp];
            if(data==nil){
                [reqItem setObject:[NSString stringWithFormat:@"%d",trycount+1] forKey:@"trycount"];
                NSLog(@"已尝试［%d］次 isNecessary:%d  SaveToLocal:%d  error:%@",trycount,isNecessary,SaveToLocal,error);
                if(trycount>=(2-1)){
                    if ([delegate respondsToSelector:@selector(OnHttpErrorBack: response:)]){
                        [delegate OnHttpErrorBack:reqItem response:rq];
                    }
                    if(!isNecessary){[IO_RequestGroups removeObjectAtIndex:0];NSLog(@"请求包自动删除.");}
                }
            }else{
                ;
                NSLog(@"返回成功(缓存)[%d][%d][%@][%@]",isok,SaveToLocal,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],Url);
                [self SetNData:data reqItem:reqItem urlResponse:rq];[IO_RequestGroups removeObjectAtIndex:0];
            }

        }else{
            [reqItem setObject:[NSString stringWithFormat:@"%d",trycount+1] forKey:@"trycount"];
            NSLog(@"已尝试［%d］次 isNecessary:%d  SaveToLocal:%d  error:%@",trycount,isNecessary,SaveToLocal,error);
            if(trycount>=(2-1)){
                if ([delegate respondsToSelector:@selector(OnHttpErrorBack: response:)]){
                    [delegate OnHttpErrorBack:reqItem response:rq];
                }
                if(!isNecessary){[IO_RequestGroups removeObjectAtIndex:0];NSLog(@"请求包自动删除.");}
            }
        }
        [self performSelector:@selector(SendRequest) withObject:nil afterDelay:4];
    }
}

-(void)SetNData:(NSData*)data reqItem:(NSDictionary *)reqItem urlResponse:(NSURLResponse *)response{
    NSString *api=[reqItem objectForKey:@"api"];
    int DWay=[[reqItem objectForKey:@"DWay"] intValue];
    id delegate=[reqItem objectForKey:@"delegate"];

    ErrorModel *errModel = [ErrorModel getDataWithDict:data];
    if(errModel.code==900102||errModel.code==900104){
        [[UserManager sharedUserManager] logout];
        [self goLogin];
        return;
    }

    if (Lib_DataWay_XML==DWay) {
        if ([delegate respondsToSelector:@selector(OnHttpDataBack:responseDWay:data:userInfo:response:)]) [delegate OnHttpDataBack:api responseDWay:DWay data:data userInfo:self.userInfo response:response];
    }else if (Lib_DataWay_JSON==DWay){
        if ([delegate respondsToSelector:@selector(OnHttpDataBack:responseDWay:data:userInfo:response:)]) [delegate OnHttpDataBack:api responseDWay:DWay data:data userInfo:self.userInfo response:response];
    }else{
        NSLog(@"** HTTP ParserResult **.");
    }
}


- (void)goLogin {
    
    [[UserManager sharedUserManager] logout];
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MYTabBarController * tab = (MYTabBarController *)delegate.window.rootViewController;
    UINavigationController * nav = (UINavigationController *)tab.selectedViewController;
    [nav popToRootViewControllerAnimated:NO];
    if (tab.selectedIndex == 3) {
        tab.selectedIndex = 0;
    }
    LoginViewController *myVc = [[LoginViewController alloc]init];
    UINavigationController * login = [[UINavigationController alloc]initWithRootViewController:myVc];
    login.navigationBar.hidden = YES;
    [nav presentViewController:login animated:YES completion:^{
        
    }];
}


//ssl证书管理 validate:是否验证证书
- (id)KDNetSSLValidate:(BOOL)validate
{
    if(validate){//支持https（校验证书，不可以抓包）:
        // 1.初始化
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 2.设置证书模式
        NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"];
        NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:cerData, nil]];
        // 客户端是否信任非法证书
        manager.securityPolicy.allowInvalidCertificates = YES;
        // 是否在证书域字段中验证域名
        [manager.securityPolicy setValidatesDomainName:NO];
    }else{//支持https（不校验证书，可以抓包查看）:
        // 1.初始化
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 2.设置非校验证书模式
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.securityPolicy.allowInvalidCertificates = YES;
        [manager.securityPolicy setValidatesDomainName:NO];
    }
    return nil;
}
-(BOOL)isConnectionAvailable{
    BOOL isConnectTheInternet = YES;
    Reachability *reachConnect = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reachConnect currentReachabilityStatus]) {
        case NotReachable:
             isConnectTheInternet = NO;
            break;
        case ReachableViaWiFi:
            isConnectTheInternet = YES;
            break;
        case ReachableViaWWAN:
            isConnectTheInternet = YES;
            break;
        default:
            break;
    }
    return isConnectTheInternet;
}

#pragma mark -本类其他方法
-(void)initHeaderParama{
    
    language=[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if([[NSUserDefaults standardUserDefaults] valueForKey:SXUserLanguage]){
        language=[[NSUserDefaults standardUserDefaults] valueForKey:SXUserLanguage];
    }
    if([language hasPrefix:@"zh"]){
        language=@"zh";
    }
    if([language hasPrefix:@"en"]){
        language=@"en";
    }
    curreny=[CommonTools loadCurrentCurreny];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    clientVersion= [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    deviceType=[NSString stringWithFormat:@"%@-%@",@"IOS",[XYStringOperate getDeviceName]];
    
    
}


@end
//====================================================================
//====================================================THE END=========
//====================================================================
