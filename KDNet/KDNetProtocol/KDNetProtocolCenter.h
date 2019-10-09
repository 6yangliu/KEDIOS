//
//  KDNetProtocolCenter.h
//  KedllDemo
//  KDNet 协议
//  Created by ly on 15/11/15.
//  Copyright © 2015年 kedll. All rights reserved.
//


//网络回调协定
@protocol KDNetURCProtocol
@required//必实项
@optional//选实项

-(void)OnHttpDataBack:(NSString*)api responseDWay:(int)dw data:(NSData*)data userInfo:(id)userInfo response:(NSURLResponse*)rep;
-(void)OnHttpErrorBack:(NSMutableDictionary*)api response:(NSURLResponse*)rep;

@end


