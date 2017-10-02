//
//  HttpRequestTool.m
//  SecurityCameraAdmin
//
//  Created by Danny on 7/13/17.
//  Copyright © 2017 Danny. All rights reserved.
//

#import "HttpRequestTool.h"
#define kBaseURL @""
//#define MSKey @"dcf6f5e41a634b858e0647c8c172def0"

@implementation HttpRequestTool

+ (void)getWithUrlStr:(NSString *)str parameters:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:str]] ;

    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            // Handle error...
            if (failure) {
                failure(error);
            }
            return;
        }

        NSError * err = nil;
        NSArray * arr  =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err) {
            NSLog(@"JSONObjectWithData err == %@",err);
        }else{
            if (success) {
                success(arr);
            }
        }
        
    }];
    [task resume];

}



+ (void)postApplicationJsonRequestWithURLStr:(NSString *)str  headerField:(NSDictionary *)fields parameters:(NSDictionary *)params  success:(successBlock)success  failure:(failureBlock)failure{
        NSURL * url = [NSURL URLWithString:str];
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseURL,str]];

    // configure the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:fields.allValues.firstObject forHTTPHeaderField:fields.allKeys.firstObject];
   
    // create body
    NSData *httpBody;
    if (params) {
        httpBody = [NSJSONSerialization  dataWithJSONObject:params options:0 error:nil];
        [request setHTTPBody:httpBody];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            if (failure) {
                failure(error);
            }

            return;
        }
        
        NSArray * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (success) {
            success(result);
        }
    }];
    [task resume];
    
}


+ (void)postMultipartRequestWithURLStr:(NSString *)str headerField:(NSDictionary *)fields parameters:(NSDictionary *)params imageData:(NSData *)imageD success:(successBlock)success  failure:(failureBlock)failure{
    
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseURL,str]];

    NSURL * url = [NSURL URLWithString:str];
    NSString *boundary = [self generateBoundaryString];
    
    // configure the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];

    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:fields.allValues.firstObject forHTTPHeaderField:fields.allKeys.firstObject];

    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params imageData:imageD fieldName:@"image"];
    
    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            if (failure) {
                failure(error);
            }
            return;
        }
//        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//            NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
//            //            NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
//        }
        
        NSArray * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (success) {
            success(result);
        }
    }];
    [task resume];
}

+ (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                         imageData:(NSData *)data
                         fieldName:(NSString *)fieldName {
    
    //    NSLog(@"parameters===%@",parameters);
    
    NSMutableData *httpBody = [NSMutableData data];
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    NSString *mimetype  = @"image/jpeg";
    NSString * fileName = @"securityCamera.jpg";
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

+ (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}


@end
