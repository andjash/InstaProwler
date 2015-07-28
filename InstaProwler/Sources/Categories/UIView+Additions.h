//
//  UIView+Additions.h
//  galery
//
//  Created by Andrey Yashnev on 09/06/15.
//  Copyright (c) 2015 Alexandr Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

+ (instancetype)ip_loadFromNib;

- (void)ip_addTopBorderWithWidth:(CGFloat)width color:(UIColor *)color;
- (void)ip_addTopBorderWithWidth:(CGFloat)width color:(UIColor *)color
                       leftInset:(CGFloat)leftInset
                      rightInset:(CGFloat)rightInset;

- (void)ip_addBottomBorderWithWidth:(CGFloat)width color:(UIColor *)color;
- (void)ip_addBottomBorderWithWidth:(CGFloat)width
                              color:(UIColor *)color
                          leftInset:(CGFloat)leftInset
                         rightInset:(CGFloat)rightInset;

@end
