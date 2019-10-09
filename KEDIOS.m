//
//  KEDIOS.m
//  KEDIOS
//
//  Created by ly on 15/11/14.
//  Copyright © 2015年 kedll. All rights reserved.
//

#import "KEDIOS.h"

@implementation KEDIOS



- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


-(NSDictionary  *)getVersion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@"2015年11月14日" forKey:@"CreateDate"];
    [dic setObject:@"开雕师" forKey:@"Name"];
    [dic setObject:@"Pinco,tracy,Lyang" forKey:@"OriginalORG"];
    return [NSDictionary dictionaryWithDictionary:dic];
}
@end
