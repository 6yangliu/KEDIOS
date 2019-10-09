//
//  HJXUtils.h
//  LsyAppleApp
//
//  Created by ly on 15/11/14.
//  Copyright © 2015年 kedll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDNetUtil : NSObject

//字符串转MD5字符串
+(NSString *)md5:(NSString *)str;

//文件存储到本地
+(NSString*)SDTLF:(NSData*)data path:(NSString*)path fname:(NSString*)fname iSuc:(BOOL*)iSuc;

//字符串替换
+(void)MReplace:(NSMutableString*)str fdstr:(NSString*)fdstr rpstr:(NSString*)rpstr;

@end
