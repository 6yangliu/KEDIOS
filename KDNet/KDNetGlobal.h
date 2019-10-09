//
//  KDNetGlobal.h
//  KedllDemo
//  KDNetGlobal 
//  Created by ly on 15/11/15.
//  Copyright © 2015年 kedll. All rights reserved.
//

#import "KDNetHttpReqCenter.h"
#import "KDNetMacro.h"
#import "KDNetHttpReqFileModel.h"
@interface KDNetGlobal : NSObject<UIAlertViewDelegate>
{

}
@property(nonatomic,strong)NSMutableArray *httpReqCenterPool;//http网络请求中心池


+(KDNetGlobal *)getInstance;

//获取http网络请求中心 KDNetHttpReqCenter
//ID:通过ID 从请求中心池中查找实例-查找到了返回实例 未查到返回一个新实例 当ID 为nil 时 返回默认实例
-(KDNetHttpReqCenter *)getHttpReqCenter:(NSString *)ID;
//获取http网络请求中心 KDNetHttpReqCenter
//新实例
-(KDNetHttpReqCenter *)getHttpReqCenter;
@end
