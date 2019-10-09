//
//  KDNetHttpReqCenter.h
//  KedllDemo
//  http网络请求中心
//  Created by ly on 15/11/15.
//  Copyright © 2015年 kedll. All rights reserved.
//


#import <Foundation/Foundation.h>
//第三方依赖框架

#import "JSONKit.h"
//KDNet Class Header
#import "KDNetUtil.h"
#import "KDNetMacro.h"
#import "KDNetProtocolCenter.h"
#import "Reachability.h"
@interface KDNetHttpReqCenter : NSObject<NSXMLParserDelegate>
{
    id                    IO_Delegate;
    NSMutableArray       *IO_RequestGroups; // 网络请求列队
    unsigned long         IO_DataSendSum;   // 发出数据量
    unsigned long         IO_DataReciveSum; // 接收数据量
    BOOL                  IO_IsNetIdle;     // 网络闲置状态
    NSString             *m_NowReqNetDNA;	// 当前包id
}
@property (nonatomic,strong) id                  m_NowReqNetDNA;
@property (nonatomic,strong) id                  IO_Delegate;
@property (nonatomic,strong) NSMutableArray     *IO_RequestGroups;
@property unsigned long                         IO_DataSendSum;
@property unsigned long                         IO_DataReciveSum;
@property BOOL                                  IO_IsNetIdle;
@property (nonatomic,strong)id userInfo;
@property (nonatomic,copy)id userAgent;
//通过请求id删除请求包
-(void)DelRequestByAppID:(NSString*)dapi  dlgt:(id)dlgt;
//发送请求
-(void)sendHttpReq:(id)delegate sendDic:(NSMutableDictionary *)SD  URL:(NSString*)Url  responseDWay:(int)dw api:(NSString*)api nsl:(BOOL)nsl stl:(BOOL)stl;


@end
