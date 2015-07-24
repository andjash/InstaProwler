//
//  ServicesObjectionModule.m
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "ServicesObjectionModule.h"
#import "HttpServiceImpl.h"
#import "QueueServiceImpl.h"
#import "InstagramServiceImpl.h"

@implementation ServicesObjectionModule

#pragma mark - JSObjectionModule

- (void)configure {
    [self bindClass:[QueueServiceImpl class] toProtocol:@protocol(QueueService)];
    [self bindClass:[HttpServiceImpl class] toProtocol:@protocol(HttpService)];
    [self bindClass:[InstagramServiceImpl class] toProtocol:@protocol(InstagramService)];
}

@end
