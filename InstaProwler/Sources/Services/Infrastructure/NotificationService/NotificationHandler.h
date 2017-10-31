#import <Foundation/Foundation.h>

@interface NotificationHandler : NSObject

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object;

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object
					onMainThread:(BOOL)onMainThread;

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object
					onMainThread:(BOOL)onMainThread
					  fromCenter:(NSNotificationCenter *)center;

- (instancetype)initWithBlock:(void (^)(NSNotification *))block
			  forNotification:(NSString *)name
				   fromObject:(id)object;

- (instancetype)initWithBlock:(void (^)(NSNotification *))block
			  forNotification:(NSString *)name
				   fromObject:(id)object
				 onMainThread:(BOOL)onMainThread;

- (instancetype)initWithBlock:(void (^)(NSNotification *))block
			  forNotification:(NSString *)name
				   fromObject:(id)object
				 onMainThread:(BOOL)onMainThread
				   fromCenter:(NSNotificationCenter*)center;

@end

@interface NSNotificationCenter (Additions)

- (NotificationHandler *)handlerWithBlock:(void (^)(NSNotification *))block
						  forNotification:(NSString *)name
							   fromObject:(id)object
							 onMainThread:(BOOL)onMainThread;

@end
