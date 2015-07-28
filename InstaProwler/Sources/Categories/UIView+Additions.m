//
//  UIView+Additions.m
//  galery
//
//  Created by Andrey Yashnev on 09/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import "UIView+Additions.h"

static const NSInteger kTopBorderSubviewTag = 4442;
static const NSInteger kBottomBorderSubviewTag = 4443;

@implementation UIView (Additions)

+ (instancetype)ip_loadFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    if ([views count] > 0) {
        return views[0];
    }
    return nil;
}

- (void)ip_addTopBorderWithWidth:(CGFloat)width color:(UIColor *)color {
    [self ip_addTopBorderWithWidth:width color:color leftInset:0 rightInset:0];
}

- (void)ip_addTopBorderWithWidth:(CGFloat)width color:(UIColor *)color
                       leftInset:(CGFloat)leftInset
                      rightInset:(CGFloat)rightInset {
    [self ip_removeTopBorder];
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(leftInset,
                                                              0,
                                                              self.frame.size.width - rightInset - rightInset,
                                                              width)];
    border.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    border.backgroundColor = color;
    border.tag = kTopBorderSubviewTag;
    [self addSubview:border];
}

- (void)ip_addBottomBorderWithWidth:(CGFloat)width color:(UIColor *)color {
    [self ip_addBottomBorderWithWidth:width color:color leftInset:0 rightInset:0];
}

- (void)ip_addBottomBorderWithWidth:(CGFloat)width
                              color:(UIColor *)color
                          leftInset:(CGFloat)leftInset
                         rightInset:(CGFloat)rightInset {
    [self ip_removeBottomBorder];
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(leftInset,
                                                              self.frame.size.height - width,
                                                              self.frame.size.width - rightInset - rightInset,
                                                              width)];
    border.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    border.backgroundColor = color;
    border.tag = kBottomBorderSubviewTag;
    [self addSubview:border];
}


- (void)ip_removeTopBorder {
    NSArray *subviews = [self subviews];
    for (UIView *view in subviews) {
        if ([view tag] == kTopBorderSubviewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void)ip_removeBottomBorder {
    NSArray *subviews = [self subviews];
    for (UIView *view in subviews) {
        if ([view tag] == kBottomBorderSubviewTag) {
            [view removeFromSuperview];
        }
    }
}

- (UIView *)ip_bottomBorder {
    return [self viewWithTag:kBottomBorderSubviewTag];
}

- (UIView *)ip_topBorder {
    return [self viewWithTag:kTopBorderSubviewTag];
}

@end