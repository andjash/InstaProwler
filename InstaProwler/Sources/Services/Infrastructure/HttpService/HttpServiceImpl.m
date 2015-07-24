//
//  HttpServiceImpl.m
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "HttpServiceImpl.h"
#import "AFNetworking.h"
#import "QueueService.h"
#import "Objection.h"

#import "UIApplication+Additions.h"

NSString * const kHttpServiceReceivedErrorNotification = @"kHttpServiceReceivedErrorNotification";
NSString * const kHttpServiceErrorStatusCodeKey = @"kHttpServiceErrorStatusCodeKey";

@interface ExtendedAFHTTPRequestOperation : AFHTTPRequestOperation

@property (nonatomic, strong) NSString *operationId;
@property (nonatomic, assign) BOOL cancelRequested;

@end

@implementation ExtendedAFHTTPRequestOperation

- (void)cancel {
    [super cancel];
    self.cancelRequested = YES;
}

@end

@implementation RequestParameters

- (id)init {
    self = [super init];
    if (self) {
        self.method = @"POST";
    }
    return self;
}

@end

@implementation ExecutionParameters

- (id)init {
    self = [super init];
    if (self) {
        self.callbackQueue = [NSOperationQueue mainQueue];
    }
    return self;
}

@end

@interface HttpServiceImpl ()

@property (nonatomic, weak) id<QueueService> queueService;
@property (nonatomic, strong) NSMutableArray *requestsOperations;

@end

@implementation HttpServiceImpl
objection_register_singleton(HttpServiceImpl)
objection_requires(@"queueService")

#pragma mark - Objection

- (void)awakeFromObjection {
    [super awakeFromObjection];
    self.requestsOperations = [NSMutableArray array];
}

#pragma mark - Public

- (NSString *)performRequestWithExecutionParameters:(ExecutionParameters *)executionParameters
                                  requestParameters:(RequestParameters *)requestParameters {
    if (!executionParameters) {
        executionParameters = [[ExecutionParameters alloc] init];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestParameters.url];
    
    request.HTTPMethod = requestParameters.method;
    request.HTTPBody = requestParameters.body;
    
    for (NSString *key in [requestParameters.additionalHeaders allKeys]) {
        [request setValue:requestParameters.additionalHeaders[key] forHTTPHeaderField:key];
    }
    
    ExtendedAFHTTPRequestOperation *operation = [[ExtendedAFHTTPRequestOperation alloc] initWithRequest:request];
    
    if (executionParameters.progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if (totalBytesExpectedToRead > 0) {
                executionParameters.progressBlock(((double)totalBytesRead / totalBytesExpectedToRead) * 100);
            }
        }];
    }
    
    [operation setCompletionBlockWithSuccess:[self AFSuccessCompletionBlockWithBlock:executionParameters.successBlock
                                                                   withCallbackQueue:executionParameters.callbackQueue]
                                     failure:[self AFErrorCompletionBlockWithBlock:executionParameters.errorBlock
                                                                 withCallbackQueue:executionParameters.callbackQueue]];
  
	NSLog(@"REQUEST: %@ %@", request.HTTPMethod, requestParameters.url);
	NSLog(@"HEADERS: %@", [request allHTTPHeaderFields]);
	NSLog(@"BODY: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
	
    [self.requestsOperations addObject:operation];
    NSString *requestId = operation.operationId = [self.queueService postOperationInBackgroundQueue:operation];
    [UIApplication ip_increaseNetworkActivityIndication];
    return requestId;
}

- (NSURLRequest *)requestWithRequestParameters:(RequestParameters *)requestParameters {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestParameters.url];
	
	request.HTTPMethod = requestParameters.method;
	request.HTTPBody = requestParameters.body;
	
	return request;
}

- (void)cancelRequestWithToken:(NSString *)token {
    @synchronized (self) {
        [self.queueService cancelOperationWithId:token];
    }
}

- (void)cancelAllRequests {
    @synchronized (self) {
        for (ExtendedAFHTTPRequestOperation *operation in _requestsOperations) {
            [self.queueService cancelOperationWithId:operation.operationId];
        }
    }
}

#pragma mark - Private

- (void (^)(AFHTTPRequestOperation *, id))AFSuccessCompletionBlockWithBlock:(void (^)(NSData *))success
                                                          withCallbackQueue:(NSOperationQueue *)callbackQueue {
    __weak typeof(self) wself = self;
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, id responseObject) {
        NSBlockOperation *callbackOperation = [NSBlockOperation blockOperationWithBlock:^{
            ExtendedAFHTTPRequestOperation *extendedOperation = (ExtendedAFHTTPRequestOperation *)operation;
			@synchronized (self) {
				[wself.requestsOperations removeObject:extendedOperation];
			}
            [UIApplication ip_decreaseNetworkActivityIndication];
            if (![extendedOperation cancelRequested]) {
                NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (!responseString && [responseObject isKindOfClass:[NSData class]]) {
                    responseString = [NSString stringWithFormat:@"<%ldbytes of raw data>", (unsigned long)[(NSData *)responseObject length]];
                }
                    NSLog(@"RESPONSE: %@", responseString);
                if (success) {
                    success(responseObject);
                }
            } else {
                    NSLog(@"Operation [%@][%@] complete but was cancelled during execution", extendedOperation.operationId,
                              extendedOperation.request.URL);
            }
        }];
        [callbackQueue addOperation:callbackOperation];

    };
    
    return successBlock;
}

- (void (^)(AFHTTPRequestOperation *, NSError*))AFErrorCompletionBlockWithBlock:(void (^)(NSError *))innerErrorBlock
                                                              withCallbackQueue:(NSOperationQueue *)callbackQueue{
    __weak typeof(self) wself = self;
    void (^errorBlock)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, NSError *error) {
        NSBlockOperation *callbackOperation = [NSBlockOperation blockOperationWithBlock:^{
            ExtendedAFHTTPRequestOperation *extendedOperation = (ExtendedAFHTTPRequestOperation *)operation;
            @synchronized (self) {
                [wself.requestsOperations removeObject:extendedOperation];
            }
            [UIApplication ip_decreaseNetworkActivityIndication];
            if (![extendedOperation cancelRequested]) {
                if (innerErrorBlock) {
                    innerErrorBlock(error);
                }
                NSLog(@"Error during [%@][%@] operation execution. Decription: %@", [extendedOperation description],
                        extendedOperation.request.URL, [operation responseString]);
                [self onErrorReceived:[operation response]];
            }
        }];
        [callbackQueue addOperation:callbackOperation];
    };
    
    return errorBlock;
}

- (void)onErrorReceived:(NSHTTPURLResponse *)response {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHttpServiceReceivedErrorNotification
                                                        object:self
                                                      userInfo:@{kHttpServiceErrorStatusCodeKey : @([response statusCode])}];
}

@end
