
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
