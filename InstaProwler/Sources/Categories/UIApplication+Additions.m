//
//  UIApplication+Additions.m
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "UIApplication+Additions.h"

static NSInteger networkActivityIndicationCount = 0;

@implementation UIApplication (Additions)

+ (void)ip_increaseNetworkActivityIndication {
    dispatch_async(dispatch_get_main_queue(), ^{
        networkActivityIndicationCount++;
        [NSObject cancelPreviousPerformRequestsWithTarget:[UIApplication sharedApplication]
                                                 selector:@selector(ip_updateNetworkActivityIndicator)
                                                   object:nil];
        [[UIApplication sharedApplication] performSelector:@selector(ip_updateNetworkActivityIndicator)
                                                withObject:nil
                                                afterDelay:0];
    });
}

+ (void)ip_decreaseNetworkActivityIndication {
    dispatch_async(dispatch_get_main_queue(), ^{
        networkActivityIndicationCount--;
        if (networkActivityIndicationCount <= 0) {
            networkActivityIndicationCount = 0;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:[UIApplication sharedApplication]
                                                 selector:@selector(ip_updateNetworkActivityIndicator)
                                                   object:nil];
        [[UIApplication sharedApplication] performSelector:@selector(ip_updateNetworkActivityIndicator)
                                                withObject:nil
                                                afterDelay:0.3];
    });
}

+ (void)ip_disableNetworkActivityIndication {
    dispatch_async(dispatch_get_main_queue(), ^{
        networkActivityIndicationCount = 0;
        [NSObject cancelPreviousPerformRequestsWithTarget:[UIApplication sharedApplication]
                                                 selector:@selector(ip_updateNetworkActivityIndicator)
                                                   object:nil];
        [[UIApplication sharedApplication] performSelector:@selector(ip_updateNetworkActivityIndicator)
                                                withObject:nil
                                                afterDelay:0.3];
    });
}

- (void)ip_updateNetworkActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.networkActivityIndicatorVisible) {
            if (networkActivityIndicationCount <= 0) {
                self.networkActivityIndicatorVisible = NO;
            }
        } else {
            if (networkActivityIndicationCount > 0) {
                self.networkActivityIndicatorVisible = YES;
            }
        }
    });
}


@end
