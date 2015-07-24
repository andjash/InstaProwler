//
//  HttpService.h
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestParameters : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSDictionary *additionalHeaders;
@property (nonatomic, strong) NSData *body;

@end

@interface ExecutionParameters : NSObject

@property (nonatomic, copy) void(^successBlock)(NSData *);
@property (nonatomic, copy) void(^errorBlock)(NSError *);
@property (nonatomic, copy) void(^progressBlock)(double);
@property (nonatomic, strong) NSOperationQueue *callbackQueue;

@end

extern NSString * const kHttpServiceReceivedErrorNotification;
//user info
extern NSString * const kHttpServiceErrorStatusCodeKey;


@protocol HttpService <NSObject>

- (NSString *)performRequestWithExecutionParameters:(ExecutionParameters *)executionParameters
                                  requestParameters:(RequestParameters *)requestParameters;

- (NSURLRequest *)requestWithRequestParameters:(RequestParameters *)requestParameters;

- (void)cancelRequestWithToken:(NSString *)token;
- (void)cancelAllRequests;

@end
