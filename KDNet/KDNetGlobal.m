
//
//  KDNetGlobal.h
//  KedllDemo
//  KDNetGlobal
//  Created by ly on 15/11/15.
//  Copyright © 2015年 kedll. All rights reserved.
//


#import "KDNetGlobal.h"

@implementation KDNetGlobal

@synthesize httpReqCenterPool;

+ (KDNetGlobal *)getInstance
{
	static KDNetGlobal * global = nil;
    if (global == nil) {
        global = [[KDNetGlobal alloc] init];
    }
    return global;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
       httpReqCenterPool =[NSMutableArray array];
    }
    return self;
}


-(KDNetHttpReqCenter *)getHttpReqCenter:(NSString *)ID{
    KDNetHttpReqCenter *httpReqCenter=nil;
    if(ID==nil){
        ID=KEDIOS_DefaultURCID;
    }
    for (int i=0; i<httpReqCenterPool.count; i++) {
        NSDictionary *dic=httpReqCenterPool[i];
        if([dic[@"URCID"] isEqualToString:ID]){
            httpReqCenter=dic[@"URC"];
        }
    }
    if(httpReqCenter==nil){
        httpReqCenter=[[KDNetHttpReqCenter alloc] init];
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setObject:ID forKey:@"URCID"];
        [dic setObject:httpReqCenter forKey:@"URC"];
        [httpReqCenterPool addObject:dic];
        return httpReqCenter;
    }else{
        return httpReqCenter;
    }
}

-(KDNetHttpReqCenter *)getHttpReqCenter{
    KDNetHttpReqCenter *httpReqCenter=nil;
    httpReqCenter=[[KDNetHttpReqCenter alloc] init];
    return httpReqCenter;
}

@end


//====================================================================
//====================================================THE END=========
//====================================================================