//
//  HttpRequestTool.h
//  SecurityCameraAdmin
//
//  Created by Danny on 7/13/17.
//  Copyright © 2017 Danny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^successBlock) (id responseObject);
typedef void(^failureBlock)(NSError *error);
typedef void(^completionHandler)(id responseObject);
@interface HttpRequestTool : NSObject

+ (void)getWithUrlStr:(NSString *)str parameters:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure;
//+ (void)postWithUrlStr:(NSString *)str  parameters:(NSDictionary *)parameters  success:(successBlock)success  failure:(failureBlock)failure;
+ (void)postMultipartRequestWithURLStr:(NSString *)str headerField:(NSDictionary *)fields parameters:(NSDictionary *)params imageData:(NSData *)imageD success:(successBlock)success  failure:(failureBlock)failure;
+ (void)postApplicationJsonRequestWithURLStr:(NSString *)str headerField:(NSDictionary *)fields parameters:(NSDictionary *)params  success:(successBlock)success  failure:(failureBlock)failure;
@end
