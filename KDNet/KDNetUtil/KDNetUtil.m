//
//  HJXUtils.m
//  LsyAppleApp
//
//  Created by ly on 15/11/14.
//  Copyright © 2015年 kedll. All rights reserved.
//

#import "KDNetUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation KDNetUtil

+(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],result[4],result[5],result[6],result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]
            ];
}

+(NSString*)SDTLF:(NSData*)data path:(NSString*)path fname:(NSString*)fname iSuc:(BOOL*)iSuc{
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dir isDirectory:iSuc]) *iSuc=[fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *rpath =[NSString stringWithFormat:@"%@",dir];
    if(fname)rpath =[NSString stringWithFormat:@"%@/%@",rpath,fname];
    if(*iSuc&&data) *iSuc = [data writeToFile:rpath atomically:YES];
    return rpath;
}

+(void)MReplace:(NSMutableString*)str fdstr:(NSString*)fdstr rpstr:(NSString*)rpstr{
    NSRange range=[str rangeOfString:fdstr];
    if(range.length>0)[str replaceCharactersInRange:range withString:rpstr];
}

@end
