//
//  KDNetHttpReqFileModel.h
//  GangQinEJia
//  上传文件Model
//  Created by ly on 16/1/14.
//  Copyright © 2016年 kedll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDNetHttpReqFileModel : NSObject


@property (nonatomic, strong) NSData *fileData;

@property (nonatomic, copy) NSString *name;//带后缀的名称文件

@property (nonatomic, copy) NSString *fileName;//不带后缀的文件名称

//文件类型:AF框架中的类型http://www.iana.org/assignments/media-types/media-types.xhtml
@property (nonatomic, copy) NSString *mimeType;


@property (nonatomic, strong) id useinfo;


@end
