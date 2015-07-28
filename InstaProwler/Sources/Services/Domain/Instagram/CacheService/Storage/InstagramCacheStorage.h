//
//  InstagramCacheStorage.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramCacheStorage <NSObject>

- (void)setImage:(UIImage *)image withUrl:(NSString *)url withCompletionBlock:(void (^)())completionBlock;
- (void)getImageWithUrl:(NSString *)url withCompletionBlock:(void (^)(UIImage *))completionBlock;

@end
