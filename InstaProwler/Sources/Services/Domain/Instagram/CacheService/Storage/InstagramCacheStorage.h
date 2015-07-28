//
//  InstagramCacheStorage.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstagramMediaItem;

@protocol InstagramCacheStorage <NSObject>

- (void)setImage:(UIImage *)image withUrl:(NSString *)url withCompletionBlock:(void (^)())completionBlock;
- (void)getImageWithUrl:(NSString *)url withCompletionBlock:(void (^)(UIImage *))completionBlock;

- (void)storePost:(InstagramMediaItem *)post withCompletionBlock:(void (^)())completionBlock;
- (void)getPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock;

@end
