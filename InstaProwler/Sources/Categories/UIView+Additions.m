//
//  UIView+Additions.m
//  galery
//
//  Created by Andrey Yashnev on 09/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

+ (instancetype)ip_loadFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    if ([views count] > 0) {
        return views[0];
    }
    return nil;
}

@end
