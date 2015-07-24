//
//  QueueService.h
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QueueService <NSObject>

- (NSString *)postOperationInBackgroundQueue:(NSOperation *)operation;
- (NSString *)postBlockInBackgroundQueue:(void (^)())block;

- (void)postBlockInBackgroundSerialQueue:(void (^)())block;


- (NSOperationQueue *)queue;

- (void)cancelOperationWithId:(NSString *)operationId;

@end