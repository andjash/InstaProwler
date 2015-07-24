//
//  NotificationHandler.m
//  galery
//
//  Created by Andrey Yashnev on 09/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "NotificationHandler.h"

@interface NotificationHandler()

@property (nonatomic, assign) BOOL handleOnMainThread;
@property (nonatomic, copy) void (^handlerBlock)(NSNotification *notification);
@property (nonatomic, assign) NSNotificationCenter *notificationCenter;

@end


@implementation NotificationHandler

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object {
    return [[NotificationHandler alloc] initWithBlock:block forNotification:name fromObject:object];
}

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object
					onMainThread:(BOOL)onMainThread {
    return [[NotificationHandler alloc] initWithBlock:block forNotification:name fromObject:object onMainThread:onMainThread];
}

+ (instancetype)handlerWithBlock:(void (^)(NSNotification *notification))block
				 forNotification:(NSString *)name
					  fromObject:(id)object
					onMainThread:(BOOL)onMainThread
					  fromCenter:(NSNotificationCenter *)center {
    return [[NotificationHandler alloc] initWithBlock:block forNotification:name fromObject:object onMainThread:onMainThread fromCenter:center];
}

- (instancetype)initWithBlock:(void (^)(NSNotification *notification))block
			  forNotification:(NSString *)name
				   fromObject:(id)object {
    return [self initWithBlock:block forNotification:name fromObject:object onMainThread:NO];
}

- (instancetype)initWithBlock:(void (^)(NSNotification *notification))block
			  forNotification:(NSString *)name
				   fromObject:(id)object
				 onMainThread:(BOOL)onMainThread {
	return [self initWithBlock:block forNotification:name fromObject:object onMainThread:onMainThread fromCenter:[NSNotificationCenter defaultCenter]];
}

- (instancetype)initWithBlock:(void (^)(NSNotification *notification))block
			  forNotification:(NSString *)name
				   fromObject:(id)object
				 onMainThread:(BOOL)onMainThread
				   fromCenter:(NSNotificationCenter *)center {
    self = [super init];
    if (self) {
		self.handleOnMainThread = onMainThread;
		self.handlerBlock = block;
		self.notificationCenter = center;
		[self.notificationCenter addObserver:self selector:@selector(onReceiveNotification:) name:name object:object];
	}
    return self;
}

- (void)onReceiveNotification:(NSNotification *)notification {
    if (self.handlerBlock) {
		if (self.handleOnMainThread) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.handlerBlock(notification);
			});
		} else {
			self.handlerBlock(notification);
		}
	}
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
    self.handlerBlock = nil;
}

@end

@implementation NSNotificationCenter (Additions)

- (NotificationHandler *)handlerWithBlock:(void (^)(NSNotification *notification))block
						  forNotification:(NSString *)name
							   fromObject:(id)object
							 onMainThread:(BOOL)onMainThread {
    return [NotificationHandler handlerWithBlock:block forNotification:name fromObject:object onMainThread:onMainThread fromCenter:self];
}

@end