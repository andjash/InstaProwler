//
//  QueueServiceImpl.m
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "QueueServiceImpl.h"
#import "Objection.h"

@interface QueueServiceImpl ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperationQueue *serialQueue;
@property (nonatomic, strong) NSMapTable *operationsMapping;
@property (nonatomic, assign) NSUInteger latestOperationId;

@end

@implementation QueueServiceImpl
objection_register_singleton(QueueServiceImpl)

#pragma mark - Objection

- (void)awakeFromObjection {
    [super awakeFromObjection];
    self.serialQueue = [[NSOperationQueue alloc] init];
    self.serialQueue.maxConcurrentOperationCount = 1;
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 20;
    self.operationsMapping = [NSMapTable weakToWeakObjectsMapTable];
}

#pragma mark - Public

- (void)postBlockInBackgroundSerialQueue:(void (^)())block {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
    [self.serialQueue addOperation:operation];
}

- (NSString *)postOperationInBackgroundQueue:(NSOperation *)operation {
    [_queue addOperation:operation];
    return [self addOperationToMapping:operation];
}

- (NSString *)postBlockInBackgroundQueue:(void (^)())block {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
    return [self postOperationInBackgroundQueue:operation];
}

- (NSOperationQueue *)queue {
    return _queue;
}

- (void)cancelOperationWithId:(NSString *)operationId {
    @synchronized (self) {
        NSOperation *operation = [self.operationsMapping objectForKey:operationId];
        [operation cancel];
        [self.operationsMapping removeObjectForKey:operationId];
    }
}

#pragma mark - Private

- (NSString *)addOperationToMapping:(NSOperation *)operation {
    @synchronized (self) {
		NSString *operationId = [NSString stringWithFormat:@"%ld", (unsigned long)++_latestOperationId];
        [self.operationsMapping setObject:operation forKey:operationId];
        return operationId;
    }
}

@end
