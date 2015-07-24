//
//  UIApplication+Additions.h
//  galery
//
//  Created by Andrey Yashnev on 12/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Additions)

+ (void)ip_increaseNetworkActivityIndication;
+ (void)ip_decreaseNetworkActivityIndication;

@end
