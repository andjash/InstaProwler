#import <Foundation/Foundation.h>

@protocol QueueService <NSObject>

- (NSString *)postOperationInBackgroundQueue:(NSOperation *)operation;
- (NSString *)postBlockInBackgroundQueue:(void (^)(void))block;

- (void)postBlockInBackgroundSerialQueue:(void (^)(void))block;


- (NSOperationQueue *)queue;

- (void)cancelOperationWithId:(NSString *)operationId;

@end
